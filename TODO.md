# TODO


## Alternative

Better for implementing other ebuild generators?

Racket:          pkgs-hash -> json
Python/Anything: json      -> json-to-ebuild-converter


## Net

report+error:
- if network is inaccessible ?
- if we get a empty hash


## Ebuild Generation

### Skip

Also skip if the SAME snapshot already exists!

#### Build

- fails
- has dependency problems

#### Tags

- main-tests ?

### Categories

...or put everything in dev-racket

From tags.

- app, application - app-misc
- language         - dev-lang
- game, games      - games-misc

### Variables

If has docs -> SCRIBBLE_DOCS=ON

### Hash map

```racket
#hash(["package-name" . #hash(["version-number" . "ebuild-script"])])
```


## Interaction

### Via command-line options

```shell
    -d --directory  overlay directory
    -o --overwrite  overwrite ebuild versions
    -s --simulate   dry run; do not create files
    -v --verbose    also display created ebuilds
```

#### Ebuild update

- --ebuild-update - generate ebuild again and diff the changes

#### Report

- --report-location -> ebuild location (ie.: "::rkt dev-lang/anarki")
- --report-recent   -> up-to-date ebuilds
- --report-outdated -> outdated ebuilds


## Libraries

Separate into collector2-lib and collector2
