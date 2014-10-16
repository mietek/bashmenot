[_bashmenot_](http://bashmenot.mietek.io/)
==========================================

_bashmenot_ is a library of functions for safer shell scripting in [GNU _bash_](http://gnu.org/software/bash/), used by [Halcyon](http://halcyon.sh/) and [_Haskell on Heroku_](http://haskellonheroku.com/).


Usage
-----

See the [programmer’s reference](http://bashmenot.mietek.io/reference/) for a detailed description of each available function, complete with usage examples.

- [Logging module](http://bashmenot.mietek.io/reference/#logging-module)
- [Expectation control module](http://bashmenot.mietek.io/reference/#expectation-control-module)
- [OS detection module](http://bashmenot.mietek.io/reference/#os-detection-module)
- [Quoting module](http://bashmenot.mietek.io/reference/#quoting-module)
- [Line processing module](http://bashmenot.mietek.io/reference/#line-processing-module)
- [Sorting module](http://bashmenot.mietek.io/reference/#sorting-module)
- [Date formatting module](http://bashmenot.mietek.io/reference/#date-formatting-module)
- [File system module](http://bashmenot.mietek.io/reference/#file-system-module)
- [Archiving module](http://bashmenot.mietek.io/reference/#archiving-module)
- [HTTP transfer module](http://bashmenot.mietek.io/reference/#http-transfer-module)
- [Amazon S3 storage module](http://bashmenot.mietek.io/reference/#amazon-s3-storage-module)


### Installation

```
$ git clone --depth=1 https://github.com/mietek/bashmenot.git
```


### Dependencies

_bashmenot_ requires [GNU _bash_](http://gnu.org/software/bash/) 4 or newer.

- Date formatting requires [GNU _date_](http://gnu.org/software/coreutils/manual/html_node/date-invocation.html).
- Sorting requires [GNU _sort_](http://gnu.org/software/coreutils/manual/html_node/sort-invocation.html).
- HTTP transfer requires [_curl_](http://curl.haxx.se/).
- Amazon S3 storage requires [GNU _date_](http://gnu.org/software/coreutils/manual/html_node/date-invocation.html), [_curl_](http://curl.haxx.se/), and [OpenSSL](https://www.openssl.org/).


### Bugs

Please report any problems with _bashmenot_ on the [issue tracker](https://github.com/mietek/bashmenot/issues/).

There is a [separate issue tracker](https://github.com/mietek/bashmenot-website/issues/) for problems with the documentation.


About
-----

My name is [Miëtek Bak](http://mietek.io/).  I make software, and _bashmenot_ is one of [my projects](http://mietek.io/projects/).

This work is published under the [MIT X11 license](http://bashmenot.mietek.io/license/), and supported by my company, [Least Fixed](http://leastfixed.com/).

Would you like to work with me?  Say [hello](http://mietek.io/).


### Acknowledgments

Thanks to [Kenneth Reitz](http://www.kennethreitz.org/) for building [_httpbin_](http://httpbin.org/).
