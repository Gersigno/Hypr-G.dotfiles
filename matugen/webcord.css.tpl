/* ~/.config/matugen/templates/webcord.css */
.theme-dark {
    /* --- FONDS PRINCIPAUX --- */
    --background-primary: {{colors.surface.default.hex}};           /* Fond des messages */
    --background-secondary: {{colors.surface_container_low.default.hex}};     /* Liste des salons */
    --background-secondary-alt: {{colors.surface_container_high.default.hex}}; /* Zone utilisateur (bas gauche) */
    --background-tertiary: {{colors.surface_container.default.hex}};          /* Liste des serveurs (extrême gauche) */
    --background-floating: {{colors.surface_container_highest.default.hex}};  /* Menus contextuels / Clic droit */

    /* --- EFFETS AU SURVOL (Listes de salons/membres) --- */
    /* On utilise la couleur bright avec de l'opacité (format HEXA à 8 caractères) */
    --background-modifier-hover: {{colors.surface_bright.default.hex}}33;    /* 20% opacité au survol */
    --background-modifier-selected: {{colors.surface_bright.default.hex}}55; /* 33% opacité quand sélectionné */
    --background-modifier-active: {{colors.surface_bright.default.hex}}77;   /* 46% opacité quand on clique */

    /* --- TEXTES --- */
    --text-normal: {{colors.on_surface.default.hex}};              /* Messages et texte classique */
    --text-muted: {{colors.on_surface_variant.default.hex}};       /* Salons non-lus / Salons muets */
    --header-primary: {{colors.on_surface.default.hex}};           /* Pseudos / Titres des salons */
    --header-secondary: {{colors.on_surface_variant.default.hex}}; /* Catégories (ex: "SALONS TEXTUELS") */
    --text-link: {{colors.tertiary.default.hex}};                  /* Liens hypertextes */

    /* --- LES COULEURS "BLURPLE" (L'accent de Discord) --- */
    /* Discord utilise toute une déclinaison pour ses boutons et mentions */
    --brand-experiment: {{colors.primary.default.hex}};
    --brand-experiment-100: {{colors.primary_container.default.hex}};
    --brand-experiment-200: {{colors.primary_container.default.hex}};
    --brand-experiment-300: {{colors.primary_container.default.hex}};
    --brand-experiment-400: {{colors.primary.default.hex}};
    --brand-experiment-500: {{colors.primary.default.hex}};        /* La couleur principale des boutons */
    --brand-experiment-600: {{colors.primary_fixed_dim.default.hex}};/* Bouton survolé */
    --brand-experiment-700: {{colors.primary_fixed_dim.default.hex}};/* Bouton cliqué */
    
    /* --- STATUTS --- */
    --status-online: {{colors.inverse_primary.default.hex}};
    --status-dnd: {{colors.error.default.hex}};
    --status-idle: {{colors.tertiary_container.default.hex}};
}