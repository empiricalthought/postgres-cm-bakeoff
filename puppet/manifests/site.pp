class postgresql_node {

  $postgres_password = 'password'

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
  }

  class { 'postgresql::server::contrib':
    package_ensure => 'present',
  }
}

node 'primary.vagrant.dev' {
  include postgresql_node
}

node 'standby.vagrant.dev' {
  include postgresql_node
}
