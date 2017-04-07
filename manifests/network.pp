# ldap_nis::network
##
# from: openldap nis.schema
# objectclass ( 1.3.6.1.1.1.2.7 NAME 'ipNetwork'
#   DESC 'Abstraction of an IP network'
#   SUP top STRUCTURAL
#   MUST ( cn $ ipNetworkNumber )
#   MAY ( ipNetmaskNumber $ l $ description $ manager ) )
define ldap_nis::network (
  # required
  ## $ipnetworknumber = name/title
  $label,

  $ensure      = present,
  $objectclass = lookup('ldap_nis::networks::objectclass'),

  # optional
  $ipnetmask     = undef,
  $description   = undef,
  $mutable       = [],

  # ldap connectivity
  $base       = lookup('ldap_nis::server::base',       String),
  $host       = lookup('ldap_nis::server::host',       String),
  $username   = lookup('ldap_nis::server::username',   String),
  $password   = lookup('ldap_nis::server::password',   String),
  $port       = lookup('ldap_nis::server::port',       Data),
  $ssl        = lookup('ldap_nis::server::ssl',        Boolean),
  $ssl_cacert = lookup('ldap_nis::server::ssl_cacert', String),
  $verify     = lookup('ldap_nis::server::verify',     Boolean),
) {

  $required_attributes = {
    objectclass     => $objectclass,
    ipnetworknumber => $name,
    cn              => $label,
  }

  if $ipnetmask {
    $_ipnetmask = { 'ipnetmasknumber' => $ipnetmask }
  }
  else {
    $_ipnetmask = {}
  }

  if $description {
    $_description = { 'description' => $description }
  }
  else {
    $_description = {}
  }


  $attributes = $required_attributes + $_ipnetmask + $_description

  ldap_entity { "ipnetworknumber=${name},ou=networks,${base}":
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
    attributes => $attributes,
  }
}
