The intent of this repository is to compare different configuration
management systems inside Vagrant.

The configuration under test is two virtual machines, one hosting a
primary PostgreSQL server and one hosting a hot-standby server
configured to be a replica of the primary.  Creation of this
configuration must be turnkey automation, going from no VM to a
working pair of PostgreSQL nodes.

