node 'primary.vagrant.dev' {
  package {
    ['tmux',
     'postgresql']:
  }
}

node 'standby.vagrant.dev' {
}
