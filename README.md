[_bashmenot_](https://bashmenot.mietek.io/)
===========================================

_bashmenot_ is a library of functions for safer shell scripting in [GNU _bash_](https://gnu.org/software/bash/), used by [Halcyon](https://halcyon.sh/) and [Haskell on Heroku](https://haskellonheroku.com/).


Usage
-----

```
$ git clone -q --depth=1 https://github.com/mietek/bashmenot.git
$ source bashmenot/src.sh
-----> Auto-updating bashmenot... done, fa1afe1
```

See the [programmer’s reference](https://bashmenot.mietek.io/reference/) for a description of available functions, including examples.


### Dependencies

_bashmenot_ requires [GNU _bash_](https://gnu.org/software/bash/) 4 or newer, and:

- [GNU _date_](https://gnu.org/software/coreutils/manual/html_node/date-invocation.html) for date formatting.
- [GNU _sort_](https://gnu.org/software/coreutils/manual/html_node/sort-invocation.html) for sorting.
- [_curl_](http://curl.haxx.se/) for HTTP transfer.
- [GNU _date_](https://gnu.org/software/coreutils/manual/html_node/date-invocation.html), [_curl_](http://curl.haxx.se/), and [OpenSSL](https://openssl.org/) for Amazon S3 storage.
- [_git_](http://git-scm.com/) for automatic updates.


### Bugs

Please report any problems with _bashmenot_ on the [issue tracker](https://github.com/mietek/bashmenot/issues/).

There is a [separate issue tracker](https://github.com/mietek/bashmenot-website/issues/) for problems with the documentation.


About
-----

My name is [Miëtek Bak](https://mietek.io/).  I make software, and _bashmenot_ is one of [my projects](https://mietek.io/projects/).

This work is published under the [MIT X11 license](https://bashmenot.mietek.io/license/), and supported by my company, [Least Fixed](https://leastfixed.com/).

Like my work?  I am available for consulting on software projects.  Say [hello](https://mietek.io/), or follow [@mietek](https://twitter.com/mietek).


### Acknowledgments

Thanks to [Kenneth Reitz](http://kennethreitz.org/) for building [_httpbin_](https://httpbin.org/).
