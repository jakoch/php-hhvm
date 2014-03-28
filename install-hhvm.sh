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


    # install apt-fast to speed up later dependency installation
    sudo add-apt-repository -y ppa:apt-fast/stable
    # for fetching libboost
    sudo add-apt-repository -y ppa:boost-latest/ppa
    sudo add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ quantal main universe"
        sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com AED4B06F473041FA
        sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 8B48AD6246925553
    sudo add-apt-repository -y "deb http://ftp.debian.org/debian experimental main"
    sudo apt-get -y update

    sudo apt-get -y install apt-fast

    sudo apt-get -y install git-core cmake g++ cpp gcc make libboost1.54-all-dev libmysqlclient-dev \
      libxml2-dev libmcrypt-dev libicu-dev openssl build-essential binutils-dev \
      libcap-dev libgd2-xpm-dev zlib1g-dev libtbb-dev libonig-dev libpcre3-dev \
      autoconf libtool libcurl4-openssl-dev wget memcached \
      libreadline-dev libncurses5-dev libbz2-dev \
      libc-client2007e-dev php5-mcrypt php5-imagick libgoogle-perftools-dev \
      libcloog-ppl0 libelf-dev libdwarf-dev libunwind7-dev libnotify-dev subversion \
      g++-4.7 gcc-4.7

    sudo apt-get -t experimental -f install libmemcachedutil2 libmemcached10 libmemcached-dev libc6

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
    pmake && pmake install
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
    pmake && pmake install
    cd ..

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

# jemalloc
function install_jemalloc() {
    echo
    echo -e "\e[1;33mInstalling jemalloc...\e[0m"
    echo

    wget --quiet http://www.canonware.com/download/jemalloc/jemalloc-3.5.1.tar.bz2
    tar xjvf jemalloc-3.5.1.tar.bz2 > /dev/null
    cd jemalloc-3.5.1
    ./configure --prefix=$CMAKE_PREFIX_PATH > /dev/null
    pmake && pmake install
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
    pmake && pmake install
    cd ..

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

function get_hhvm_source() {
    echo
    echo -e "\e[1;33mFetching HHVM...\e[0m"
    echo

    mkdir dev
    cd dev
    git clone --quiet --depth 1 git://github.com/facebook/hhvm.git
    export CMAKE_PREFIX_PATH=`pwd`
    cd hhvm
    git submodule init
    cd ..

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

function build() {
    echo
    echo -e "\e[1;33mBuilding HHVM...\e[0m"
    echo

    cd hhvm
    git submodule update
    cmake .
    pmake

    # where am i, why is it so dark
    ls & cd .. & ls

    echo -e "\e[1;32m> Done.\e[0m"
    echo
}

function install() {
    install_dependencies
    # hhvm source fetched before libraries, because of patches
    get_hhvm_source
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
${CMAKE_PREFIX_PATH}/hphp/hhvm/hhvm --version
./hphp/hhvm/hhvm --version
hhvm --version

## Display Help
${CMAKE_PREFIX_PATH}/hphp/hhvm/hhvm --help

## Getting started with Hello-World
echo -e "<?php\n echo 'Hello Hiphop-PHP!' . PHP_EOL;\n?>" > hello.php

echo
echo -e "\e[1;32m *** Example of executing specified file *** \e[0m"
echo

${CMAKE_PREFIX_PATH}/hphp/hhvm/hhvm hello.php

echo
echo -e "\e[1;32m *** Example of linting specified file *** \e[0m"
echo

${CMAKE_PREFIX_PATH}/hphp/hhvm/hhvm --lint hello.php

echo
echo -e "\e[1;32m *** Static Analyzer Report ! *** \e[0m"
echo

${CMAKE_PREFIX_PATH}/hphp/hhvm/hhvm --hphp -t analyze --input-list example.php --output-dir . --log 2 > report.log
cat report.log

echo
echo -e "\e[1;32m *** Example of parsing the specified file and dumping the AST ! *** \e[0m"
echo

# uhm? > The 'parse' command line option is not supported
#${CMAKE_PREFIX_PATH}/hiphop-php/hphp/hhvm/hhvm --file hello.php --parse

echo
echo -e "\e[1;32m *** Example of the Server Mode ! *** \e[0m"
echo

${CMAKE_PREFIX_PATH}/hphp/hhvm/hhvm -m server -p 8123 ./
curl http://127.0.0.1:8123/hello.php

echo
echo -e "\e[1;32m *** Run HHVM TestSuite! *** \e[0m"
echo

# Run HHVM TestSuite
${CMAKE_PREFIX_PATH}/hphp/hhvm/hhvm hphp/test/run all

exit 0
