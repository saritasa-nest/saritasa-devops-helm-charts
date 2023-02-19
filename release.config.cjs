const COMMIT_ANALYZER = [
  '@semantic-release/commit-analyzer',
  {
    preset: 'angular',
    releaseRules: [
      { tag: 'Breaking', release: 'major' },
      { tag: 'Feature', release: 'minor' },
      { tag: 'Feature', release: 'minor' },
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
    preset: 'angular'
  }
];

const CHANGELOG = [
  '@semantic-release/changelog',
  {
    changelogFile: '__CHART__/CHANGELOG.md'
  }
]

const HELM = [
  'semantic-release-helm3',
  {
    chartPath: '__CHART__',
    onlyUpdateVersion: true
  }
]


module.exports = {
  branches: [
    '+([0-9])?(.{+([0-9]),x}).x',
    'main',
    { name: 'alpha', prerelease: true }
  ],
  plugins: [
    COMMIT_ANALYZER,
    RELEASE_NOTES_GENERATOR,
    CHANGELOG,
    HELM
  ]
};
