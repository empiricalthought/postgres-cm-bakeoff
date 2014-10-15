#!/bin/sh

SSH_OPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
SSH_HOST=postgres@primary.vagrant.dev
PG_DATA=/var/lib/postgresql/9.3/main

# create remote backup
ssh $SSH_OPTS $SSH_HOST pg_basebackup -D /tmp/pg_backup --format=t --gzip --xlog

# retrieve remote backup
scp $SSH_OPTS $SSH_HOST:/tmp/pg_backup/base.tar.gz /tmp/base.tar.gz
service postgresql stop
rm -rf $PG_DATA
mkdir $PG_DATA
chmod 0700 $PG_DATA
tar -C $PG_DATA -x -f /tmp/base.tar.gz
cat <<EOF > $PG_DATA/recovery.conf
# Note that recovery.conf must be in $PGDATA directory.
# It should NOT be located in the same directory as postgresql.conf

# Specifies whether to start the server as a standby. In streaming replication,
# this parameter must to be set to on.
standby_mode          = 'on'

# Specifies a connection string which is used for the standby server to connect
# with the primary.
primary_conninfo      = 'host=primary.vagrant.dev port=5432 user=rep password=vader'

# Specifies a trigger file whose presence should cause streaming replication to
# end (i.e., failover).
trigger_file = '/var/lib/postgresql/trigger'

# Specifies a command to load archive segments from the WAL archive. If
# wal_keep_segments is a high enough number to retain the WAL segments
# required for the standby server, this may not be necessary. But
# a large workload can cause segments to be recycled before the standby
# is fully synchronized, requiring you to start again from a new base backup.
restore_command = 'cp /data/wal_archive/%f "%p"'
EOF
echo "hot_standby = 'on'" >> /etc/postgresql/9.3/main/postgresql.conf
service postgresql start

