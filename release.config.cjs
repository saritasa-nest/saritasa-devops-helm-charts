const COMMIT_ANALYZER = [
    '@semantic-release/commit-analyzer',
    {
        preset: 'eslint',
        releaseRules: [
            { tag: 'Breaking', release: 'major' },
            { tag: 'New', release: 'minor' },
            { tag: 'Update', release: 'minor' },
            { tag: 'Fix', release: 'patch' },
            { tag: 'Upgrade', release: 'patch' }
        ]
    }
];

const RELEASE_NOTES_GENERATOR = [
    '@semantic-release/release-notes-generator',
    {
        preset: 'eslint'
    }
];

const CHANGELOG = [
    '@semantic-release/changelog',
    {
      changelogFile: 'charts/CHANGELOG.md'
    }
]

const HELM = [
    'semantic-release-helm3',
    {
      chartPath: 'charts',
        onlyUpdateVersion: true
    }
]


module.exports = {
    branches: [
        '+([0-9])?(.{+([0-9]),x}).x',
        'main',
    { name: 'beta', prerelease: true },
    { name: 'alpha', prerelease: true }
    ],
    plugins: [
        COMMIT_ANALYZER,
        RELEASE_NOTES_GENERATOR,
        CHANGELOG,
        HELM
    ]
};
