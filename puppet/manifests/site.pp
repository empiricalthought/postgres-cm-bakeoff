class postgresql_node {

  $postgres_password = 'palpatine'
  $rep_password = 'vader'
  $app_password = 'yoda'

  class { 'apt':
    always_apt_update   => true,
  }

  file { '/etc/default/locale':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    content => "LANG=en_US.UTF-8\n",
  } ->
  class { 'postgresql::globals':
    version             => '9.3',
    manage_package_repo => true,
    encoding            => 'UTF8',
    locale              => 'en_US.utf8',
  } ->
  class { 'postgresql::server':
    listen_addresses           => '*',
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    postgres_password          => $postgres_password,
  } ->
  file { '/var/lib/postgresql/.ssh':
    source => 'file:///home/vagrant/.ssh',
    recurse => true,
    owner => 'postgres',
    mode => 0700,
  }

  postgresql::server::role { 'rep':
    password_hash => postgresql_password('rep', $rep_password),
    replication => true,
  }

  class { 'postgresql::server::contrib':
    package_ensure => 'present',
  }

}

class postgresql_primary inherits postgresql_node {

  postgresql::server::pg_hba_rule { 'allow replication user to connect':
    description => 'Permit streaming replication for access from standby',
    type => 'host',
    database => 'replication',
    user => 'rep',
    address => 'samenet',
    auth_method => 'md5'
  }

  postgresql::server::pg_hba_rule { 'allow replication user to connect locally':
    description => 'Permit base backups to be created',
    type => 'local',
    database => 'replication',
    user => 'postgres',
    auth_method => 'trust'
  }

  postgresql::server::config_entry {
    'wal_level': value => 'hot_standby';
    'wal_keep_segments': value => '1000';
    'archive_mode': value => 'off';
    'max_wal_senders': value => '5';
  }

}

class postgresql_standby inherits postgresql_node {

  file { '/data':
    ensure => 'directory',
    owner => 'postgres',
    mode => 0700,
    require => [ Class['postgresql::server'] ],
  } ->
  file { '/data/wal_archive':
    ensure => 'directory',
    owner => 'postgres',
    mode => 0700,
  } ->
  file { '/etc/init.d/pg_wal_receiver':
    ensure => 'present',
    owner  => 'root',
    source => 'file:///vagrant/pg_wal_receiver'
  } ->
  file { '/var/lib/postgresql/start_replica.sh':
    ensure => 'present',
    owner  => 'postgres',
    mode   => 0700,
    source => 'file:///vagrant/start_replica.sh',
  } ->
  file { '/var/lib/postgresql/.pgpass':
    ensure  => 'present',
    owner   => 'postgres',
    mode    => 0700,
    content => "primary.vagrant.dev:5432:*:rep:$rep_password"
  } ->
  service { 'pg_wal_receiver':
    name => 'pg_wal_receiver',
    ensure => 'running',
  } ->
  exec { 'start_replica':
    command => "/var/lib/postgresql/start_replica.sh",
    user => "postgres",
    require => [ File['/var/lib/postgresql/.ssh' ] ],
  }
  
}

node 'primary.vagrant.dev' {
  include postgresql_primary
}

node 'standby.vagrant.dev' {
  include postgresql_standby
}
