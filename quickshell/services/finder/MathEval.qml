pragma Singleton

import QtQuick

/**
 * Native, sandboxed math evaluator for the Finder's "=" prefix.
 *
 * The expression is tokenized and parsed by hand; eval(), Function(),
 * subprocesses and external tools are never used. Only the whitelisted
 * operators, constants and functions below are accepted. Malformed input,
 * unknown symbols and non-finite results all return null.
 *
 * Supported syntax:
 *   + - * / % ^, parentheses, implicit multiplication (2pi, 3(4+5))
 *   constants: pi, tau, e, phi
 *   functions: abs, sign, sqrt, cbrt, exp, ln, log, log2, log10, floor,
 *              ceil, round, trunc, sin, cos, tan, asin, acos, atan, atan2,
 *              sinh, cosh, tanh, pow, mod, hypot, min, max
 *   postfix percent: 50% -> 0.5 (10 % 3 is modulo, 10% is percent)
 *
 * Numbers are IEEE-754 doubles, so results are exact up to 15 significant
 * digits, like any classic calculator. Division by zero (or overflow to
 * infinity) yields no result instead of a bogus one.
 */

QtObject {
    id: root

    readonly property int maxLength: 512
    readonly property int maxDepth: 64

    readonly property var _constants: ({
        "pi": Math.PI,
        "tau": Math.PI * 2,
        "e": Math.E,
        "phi": (1 + Math.sqrt(5)) / 2,
    })

    readonly property var _functions: ({
        "abs":   { min: 1, max: 1,  run: a => Math.abs(a[0]) },
        "sign":  { min: 1, max: 1,  run: a => a[0] === 0 ? 0 : (a[0] > 0 ? 1 : -1) },
        "sqrt":  { min: 1, max: 1,  run: a => Math.sqrt(a[0]) },
        "cbrt":  { min: 1, max: 1,  run: a => a[0] < 0 ? -Math.pow(-a[0], 1 / 3) : Math.pow(a[0], 1 / 3) },
        "exp":   { min: 1, max: 1,  run: a => Math.exp(a[0]) },
        "ln":    { min: 1, max: 1,  run: a => Math.log(a[0]) },
        "log":   { min: 1, max: 2,  run: a => a.length === 2 ? Math.log(a[0]) / Math.log(a[1]) : Math.log(a[0]) / Math.LN10 },
        "log2":  { min: 1, max: 1,  run: a => Math.log(a[0]) / Math.LN2 },
        "log10": { min: 1, max: 1,  run: a => Math.log(a[0]) / Math.LN10 },
        "floor": { min: 1, max: 1,  run: a => Math.floor(a[0]) },
        "ceil":  { min: 1, max: 1,  run: a => Math.ceil(a[0]) },
        "round": { min: 1, max: 2,  run: a => {
            const f = Math.pow(10, a.length === 2 ? a[1] : 0)
            return Math.round(a[0] * f) / f
        } },
        "trunc": { min: 1, max: 1,  run: a => a[0] < 0 ? Math.ceil(a[0]) : Math.floor(a[0]) },
        "sin":   { min: 1, max: 1,  run: a => Math.sin(a[0]) },
        "cos":   { min: 1, max: 1,  run: a => Math.cos(a[0]) },
        "tan":   { min: 1, max: 1,  run: a => Math.tan(a[0]) },
        "asin":  { min: 1, max: 1,  run: a => Math.asin(a[0]) },
        "acos":  { min: 1, max: 1,  run: a => Math.acos(a[0]) },
        "atan":  { min: 1, max: 1,  run: a => Math.atan(a[0]) },
        "atan2": { min: 2, max: 2,  run: a => Math.atan2(a[0], a[1]) },
        "sinh":  { min: 1, max: 1,  run: a => (Math.exp(a[0]) - Math.exp(-a[0])) / 2 },
        "cosh":  { min: 1, max: 1,  run: a => (Math.exp(a[0]) + Math.exp(-a[0])) / 2 },
        "tanh":  { min: 1, max: 1,  run: a => {
            const p = Math.exp(2 * a[0])
            const m = Math.exp(-2 * a[0])
            return (p - m) / (p + m)
        } },
        "pow":   { min: 2, max: 2,  run: a => Math.pow(a[0], a[1]) },
        "mod":   { min: 2, max: 2,  run: a => a[0] % a[1] },
        "hypot": { min: 2, max: 16, run: a => Math.sqrt(a.reduce((sum, x) => sum + x * x, 0)) },
        "min":   { min: 1, max: 32, run: a => Math.min.apply(null, a) },
        "max":   { min: 1, max: 32, run: a => Math.max.apply(null, a) },
    })

    // -----------------------------------------------------------------
    //      Public API
    // -----------------------------------------------------------------
    /**
     * Evaluates a math expression. Returns a formatted string on success
     * or null when the expression is invalid / not finite.
     */
    function evaluate(expression) {
        if (typeof expression !== "string")
            return null

        const src = expression.trim()
        if (src.length === 0 || src.length > root.maxLength)
            return null

        let pos = 0
        let depth = 0

        // -------- character helpers --------
        function peek(offset) {
            const i = pos + (offset ?? 0)
            return (i >= 0 && i < src.length) ? src.charAt(i) : ""
        }
        function skipSpaces() {
            while (peek() === " " || peek() === "\t")
                pos++
        }
        function isDigit(c) {
            return c >= "0" && c <= "9"
        }
        function isIdentStart(c) {
            return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c === "_"
        }
        function isIdentPart(c) {
            return isIdentStart(c) || isDigit(c)
        }
        function startsOperand(c) {
            return c !== "" && (isDigit(c) || isIdentStart(c) || c === "." || c === "(")
        }

        // -------- grammar --------
        // expression := term (('+' | '-') term)*
        function parseExpression() {
            if (++depth > root.maxDepth)
                throw new Error("expression too deeply nested")
            try {
                let value = parseTerm()
                for (;;) {
                    skipSpaces()
                    const c = peek()
                    if (c === "+") {
                        pos++
                        value += parseTerm()
                    } else if (c === "-") {
                        pos++
                        value -= parseTerm()
                    } else {
                        return value
                    }
                }
            } finally {
                depth--
            }
        }

        // term := unary (('*' | '/' | '%') unary | implicit-multiplication)*
        function parseTerm() {
            let value = parseUnary()
            for (;;) {
                skipSpaces()
                const c = peek()
                if (c === "*") {
                    pos++
                    value *= parseUnary()
                } else if (c === "/") {
                    pos++
                    value /= parseUnary()
                } else if (c === "%") {
                    pos++
                    skipSpaces()
                    if (startsOperand(peek()))
                        value %= parseUnary()   // binary modulo
                    else
                        value /= 100           // postfix percent
                } else if (startsOperand(c)) {
                    value *= parseUnary()       // implicit multiplication
                } else {
                    return value
                }
            }
        }

        // unary := ('+' | '-') unary | power
        function parseUnary() {
            skipSpaces()
            const c = peek()
            if (c === "+") {
                pos++
                return parseUnary()
            }
            if (c === "-") {
                pos++
                return -parseUnary()
            }
            return parsePower()
        }

        // power := primary ('^' unary)?   (right associative)
        function parsePower() {
            const base = parsePrimary()
            skipSpaces()
            if (peek() === "^") {
                pos++
                return Math.pow(base, parseUnary())
            }
            return base
        }

        // primary := number | constant | function '(' args ')' | '(' expression ')'
        function parsePrimary() {
            skipSpaces()
            const c = peek()
            if (c === "(") {
                pos++
                const value = parseExpression()
                skipSpaces()
                if (peek() !== ")")
                    throw new Error("missing closing parenthesis")
                pos++
                return value
            }
            if (isDigit(c) || c === ".")
                return parseNumber()
            if (isIdentStart(c))
                return parseIdentifier()
            throw new Error("unexpected character")
        }

        function parseNumber() {
            const start = pos
            while (isDigit(peek()))
                pos++
            if (peek() === ".") {
                pos++
                while (isDigit(peek()))
                    pos++
            }
            // Optional exponent; if there is no digit after 'e'/'E', leave it
            // for the identifier parser (so "2e" means 2 * e).
            if (peek() === "e" || peek() === "E") {
                const savedPos = pos
                pos++
                if (peek() === "+" || peek() === "-")
                    pos++
                if (isDigit(peek())) {
                    while (isDigit(peek()))
                        pos++
                } else {
                    pos = savedPos
                }
            }
            const text = src.slice(start, pos)
            const value = Number(text)
            if (!isFinite(value) || text === "")
                throw new Error("invalid number")
            return value
        }

        function parseIdentifier() {
            const start = pos
            while (isIdentPart(peek()))
                pos++
            const name = src.slice(start, pos).toLowerCase()
            const afterName = pos
            skipSpaces()

            const constant = root._constants[name]
            if (peek() !== "(" || constant !== undefined) {
                if (constant === undefined)
                    throw new Error("unknown symbol: " + name)
                // "e(2)" must mean e * (2), not a function call.
                pos = afterName
                return constant
            }

            pos++ // consume "("
            const args = []
            skipSpaces()
            if (peek() !== ")") {
                for (;;) {
                    args.push(parseExpression())
                    skipSpaces()
                    const separator = peek()
                    if (separator === "," || separator === ";") {
                        pos++
                        continue
                    }
                    break
                }
            }
            skipSpaces()
            if (peek() !== ")")
                throw new Error("missing closing parenthesis")
            pos++

            const fn = root._functions[name]
            if (fn === undefined)
                throw new Error("unknown function: " + name)
            if (args.length < fn.min || args.length > fn.max)
                throw new Error("wrong argument count for " + name)
            return fn.run(args)
        }

        // -------- run --------
        try {
            const value = parseExpression()
            skipSpaces()
            if (pos !== src.length)
                return null
            return root.format(value)
        } catch (e) {
            return null
        }
    }

    /**
     * Formats a finite number: 12 significant digits, trimming binary
     * floating point noise (0.1 + 0.2 -> 0.3) and switching to scientific
     * notation for very large / very small values.
     */
    function format(value) {
        if (typeof value !== "number" || !isFinite(value))
            return null
        if (value === 0)
            return "0"

        const abs = Math.abs(value)
        let text
        if (abs >= 1e15 || abs < 1e-9) {
            text = value.toExponential(11)
            text = text.replace(/(\.\d*?)0+e/, "$1e").replace(/\.e/, "e")
        } else {
            text = String(parseFloat(value.toPrecision(12)))
        }
        return text
    }
}
