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
    owner => 'postgres'
  }

  postgresql::server::role { 'rep':
    password_hash => postgresql_password('rep', $rep_password);
  }

  class { 'postgresql::server::contrib':
    package_ensure => 'present',
  }

}

node 'primary.vagrant.dev' {
  include postgresql_node

  postgresql::server::pg_hba_rule { 'allow replication user to connect':
    description => 'Permit streaming replication for access from standby',
    type => 'host',
    database => 'replication',
    user => 'rep',
    address => 'standby.vagrant.dev',
    auth_method => 'md5'
  }

  postgresql::server::config_entry {
    'wal_level': value => 'hot_standby';
    'archive_mode': value => 'on';
  }
}

node 'standby.vagrant.dev' {
  include postgresql_node
}
