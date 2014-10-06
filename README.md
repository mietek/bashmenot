bashmenot
=========

Library for safer shell scripting with [GNU bash](http://gnu.org/software/bash/).

Minimal dependencies.  Reasonably cross-platform.

Used in [Halcyon](https://github.com/mietek/halcyon/) and [Haskell on Heroku](https://github.com/mietek/haskell-on-heroku/).


Usage
-----

Sourcing the top-level script brings all functions into scope, without any side effects.

```sh
source bashmenot/bashmenot.sh
```

Individual modules can also be sourced separately, as long as their dependencies are sourced as well.

Refer to the [documentation](http://halcyon.sh/docs/library-reference/) for details and examples.


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
