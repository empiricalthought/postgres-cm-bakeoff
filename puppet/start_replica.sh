#!/bin/sh

SSH_OPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
SSH_HOST=postgres@primary.vagrant.dev

# create remote backup
ssh $SSH_OPTS $SSH_HOST pg_basebackup -D /tmp/pg_backup --format=t --gzip --xlog

# retrieve remote backup
scp $SSH_OPTS $SSH_HOST:/tmp/pg_backup/base.tar.gz /tmp/base.tar.gz
