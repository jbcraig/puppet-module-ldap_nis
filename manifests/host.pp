# ldap_nis::server::nis_host - creates a nis style host
define ldap_nis::host (
  $iphostnumber,
  $ensure      = present,
  $aliases     = [],
  $objectclass = lookup('ldap_nis::host::objectclass', Array),
  $base        = lookup('ldap_nis::server::base'),
  $host        = lookup('ldap_nis::server::host'),
  $username    = lookup('ldap_nis::server::username'),
  $password    = lookup('ldap_nis::server::password'),
  $port        = lookup('ldap_nis::server::port'),
  $ssl         = lookup('ldap_nis::server::ssl'),
  $verify      = lookup('ldap_nis::server::verify'),
) {

  ldap_entity { "cn=${name}+ipHostNumber=${iphostnumber},ou=hosts,${base}":
    ensure     => $ensure,
    base       => $base,
    host       => $host,
    username   => $username,
    password   => $password,
    port       => $port,
    ssl        => $ssl,
    verify     => $verify,
    attributes => {
      objectclass  => $objectclass,
      cn           => flatten([$name, $aliases]),
      iphostnumber => $iphostnumber,
    },
  }

}
