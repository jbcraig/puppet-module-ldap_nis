# ldap_nis::group
##
# from: openldap nis.schema
# objectclass ( 1.3.6.1.1.1.2.2 NAME 'posixGroup'
#   DESC 'Abstraction of a group of accounts'
#   SUP top STRUCTURAL
#   MUST ( cn $ gidNumber )
#   MAY ( userPassword $ memberUid $ description ) )
define ldap_nis::group (
  # required
  ## cn = name/title
  $gidnumber,

  $ensure = present,

  # optional
  $gr_password = undef,
  $members     = undef,
  $description = undef,
  $mutable     = [],
  $objectclass = lookup('ldap_nis::group::objectclass'),

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
    objectclass => $objectclass,
    cn          => $name,
    gidnumber   => $gidnumber,
  }

  if $gr_password {
    $_gr_password = { 'userpassword' => $gr_password }
  }
  else {
    $_gr_password = {}
  }

  if $members {
    $_members = { 'memberuid' => $members }
  }
  else {
    $_members = {}
  }

  if $description {
    $_description = { 'description' => $description }
  }
  else {
    $_description = {}
  }

  $attributes = $required_attributes + $_gr_password + $_members +
        $_description

  ldap_entity { "cn=${name},ou=group,${base}":
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
