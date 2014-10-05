#!/bin/bash

apt-get -q update
apt-get -q upgrade
echo 'Installing puppetmaster.'
apt-get -q -y install puppetmaster
touch /etc/puppet/manifests/site.pp
