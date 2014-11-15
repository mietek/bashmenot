[_bashmenot_](https://bashmenot.mietek.io/)
===========================================

_bashmenot_ is a library of shell functions for [GNU _bash_](https://gnu.org/software/bash/), used by [Halcyon](https://halcyon.sh/) and [Haskell on Heroku](https://haskellonheroku.com/).


Usage
-----

Sourcing the top-level [`src.sh`](https://github.com/mietek/bashmenot/blob/master/src.sh) file brings all functions into scope, automatically updating _bashmenot_ to the newest version available.

```
$ git clone https://github.com/mietek/bashmenot
$ source bashmenot/src.sh
-----> Auto-updating bashmenot... done, fa1afe1
```

To disable automatic updates, set [`BASHMENOT_NO_AUTOUPDATE`](https://bashmenot.mietek.io/options/#bashmenot_no_autoupdate) to `1`.

Individual _bashmenot_ modules can also be sourced separately, as long as their dependencies are sourced in the appropriate order.


### Documentation

- [Function reference](https://bashmenot.mietek.io/functions/)
- [Option reference](https://bashmenot.mietek.io/options/)
- [Source code](https://github.com/mietek/bashmenot/)


### Dependencies

_bashmenot_ requires [GNU _bash_](https://gnu.org/software/bash/) 4 or newer, and:

- [GNU _date_](https://gnu.org/software/coreutils/manual/html_node/date-invocation.html)—date formatting
- [GNU _sort_](https://gnu.org/software/coreutils/manual/html_node/sort-invocation.html)—sorting
- [_curl_](http://curl.haxx.se/)—HTTP transfer
- [OpenSSL](https://openssl.org/)—hashing and Amazon S3 storage
- [_git_](http://git-scm.com/)—automatic updates


### Support

Please report any problems with _bashmenot_ on the [issue tracker](https://github.com/mietek/bashmenot/issues/).  There is a [separate issue tracker](https://github.com/mietek/bashmenot-website/issues/) for problems with the documentation.


About
-----

My name is [Miëtek Bak](https://mietek.io/).  I make software, and _bashmenot_ is one of [my projects](https://mietek.io/projects/).

This work is published under the [MIT X11 license](https://bashmenot.mietek.io/license/), and supported by my company, [Least Fixed](https://leastfixed.com/).

Like my work?  I am available for consulting on software projects.  Say [hello](https://mietek.io/), or follow [@mietek](https://twitter.com/mietek).


### Acknowledgments

Thanks to [Kenneth Reitz](http://kennethreitz.org/) for building [_httpbin_](https://httpbin.org/).
