const fs = require('fs');
const path = require('path');

// Flows directory (configured in Dockerfile)
const flowsDir = process.env.KATA_PATH_FLOWS

// Node-RED users
const authUsersFile = 'flows_auth.json';
const authUsers = require(`./${authUsersFile}`);
if (!authUsers) {
    console.error(`authUsers file missing or empty: ${authUsersFile}`);
    process.exit(1);
}

module.exports = {
    uiPort: process.env.PORT || 1881,
    httpRequestTimeout: 5000,
    debugMaxLength: 100,
    debugUseColors: true,
    flowFile: 'flows.json',
    flowFilePretty: true,
    credentialSecret: false,
    userDir: flowsDir,
    adminAuth: {
        type: 'credentials',
        users: authUsers,
        default: {
            permissions: "read"
        }
    },
    logging: {
        console: {
            level: 'info',
            metrics: false,
            audit: false
        }
    },
    editorTheme: {
        page: {
            title: 'API Gateway'
        },
        header: {
            title: 'Node-RED API Gateway',
            url: 'https://nodered.org/'
        },
        projects: {
            enabled: false
        }
    }
}
