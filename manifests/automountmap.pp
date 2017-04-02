# ldap_nis::_automountmap - creates a nis style automountMap
# olcObjectClasses: (
#   1.3.6.1.1.1.2.16
#   NAME 'automountMap'
#   SUP top
#   STRUCTURAL
#   MUST ( automountMapName )
#   MAY description
#   )
define ldap_nis::automountmap (
  # $name = automountMapName
  $ensure      = present,
  $objectclass = lookup('ldap_nis::automountmap::objectclass', Array),
  $base        = lookup('ldap_nis::server::base'),
  $host        = lookup('ldap_nis::server::host'),
  $username    = lookup('ldap_nis::server::username'),
  $password    = lookup('ldap_nis::server::password'),
  $port        = lookup('ldap_nis::server::port'),
  $ssl         = lookup('ldap_nis::server::ssl'),
  $verify      = lookup('ldap_nis::server::verify'),
) {

  ldap_entity { "automountmapname=${name},${base}":
    ensure     => $ensure,
    base       => $base,
    host       => $host,
    username   => $username,
    password   => $password,
    port       => $port,
    ssl        => $ssl,
    verify     => $verify,
    attributes => {
      objectclass      => $objectclass,
      automountmapname => $name,
    },
  }

}
