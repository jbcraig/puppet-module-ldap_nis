# ldap_nis::network
# olcObjectClasses: (
#   1.3.6.1.1.1.2.7
#   NAME 'ipNetwork'
#   DESC 'Abstraction of a network. The distinguished value of the cn attribute denotes the networks canonical name'
#   SUP top
#   STRUCTURAL
#   MUST ipNetworkNumber
#   MAY ( cn $ ipNetmaskNumber $ l $ description $ manager )
#   )
define ldap_nis::network (
  # required
  ## $ipnetworknumber = name/title

  $ensure      = present,
  $objectclass = lookup('ldap_nis::networks::objectclass'),

  # optional
  $label         = undef,
  $description   = undef,
  $mutable       = [],

  # ldap connectivity
  $base     = lookup('ldap_nis::server::base',     String),
  $host     = lookup('ldap_nis::server::host',     String),
  $username = lookup('ldap_nis::server::username', String),
  $password = lookup('ldap_nis::server::password', String),
  $port     = lookup('ldap_nis::server::port',     Data),
  $ssl      = lookup('ldap_nis::server::ssl',      Boolean),
  $verify   = lookup('ldap_nis::server::verify',   Boolean),
) {

  $required_attributes = {
    objectclass     => $objectclass,
    ipnetworknumber => $name,
  }

  if $description {
    $_description = { 'description' => $description }
  }
  else {
    $_description = {}
  }

  if $label {
    $_label = { 'cn' => $label }
  }
  else {
    $_label = {}
  }

  $attributes = $required_attributes + $_description + $_label

  ldap_entity { "ipnetworknumber=${name},ou=networks,${base}":
    ensure     => $ensure,
    base       => $base,
    host       => $host,
    username   => $username,
    password   => $password,
    port       => $port,
    ssl        => $ssl,
    verify     => $verify,
    mutable    => $mutable,
    attributes => $attributes,
  }
}
