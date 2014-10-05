node 'primary.vagrant.dev' {
  class { 
    'postgresql::server': 
  }
}

node 'standby.vagrant.dev' {
  class {
    'postgresql::server':
  }
}
