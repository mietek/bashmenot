_bashmenot_
===========

[_bashmenot_](http://bashmenot.mietek.io/).  Functions for safer shell scripting.

Used in [Halcyon](http://halcyon.sh/) and [Haskell on Heroku](http://haskellonheroku.com/).


Usage
-----

Please see the [programmer’s reference](http://bashmenot.mietek.io/reference/) for a complete description of each function, including usage examples.


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

Requires [GNU _bash_](http://gnu.org/software/bash/) 4 or newer.

Some functions require [GNU _date_](https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html) and [GNU _sort_](https://www.gnu.org/software/coreutils/manual/html_node/sort-invocation.html), available as part of [GNU _coreutils_](https://www.gnu.org/software/coreutils/).

HTTP transfer functions require [_curl_](http://curl.haxx.se/).  Amazon S3 transfer functions also require [OpenSSL](https://www.openssl.org/).


Support
-------

Please report any problems with _bashmenot_ on the [issue tracker](https://github.com/mietek/bashmenot/issues/).  There is a [separate issue tracker](https://github.com/mietek/bashmenot-website/issues/) for problems with the documentation.

Commercial support for _bashmenot_ is offered by [Least Fixed](http://leastfixed.com/), a functional software consultancy.

Need help?  Say [hello](http://leastfixed.com/).


License
-------

Made by [Miëtek Bak](http://mietek.io/).  Published under the [MIT X11 license](http://bashmenot.mietek.io/license/).
