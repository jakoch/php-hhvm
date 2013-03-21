HHVM - [![Build Status](https://travis-ci.org/jakoch/php-hhvm.png?branch=master)](https://travis-ci.org/jakoch/php-hhvm)
----

A build script for building HHVM on Debian based linux distributions.

Travis is used as the Continuous Integration Platform, because they provide decent Ubuntu VMs.

The list of required packages (dependencies) to build HHVM is extensive, while at the same time the official build documentation is work in progress.

#### Quick Links

- [Dependencies (HPHPFindLibs.cmake)](https://github.com/facebook/hiphop-php/blob/master/CMake/HPHPFindLibs.cmake)
- [HHVM Issues](https://github.com/facebook/hiphop-php/issues)
- [Building and installing HHVM on Ubuntu 12.04](https://github.com/facebook/hiphop-php/wiki/Building-and-installing-HHVM-on-Ubuntu-12.04)
- [Building and installing HHVM on Ubuntu 12.10 (AWS)](https://github.com/facebook/hiphop-php/wiki/Building-and-installing-HHVM-on-Ubuntu-12.10-%28tested-on-AWS%29)

#### Building on CentOS

If you intend building HHVM on CentOS, you might take a look at https://github.com/jackywei/HOW-TO-BUILD-HHVM-WiKi

### Notes on Build Failures

### make -jN
- I suggest to not use make -jN to build HHVM, because parallel jobs "tend to" make the build fail.
- On the other hand, building HHVM might exceed the allowed runtime for a build job on Travis-CI, which is limited to 50 minutes.
- To keep it under 50 minutes, we are building with "time ionice -c3 nice -n 19 make -j2". 
A build finishes in approximately 37 minutes.
The result of "time" is  (time: real 36m14.618s - user	67m9.428s - sys	4m22.474s).
The value "real" represents the actual elapsed time, while "user" and "sys" values represent CPU execution time.

### -- Performing Test LIBICONV_CONST - Failed
 
According to https://github.com/facebook/hiphop-php/issues/689#issuecomment-13429681
"LIBICONV_CONST test: It's okay for this to "fail". In the context of this test, 
"fail" just indicates that the version of iconv you're using is of a particular version, 
and hiphop adapts itself around that."

