The intent of this repository is to compare different configuration
management systems inside Vagrant.

The configuration under test is two virtual machines, one hosting a
primary PostgreSQL server and one hosting a hot-standby server
configured to be a replica of the primary.  Creation of this
configuration must be turnkey automation, going from no VM to a
working pair of PostgreSQL nodes.

The first try will be with Puppet since it's most relevant to me now;
the next try will be Ansible.  Then Chef and CFEngine to round it out
if I have time.

I will use the server-client configuration model for systems where it
is applicable, since the intent is to evaluate the CM tool with
respect to my use case and personal tastes and concerns.  If my goal
was to get a working VM configuration in Vagrant, I would likely use
the simpler versions of those systems.
