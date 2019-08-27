# (Semi-)Automated Dependency Upgrades for JavaScript Projects

## Usage

To run semi-automated upgrades for the `acme/widgets` repo on GitHub,
clone this repo and run:

```
$ ./upgrade.sh acme/widgets
```

You will be prompted for approval before committing any changes.
Automatically runs `build`, `lint`, `documentation`, and `test` scripts
if defined in your project's **package.json**.

Also ensures that lockfiles (both yarn and npm) are up-to-date.
