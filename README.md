# repository-template
Template for GitHub repositories

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit) [![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

# Contributing

### Commit Messages
All commit messages must conform to the format `<change type>(<scope>): <description of change>`. An example of a new feature would be `feat(payment): add new payment feature`. The list of accepted change types is:

* `ci`:       Changes to our CI configuration files and scripts (example scopes: Travis, Circle CI, BrowserStack, GitHub)
* `feat`:     Adds a new feature.
* `fix`:      Solves a bug.
* `docs`:     Adds or alters documentation. (example scopes: readme, worker, code_of_conduct, contributors)
* `style`:    Improves formatting, white-space.
* `refactor`: Rewrites code without feature, performance or bug changes.
* `perf`:     Improves performance.
* `test`:     Adds or modifies tests. (example scopes: functionals, unit-tests)
* `revert`:   Changes that reverting other changes
* `chore`:    No production code change. Updating grunt tasks etc;

### Commit Hooks
[ Install `pre-commit`](https://pre-commit.com/#install) and install the GitHub hook scripts
```bash
pre-commit install
pre-commit install -t commit-msg
```

This repository uses [pre-commit](https://pre-commit.com) and [commitlint](https://github.com/conventional-changelog/commitlint#what-is-commitlint) to ensure that code committed to this repository follows our formatting standards and is accompanied by a commit message that meets the [conventional commit format](https://www.conventionalcommits.org/en/v1.0.0/)

If you would like to use JIRA task IDs for your commit messages instead of the conventional format, following the instruction in [.commitlintrc.yaml](./.commitlintrc.yaml).


### Release Management
This repository uses [semantic-release](https://github.com/semantic-release/semantic-release) to manage the release process. Sematic-release runs on each merge to the master branch and will automatically generate a changelog and release.

For options on customizing the GitHub release process see the documentation for [semantic-release/github](https://github.com/semantic-release/github)
