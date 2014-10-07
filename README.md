bashmenot
=========

Library of functions for safer shell scripting.

Used in [Halcyon](http://halcyon.sh/).


Usage
-----

Sourcing the top-level script brings all functions into scope.

```
$ source bashmenot/bashmenot.sh
```

Individual modules can be sourced separately, as long as their dependencies are sourced as well.

Please refer to the [documentation](http://halcyon.sh/documentation/library-reference/) for more information, including module dependencies and usage examples.


### Installation

Cloning the repository is sufficient.

```
$ git clone https://github.com/mietek/bashmenot.git
```

Also available as a [Bower](http://bower.io/) package.

```
$ bower install bashmenot
```


### Dependencies

Requires [GNU bash](http://gnu.org/software/bash/) 4 or newer.  Some functions require [GNU date](https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html) and [GNU sort](https://www.gnu.org/software/coreutils/manual/html_node/sort-invocation.html), available as part of [GNU coreutils](https://www.gnu.org/software/coreutils/).

HTTP transfer functions require [curl](http://curl.haxx.se/).  Amazon S3 transfer functions also require [OpenSSL](https://www.openssl.org/).


License
-------

[MIT X11](https://github.com/mietek/license/blob/master/LICENSE.md) © [Miëtek Bak](http://mietek.io/)
