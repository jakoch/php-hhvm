#!/usr/bin/env bash
shopt -s expand_aliases

#
# A build script for building HHVM on Debian based linux distributions.
#
# https://github.com/jakoch/php-hhvm
#

echo
echo -e "\e[1;32m\tBuilding and installing HHVM \e[0m"
echo -e "\t----------------------------"
echo

# how many virtual processors are there?
export NUMCPUS=`grep ^processor /proc/cpuinfo | wc -l`

# parallel make
alias pmake='time ionice -c3 nice -n 19 make -j$NUMCPUS --load-average=$NUMCPUS'

# Install all package dependencies
function install_dependencies() {
    echo
    echo -e "\e[1;33mInstalling package dependencies...\e[0m"
    echo

    # for fetching libboost 1.50
    sudo add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ quantal main universe"

    sudo apt-get update -y &> /dev/null

    sudo apt-get install git-core cmake g++ libboost1.50-all-dev libmysqlclient-dev \
      libxml2-dev libmcrypt-dev libicu-dev openssl build-essential binutils-dev \
      libcap-dev libgd2-xpm-dev zlib1g-dev libtbb-dev libonig-dev libpcre3-dev \
      autoconf libtool libcurl4-openssl-dev wget memcached \
      libreadline-dev libncurses-dev libmemcached-dev libbz2-dev \
      libc-client2007e-dev php5-mcrypt php5-imagick libgoogle-perftools-dev \
      libcloog-ppl0 libelf-dev libdwarf-dev libunwind7-dev libnotify-dev subversion &> /dev/null

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

# libevent
function install_libevent() {
    echo
    echo -e "\e[1;33mInstalling libevent...\e[0m"
    echo

    git clone --quiet git://github.com/libevent/libevent.git
    cd libevent
    git checkout release-1.4.14b-stable  > /dev/null
    cat ../hiphop-php/hphp/third_party/libevent-1.4.14.fb-changes.diff | patch -p1 > /dev/null
    ./autogen.sh > /dev/null
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    pmake > /dev/null
    pmake install > /dev/null
    cd ..

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

# libCurl
function install_libcurl() {
    echo
    echo -e "\e[1;33mInstalling libcurl...\e[0m"
    echo

    git clone --quiet --depth 1 git://github.com/bagder/curl.git
    cd curl
    ./buildconf > /dev/null
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    pmake > /dev/null
    pmake install > /dev/null
    cd ..

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

# google glog
function install_googleglog() {
    echo
    echo -e "\e[1;33mInstalling Google Glog...\e[0m"
    echo

    svn checkout http://google-glog.googlecode.com/svn/trunk/ google-glog  > /dev/null
    cd google-glog
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    pmake > /dev/null
    pmake install  > /dev/null
    cd ..

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

# jemalloc
function install_jemalloc() {
    echo
    echo -e "\e[1;33mInstalling jemalloc...\e[0m"
    echo

    wget --quiet http://www.canonware.com/download/jemalloc/jemalloc-3.0.0.tar.bz2
    tar xjvf jemalloc-3.0.0.tar.bz2 > /dev/null
    cd jemalloc-3.0.0
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    pmake > /dev/null
    pmake install > /dev/null
    cd ..

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

# libiconv
function install_libiconv() {
    echo
    echo -e "\e[1;33mInstalling libiconv...\e[0m"
    echo

    wget --quiet http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
    tar xvzf libiconv-1.14.tar.gz > /dev/null
    cd libiconv-1.14
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    pmake > /dev/null
    pmake install  > /dev/null
    cd ..

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

function get_hiphop_source() {
    echo
    echo -e "\e[1;33mFetching hiphop-php...\e[0m"
    echo

    mkdir dev
    cd dev
    git clone --quiet --depth 1 git://github.com/facebook/hiphop-php.git
    cd hiphop-php
    export CMAKE_PREFIX_PATH=`/bin/pwd`/..
    export HPHP_HOME=`/bin/pwd`
    export HPHP_LIB=`/bin/pwd`/bin
    export USE_HHVM=1
    cd ..

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

function build() {
    echo
    echo -e "\e[1;33mBuilding HHVM...\e[0m"
    echo

    cd hiphop-php
    git submodule init > /dev/null
    git submodule update > /dev/null
    export HPHP_HOME=`pwd`
    export HPHP_LIB=`pwd`/bin
    ionice -c3 nice -n 19 cmake .
    #pmake
    time ionice -c3 nice -n 19 make -j3

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

function install() {
    install_dependencies
    # the hiphop source must be fetched before the libraries, because of patches
    get_hiphop_source
      install_libevent
      install_libcurl
      install_googleglog
      install_jemalloc
      install_libiconv
    build
}

install

## Success
echo
echo -e "\e[1;32m *** HHVM is now installed! *** \e[0m"
echo

echo
echo -e "\e[1;32m *** Launching some basic HHVM commands as a demonstration! *** \e[0m"
echo

## Display Version
${CMAKE_PREFIX_PATH}/hiphop-php/hphp/hhvm/hhvm --version

## Display Help
${CMAKE_PREFIX_PATH}/hiphop-php/hphp/hhvm/hhvm --help

## Getting started with Hello-World
echo -e "<?php\n echo 'Hello Hiphop-PHP!' . PHP_EOL;\n?>" > hello.php

# Example of executing specified file
${CMAKE_PREFIX_PATH}/hiphop-php/hphp/hhvm/hhvm --file hello.php

# Example of the Server Mode
#${CMAKE_PREFIX_PATH}/hiphop-php/hphp/hhvm/hhvm -m server -p 8123 ./
#lynx -source http://127.0.0.1:8123/hello.php

# Example of parsing the specified file and dumping the AST
#${CMAKE_PREFIX_PATH}/hiphop-php/hphp/hhvm/hhvm --parse hello.php

# Run HHVM TestSuite
${CMAKE_PREFIX_PATH}/hiphop-php/hphp/hhvm/hhvm hphp/test/run --arg --threads 4 quick zend slow

exit 0
