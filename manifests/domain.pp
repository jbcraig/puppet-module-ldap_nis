# ldap_nis::server::nis_domain - creates a nis style automountMap
# objectclass ( 1.3.6.1.1.1.2.15
#   NAME 'nisDomainObject'
#   SUP top AUXILIARY
#   DESC 'Associates a NIS domain with a naming context'
#   MUST nisDomain )

#
# Title == @nisDomain String [nisDomainObect] name of the NIS domain
# @dc String [domain] domain component
# @objectclass Array lists the classes used in creating the ldap entity, Classes must be lowercase
# @create_containers Boolean wether or not to create supporting containers (ie People, Hosts, ...)

define ldap_nis::domain (
  $nis_domainname,
  $ensure            = present,
  $mutable           = [],
  $base              = lookup('ldap_nis::server::base'),
  $host              = lookup('ldap_nis::server::host'),
  $username          = lookup('ldap_nis::server::username'),
  $password          = lookup('ldap_nis::server::password'),
  $port              = lookup('ldap_nis::server::port'),
  $ssl               = lookup('ldap_nis::server::ssl'),
  $verify            = lookup('ldap_nis::server::verify'),
  $ssl_cacert        = lookup('ldap_nis::server::ssl_cacert'),
  $objectclass       = lookup('ldap_nis::domain::objectclass', Array),
  $create_containers = lookup('ldap_nis::domain::create_containers', Boolean),
) {

  if $name != $base {
    fail("name and base must match")
  }

  ldap_entity { $name:
    ensure     => $ensure,
    base       => $base,
    host       => $host,
    username   => $username,
    password   => $password,
    port       => $port,
    ssl        => $ssl,
    verify     => $verify,
    ssl_cacert => $ssl_cacert,
    mutable    => $mutable,
    attributes => {
      objectclass => $objectclass,
      dc          => $nis_domainname,
      nisdomain   => $name,
    },
  }

  if $create_containers {
    $containers = lookup('ldap_nis::domain::containers', Hash)

    $ldap_defaults = {
      ensure     => $ensure,
      base       => $base,
      host       => $host,
      username   => $username,
      password   => $password,
      port       => $port,
      ssl        => $ssl,
      verify     => $verify,
      ssl_cacert => $ssl_cacert,
      before     => $ensure ? {
        'present' => undef,
        'absent'  => Ldap_entity[$name],
      },
    }

    $containers.each |String $container, Hash $definition| {
      create_resources('ldap_entity', {
        $definition[title] => {
          attributes => $definition[attributes] }}, $ldap_defaults)
    }
  }

}
