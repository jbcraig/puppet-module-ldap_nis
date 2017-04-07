# ldap_nis::automountentry - creates a nis style automountMap
# objectclass ( 1.3.6.1.1.1.2.17
#  NAME 'automount'
#  SUP top STRUCTURAL
#  DESC 'Automount information'
#  MUST ( automountKey $ automountInformation )
#  MAY description )
define ldap_nis::automountentry (
  $mapname,
  $info,
  $automountkey = $name,
  $description  = undef,
  $ensure       = present,
  $mutable      = [],
  $objectclass  = lookup('ldap_nis::automountkey::objectclass', Array),
  $base         = lookup('ldap_nis::server::base'),
  $host         = lookup('ldap_nis::server::host'),
  $username     = lookup('ldap_nis::server::username'),
  $password     = lookup('ldap_nis::server::password'),
  $port         = lookup('ldap_nis::server::port'),
  $ssl          = lookup('ldap_nis::server::ssl'),
  $ssl_cacert   = lookup('ldap_nis::server::ssl_cacert'),
  $verify       = lookup('ldap_nis::server::verify'),
) {

  $required_attributes = {
    objectclass          => $objectclass,
    automountkey         => $automountkey,
    automountinformation => $info,
  }

  if $description {
    $_description = { 'description' => $description }
  }
  else {
    $_description = {}
  }

  $attributes = $required_attributes + $_description

  ldap_entity { "automountkey=${name},automountmapname=${mapname},${base}":
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
    require    => Ldap_nis::Automountmap[$mapname],
  }

}
