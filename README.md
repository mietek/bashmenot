[_bashmenot_](http://bashmenot.mietek.io/)
==========================================

Functions for safer shell scripting.  Used in [Halcyon](http://halcyon.sh/) and [Haskell on Heroku](http://haskellonheroku.com/).


Usage
-----

_bashmenot_ is a library of functions for safer shell scripting in [GNU _bash_](http://gnu.org/software/bash/).

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

See the [programmer’s reference](http://bashmenot.mietek.io/reference/) for a detailed description of each available function, complete with usage examples.


### Installation

```
$ git clone https://github.com/mietek/bashmenot.git
```


### Dependencies

_bashmenot_ requires [GNU _bash_](http://gnu.org/software/bash/) 4 or newer.

- Date formatting requires [GNU _date_](https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html).
- Sorting requires [GNU _sort_](https://www.gnu.org/software/coreutils/manual/html_node/sort-invocation.html).
- HTTP transfer requires [_curl_](http://curl.haxx.se/).
- Amazon S3 storage requires [GNU _date_](https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html), [_curl_](http://curl.haxx.se/), and [OpenSSL](https://www.openssl.org/).


Support
-------

Please report any problems with _bashmenot_ on the [issue tracker](https://github.com/mietek/bashmenot/issues/).  There is a [separate issue tracker](https://github.com/mietek/bashmenot-website/issues/) for problems with the documentation.

Commercial support for _bashmenot_ is offered by [Least Fixed](http://leastfixed.com/), a functional software consultancy.

Need help?  Say [hello](http://leastfixed.com/).


License
-------

Made by [Miëtek Bak](http://mietek.io/).  Published under the [MIT X11 license](http://bashmenot.mietek.io/license/).
