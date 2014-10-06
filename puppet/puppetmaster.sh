#!/bin/sh

if [ ! -f /etc/puppet/manifests/site.pp ]
then
    apt-get -q update
    apt-get -q upgrade
    echo 'Installing puppet master'
    apt-get -q -y install puppetmaster
    echo "autosign = true" >> /etc/puppet/puppet.conf
    echo "*.vagrant.dev" >> /etc/puppet/autosign.conf
    puppet module install puppetlabs-postgresql
fi
cp /tmp/site.pp /etc/puppet/manifests/site.pp
