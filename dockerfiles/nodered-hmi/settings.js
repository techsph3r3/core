/**
 * Node-RED Settings for Sorting Facility HMI
 * Configured for CORE network emulator integration
 */

module.exports = {
    // Flow file location
    flowFile: 'flows.json',

    // Credential encryption key - change in production!
    credentialSecret: "sorting-hmi-secret-key",

    // HTTP settings
    uiPort: process.env.PORT || 1880,
    uiHost: "0.0.0.0",

    // Admin UI settings - editor at /, dashboard at /ui
    httpAdminRoot: '/',
    httpNodeRoot: '/',

    // Dashboard settings - accessible at /ui
    ui: { path: "ui" },

    // Logging
    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    },

    // Editor settings
    editorTheme: {
        page: {
            title: "Sorting Facility HMI"
        },
        header: {
            title: "Sorting Facility HMI",
            image: null
        },
        deployButton: {
            type: "simple",
            label: "Deploy"
        },
        menu: {
            "menu-item-import-library": false,
            "menu-item-export-library": false,
            "menu-item-keyboard-shortcuts": true,
            "menu-item-help": true
        }
    },

    // Function node settings
    functionGlobalContext: {
        os: require('os')
    },

    // Context storage
    contextStorage: {
        default: {
            module: "memory"
        }
    },

    // Export settings
    exportGlobalContextKeys: false,

    // Disable audit log for performance
    disableEditor: false
};
