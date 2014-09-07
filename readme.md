HHVM - [![Build Status](https://travis-ci.org/jakoch/php-hhvm.png?branch=master)](https://travis-ci.org/jakoch/php-hhvm)
----

A build script for building HHVM from source on Debian based linux distributions.

Travis is used as the Continuous Integration Platform, because they provide decent Ubuntu VMs.

The list of required packages (dependencies) to build HHVM is extensive, while at the same time the official build documentation is work in progress. Back, when i started this project, it was the first try of someone to build HHVM on a public build server.

### Use pre-build binaries 

You don't have to build HHVM from source. Travis-CI provides HHVM and a nightly build. So, if you simply want to use HHVM, maybe next to different PHP versions, then simply add the following to your `.travis.yml`: `php: [5.4, 5.5, 5.6, hhvm, hhvm-nightly]`. 

#### Status: It builds! 

The rest is a script playground. 
Plese feel free, to extend, for instance, the examples section in the build script, to demonstrate how to use HHVM on the CLI for running and inspecting PHP scripts.

#### Quick Links

- [Dependencies (HPHPFindLibs.cmake)](https://github.com/facebook/hiphop-php/blob/master/CMake/HPHPFindLibs.cmake)
- [HHVM Issues](https://github.com/facebook/hiphop-php/issues)
- [Building and installing HHVM on Ubuntu 12.04](https://github.com/facebook/hiphop-php/wiki/Building-and-installing-HHVM-on-Ubuntu-12.04)

### Notes on Build Failures

### make -jN
- I suggest to not use make -jN to build HHVM, because parallel jobs "tend to" make the build fail.
- On the other hand, building HHVM might exceed the allowed runtime for a build job on Travis-CI, which is limited to 50 minutes.
- To keep it under 50 minutes, we are building with "time ionice -c3 nice -n 19 make -j3".
- A build finishes in approximately 37 minutes.
- The result of "time" is  (time: real 36m14.618s - user	67m9.428s - sys	4m22.474s).
- The value "real" represents the actual elapsed time, while "user" and "sys" values represent CPU execution time.

