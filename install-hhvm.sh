#!/usr/bin/env bash

#
# Building and installing HHVM
#
# https://github.com/facebook/hiphop-php/wiki/Building-and-installing-HHVM-on-Ubuntu-12.04
#

# Install all package dependencies
function install_dependencies() {
    echo -e "\n Update & Install package dependencies. \n"

    # this is need to fetch libboost 1.5
    sudo add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ quantal main universe"

    sudo apt-get update -y
   
    sudo apt-get install git-core cmake g++ libboost1.50-all-dev libmysqlclient-dev \
      libxml2-dev libmcrypt-dev libicu-dev openssl build-essential binutils-dev \
      libcap-dev libgd2-xpm-dev zlib1g-dev libtbb-dev libonig-dev libpcre3-dev \
      autoconf libtool libcurl4-openssl-dev wget memcached \
      libreadline-dev libncurses-dev libmemcached-dev libbz2-dev \
      libc-client2007e-dev php5-mcrypt php5-imagick libgoogle-perftools-dev \
      libcloog-ppl0 libelf-dev libdwarf-dev libunwind7-dev subversion

      echo -e "\n > Done. \n"
}

function get_hiphop_source() {
    echo -e "\n Fetching hiphop-php.\n"

    mkdir dev
    cd dev
    git clone git://github.com/facebook/hiphop-php.git
    cd hiphop-php
    export CMAKE_PREFIX_PATH=`/bin/pwd`/..
    export HPHP_HOME=`/bin/pwd`
    export HPHP_LIB=`/bin/pwd`/bin
    export USE_HHVM=1
    cd ..

    echo -e "\n > Done. \n"
}

# Boost C++ Libraries
function install_libboost() {
    echo -e "\n Installing Boost C++ Libraries.\n"

    wget -c 'http://sourceforge.net/projects/boost/files/boost/1.53.0/boost_1_53_0.tar.bz2/download'
    tar xf download
    cd boost_1_53_0
    ./bootstrap.sh
    ./b2 install

    echo -e "\n > Done. \n"
}

# libevent
function install_libevent() {
    echo -e "Installing libevent.\n"

    git clone git://github.com/libevent/libevent.git
    cd libevent
    git checkout release-1.4.14b-stable
    cat ../hiphop-php/hphp/third_party/libevent-1.4.14.fb-changes.diff | patch -p1
    ./autogen.sh
    ./configure --prefix=$CMAKE_PREFIX_PATH
    make && make install
    cd ..

    echo -e "\n > Done. \n"
}

# libCurl
function install_libcurl() {
    echo -e "\n Installing curl. \n"

    git clone git://github.com/bagder/curl.git
    cd curl
    ./buildconf
    ./configure --prefix=$CMAKE_PREFIX_PATH
    make && make install
    cd ..

    echo -e "\n > Done. \n"
}

# google glog
function install_googleglog() {
    echo -e "\n Installing Google Glog. \n"

    svn checkout http://google-glog.googlecode.com/svn/trunk/ google-glog
    cd google-glog
    ./configure --prefix=$CMAKE_PREFIX_PATH
    make && make install
    cd ..

    echo -e "\n > Done. \n"
}

# jemalloc
function install_jemalloc() {
    echo -e "\n Installing jemalloc. \n"

    wget http://www.canonware.com/download/jemalloc/jemalloc-3.0.0.tar.bz2
    tar xjvf jemalloc-3.0.0.tar.bz2
    cd jemalloc-3.0.0
    ./configure --prefix=$CMAKE_PREFIX_PATH
    make && make install
    cd ..

    echo -e "\n > Done. \n"
}

# libunwind
function install_libunwind() {
    echo -e "\n Installing libunwind. \n"

    wget http://download.savannah.gnu.org/releases/libunwind/libunwind-1.1.tar.gz
    tar xvzf libunwind-1.1.tar.gz
    cd libunwind-1.1
    autoreconf -i -f
    ./configure --prefix=$CMAKE_PREFIX_PATH
    make && make install
    cd ..

    echo -e "\n > Done. \n"
}

# libiconv
function install_libiconv() {
    echo -e "\n Installing libiconv. \n"

    wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
    tar xvzf libiconv-1.14.tar.gz
    cd libiconv-1.14
    ./configure --prefix=$CMAKE_PREFIX_PATH
    make && make install
    cd ..

    echo -e "\n > Done. \n"
}


function build() {
    echo -e "\n Building HHVM. \n"

    cd hiphop-php
    git submodule init
    git submodule update
    export HPHP_HOME=`pwd`
    export HPHP_LIB=`pwd`/bin
    cmake .
    make

    echo -e "\n > Done. \n"
}

function install() {
    install_dependencies
    get_hiphop_source
        install_libevent
        install_libcurl
        install_googleglog
        install_jemalloc
        install_libunwind
        install_libiconv
    build
}

install

ln -fs ${CMAKE_PREFIX_PATH}/hiphop-php/src/hphp/hphp /usr/bin/hphp
ln -fs ${CMAKE_PREFIX_PATH}/hiphop-php/src/hhvm/hhvm /usr/bin/hhvm

## Success
echo "HipHop-PHP is now installed!"

## Fetch Version
hphp -v
hhvm -v

exit 0
