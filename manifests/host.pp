# ldap_nis::server::nis_host - creates a nis style host
##
# from: openldap nis.schema
# objectclass ( 1.3.6.1.1.1.2.6 NAME 'ipHost'
#   DESC 'Abstraction of a host, an IP device'
#   SUP top AUXILIARY
#   MUST ( cn $ ipHostNumber )
#   MAY ( l $ description $ manager ) )
define ldap_nis::host (
  $iphostnumber,
  $ensure      = present,
  $aliases     = [],
  $mutable     = [],
  $objectclass = lookup('ldap_nis::host::objectclass', Array),
  $base        = lookup('ldap_nis::server::base'),
  $host        = lookup('ldap_nis::server::host'),
  $username    = lookup('ldap_nis::server::username'),
  $password    = lookup('ldap_nis::server::password'),
  $port        = lookup('ldap_nis::server::port'),
  $ssl         = lookup('ldap_nis::server::ssl'),
  $ssl_cacert  = lookup('ldap_nis::server::ssl_cacert'),
  $verify      = lookup('ldap_nis::server::verify'),
) {

  $required_attributes = {
    objectclass => $objectclass,
    iphostnumber => $iphostnumber,
  }

  if $aliases {
    $_aliases = { 'cn' => flatten([$name, $aliases]) }
  }
  else {
    $_aliases = { 'cn' => [$name] }
  }

  $dn         = "cn=${name}+ipHostNumber=${iphostnumber},ou=hosts,${base}"
  $attributes = $required_attributes + $_aliases

  ldap_entity { $dn:
    ensure     => $ensure,
    base       => $base,
    host       => $host,
    username   => $username,
    password   => $password,
    port       => $port,
    ssl        => $ssl,
    ssl_cacert => $ssl_cacert,
    verify     => $verify,
    mutable    => $mutable,
    attributes => $attributes,
  }

  # Order resource create/destruction properly
  case $ensure {
    'present': { Ldap_nis::Domain[$base]->Ldap_entity[$dn] }
    'absent':  { Ldap_entity[$dn]->Ldap_nis::Domain[$base] }
    default :  { fail("ensure must be present or absent, not ${ensure}") }
  }

}
