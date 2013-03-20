#!/usr/bin/env bash

#
# Building and installing HHVM
#
# https://github.com/facebook/hiphop-php/wiki/Building-and-installing-HHVM-on-Ubuntu-12.04
#
echo
echo -e "\e[1;32m\tBuilding and installing HHVM \e[0m"
echo -e "\t----------------------------"
echo

export CPUS=´cat /proc/cpuinfo | grep processor | wc -l´

# Install all package dependencies
function install_dependencies() {
    echo -en "\e[1;32m\tUpdating & Installing package dependencies.\e[0m"

    # for fetching libboost 1.50
    sudo add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ quantal main universe"

    sudo apt-get update -qq -y 
   
    sudo apt-get install -qq git-core cmake g++ libboost1.50-all-dev libmysqlclient-dev \
      libxml2-dev libmcrypt-dev libicu-dev openssl build-essential binutils-dev \
      libcap-dev libgd2-xpm-dev zlib1g-dev libtbb-dev libonig-dev libpcre3-dev \
      autoconf libtool libcurl4-openssl-dev wget memcached \
      libreadline-dev libncurses-dev libmemcached-dev libbz2-dev \
      libc-client2007e-dev php5-mcrypt php5-imagick libgoogle-perftools-dev \
      libcloog-ppl0 libelf-dev libdwarf-dev libunwind7-dev subversion

    echo -en "\e[1;32m\t> Done.\e[0m"
}

function get_hiphop_source() {
    echo -en "\e[1;32m\tFetching hiphop-php.\e[0m"

    mkdir dev
    cd dev
    git clone --depth 1 git://github.com/facebook/hiphop-php.git > /dev/null
    cd hiphop-php
    export CMAKE_PREFIX_PATH=`/bin/pwd`/..
    export HPHP_HOME=`/bin/pwd`
    export HPHP_LIB=`/bin/pwd`/bin
    export USE_HHVM=1
    cd ..

    echo -en "\e[1;32m\t> Done.\e[0m"
}

# libevent
function install_libevent() {
    echo -en "\e[1;33m\tInstalling libevent.\e[0m"

    git clone git://github.com/libevent/libevent.git > /dev/null
    cd libevent
    git checkout release-1.4.14b-stable  > /dev/null
    cat ../hiphop-php/hphp/third_party/libevent-1.4.14.fb-changes.diff | patch -p1 > /dev/null
    ./autogen.sh > /dev/null
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS install > /dev/null
    cd ..

    echo -en "\e[1;32m\t> Done.\e[0m"
}

# libCurl
function install_libcurl() {
    echo -en "\e[1;33m\tInstalling curl.\e[0m"

    git clone --depth 1 git://github.com/bagder/curl.git > /dev/null
    cd curl
    ./buildconf > /dev/null
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS install > /dev/null
    cd ..

    echo -en "\e[1;32m\t> Done.\e[0m"
}

# google glog
function install_googleglog() {
    echo -en "\e[1;33m\tInstalling Google Glog.\e[0m"

    svn checkout http://google-glog.googlecode.com/svn/trunk/ google-glog  > /dev/null
    cd google-glog
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS  > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS install  > /dev/null
    cd ..

    echo -en "\e[1;32m\t> Done.\e[0m"
}

# jemalloc
function install_jemalloc() {
    echo -en "\e[1;33m\tInstalling jemalloc.\e[0m"

    wget http://www.canonware.com/download/jemalloc/jemalloc-3.0.0.tar.bz2
    tar xjvf jemalloc-3.0.0.tar.bz2 > /dev/null
    cd jemalloc-3.0.0
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS  > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS install  > /dev/null
    cd ..

    echo -en "\e[1;32m\t> Done.\e[0m"
}

# libiconv
function install_libiconv() {
    echo -en "\e[1;33m\tInstalling libiconv.\e[0m"

    wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
    tar xvzf libiconv-1.14.tar.gz > /dev/null
    cd libiconv-1.14
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS  > /dev/null
    ionice -c3 nice -n 19 make -j $CPUS install  > /dev/null
    cd ..

    echo -en "\e[1;32m\t> Done.\e[0m"
}


function build() {
    echo -en "\e[1;33m\tBuilding HHVM.\e[0m"

    cd hiphop-php
    git submodule init
    git submodule update
    export HPHP_HOME=`pwd`
    export HPHP_LIB=`pwd`/bin
    ionice -c3 nice -n 19 cmake .
    ionice -c3 nice -n 19 make -j $CPUS

    echo -en "\e[1;32m\t> Done.\e[0m"
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

ln -fs ${CMAKE_PREFIX_PATH}/hiphop-php/src/hphp/hphp /usr/bin/hphp
ln -fs ${CMAKE_PREFIX_PATH}/hiphop-php/src/hhvm/hhvm /usr/bin/hhvm

## Success
echo -e "\n HipHop-PHP is now installed! \n"

## Fetch Version
hphp -v
hhvm -v

exit 0
