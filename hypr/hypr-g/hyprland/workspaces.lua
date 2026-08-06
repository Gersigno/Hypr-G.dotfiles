-- Auto create 4 persistent workspace PER monitor
local monitors = {}
local handle = io.popen("grep -l '^connected$' /sys/class/drm/card*-*/status 2>/dev/null")

if handle then
    for path in handle:lines() do
        local mon_name = path:match("card%d+%-([^/]+)/status")
        if mon_name then
            table.insert(monitors, mon_name)
        end
    end
    handle:close()
end

if #monitors == 0 then
    monitors = { "" }
end

for m_idx, mon_name in ipairs(monitors) do
    local start_ws = (m_idx - 1) * 4 + 1
    local end_ws = m_idx * 4

    for ws = start_ws, end_ws do
        hl.workspace_rule({
            workspace  = tostring(ws),
            monitor    = mon_name ~= "" and mon_name or nil,
            persistent = true,
        })
    end
end