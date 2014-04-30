set -x
if [ "$TRAVIS_PHP_VERSION" = 'hhvm' ]; then
export DEBIAN_FRONTEND=noninteractive
    sudo apt-get purge -q -y hhvm
    sudo add-apt-repository -y ppa:mapnik/boost
    sudo apt-get update -q -y
    sudo apt-get install -q -y hhvm-nightly
    hhvm --version
    php --version

    curl -sS https://getcomposer.org/installer > composer-installer.php
    hhvm composer-installer.php
fi