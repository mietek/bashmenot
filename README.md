bashmenot
=========

Library for safer shell scripting with [GNU bash](http://gnu.org/software/bash/).

Minimal dependencies.  Reasonably cross-platform.

Used in [Halcyon](https://github.com/mietek/halcyon/) and [Haskell on Heroku](https://github.com/mietek/haskell-on-heroku/).

Contains functions to help with:

- [Logging](http://halcyon.sh/docs/bashmenot/#logging)
- [Expecting preconditions](http://halcyon.sh/docs/bashmenot/#expecting-preconditions)
- [OS detection](http://halcyon.sh/docs/bashmenot/#os-detection)
- [Quoting](http://halcyon.sh/docs/bashmenot/#quoting)
- [Line processing](http://halcyon.sh/docs/bashmenot/#line-processing)
- [Sorting](http://halcyon.sh/docs/bashmenot/#sorting)
- [File operations](http://halcyon.sh/docs/bashmenot/#file-operations)
- [Archiving](http://halcyon.sh/docs/bashmenot/#archiving)
- [Date formatting](http://halcyon.sh/docs/bashmenot/#date-formatting)
- [HTTP transfers](http://halcyon.sh/docs/bashmenot/#http-transfers)
- [Amazon S3 transfers](http://halcyon.sh/docs/bashmenot/#amazon-s3-transfers)


Usage
-----

Sourcing the top-level script safely brings all functions into scope, without causing any side effects.

```sh
source bashmenot/bashmenot.sh
```

You can also source individual modules, as long as you source their dependencies as well.

Examples are included in the [function reference](http://halcyon.sh/docs/bashmenot/).


### Installation

Available as a [Bower](http://bower.io/) package.

```sh
bower install bashmenot
```


### Dependencies

Requires [GNU bash](http://gnu.org/software/bash/) 4 or newer.  Some functions require [GNU date](https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html) and [GNU sort](https://www.gnu.org/software/coreutils/manual/html_node/sort-invocation.html), available as part of [GNU coreutils](https://www.gnu.org/software/coreutils/).

HTTP transfers require [curl](http://curl.haxx.se/).  Amazon S3 transfers also require [OpenSSL](https://www.openssl.org/).


License
-------

[MIT X11](https://github.com/mietek/license/blob/master/LICENSE.md) © [Miëtek Bak](http://mietek.io/)
