# ldap_nis::_automountmap - creates a nis style automountMap
# objectclass ( 1.3.6.1.1.1.2.16
#  NAME 'automountMap'
#  SUP top STRUCTURAL
#  MUST ( automountMapName )
#  MAY description )
define ldap_nis::automountmap (
  $ensure           = present,
  $automountmapname = $name,
  $description      = undef,
  $mutable          = [],
  $objectclass      = lookup('ldap_nis::automountmap::objectclass', Array),
  $base             = lookup('ldap_nis::server::base'),
  $host             = lookup('ldap_nis::server::host'),
  $username         = lookup('ldap_nis::server::username'),
  $password         = lookup('ldap_nis::server::password'),
  $port             = lookup('ldap_nis::server::port'),
  $ssl              = lookup('ldap_nis::server::ssl'),
  $ssl_cacert       = lookup('ldap_nis::server::ssl_cacert'),
  $verify           = lookup('ldap_nis::server::verify'),
) {

  $required_attributes = {
    objectclass      => $objectclass,
    automountmapname => $automountmapname,
  }

  if $description {
    $_description = { 'description' => $description }
  }
  else {
    $_description = {}
  }

  $attributes = $required_attributes + $_description

  ldap_entity { "automountmapname=${name},${base}":
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

}
