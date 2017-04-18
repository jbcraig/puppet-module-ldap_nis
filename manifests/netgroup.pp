# ldap_nis::netgroup
# objectclass ( 1.3.6.1.1.1.2.8 NAME 'nisNetgroup'
#   DESC 'Abstraction of a netgroup'
#   SUP top STRUCTURAL
#   MUST cn
#   MAY ( nisNetgroupTriple $ memberNisNetgroup $ description ) )
define ldap_nis::netgroup (
  # required
  ## cn = name/title

  $ensure = present,

  # optional
  Array $members = [],
  $description   = undef,
  Array $mutable = [],
  $objectclass   = lookup('ldap_nis::netgroup::objectclass'),

  # ldap connectivity
  $base       = lookup('ldap_nis::server::base',       String),
  $host       = lookup('ldap_nis::server::host',       String),
  $username   = lookup('ldap_nis::server::username',   String),
  $password   = lookup('ldap_nis::server::password',   String),
  $port       = lookup('ldap_nis::server::port',       Data),
  $ssl        = lookup('ldap_nis::server::ssl',        Boolean),
  $ssl_cacert = lookup('ldap_nis::server::ssl_cacert', String),
  $verify     = lookup('ldap_nis::server::verify',     Boolean)
) {

  $required_attributes = {
    objectclass => $objectclass,
    cn          => $name,
  }

  # seprate entries into triples and included groups
  $_members  = {
    'nisnetgrouptriple' => $members.filter |$entry| {
      $entry =~ /^(.*,.*,.*)$/ },
    'membernisnetgroup' => $members.filter |$entry| {
      $entry !~ /^(.*,.*,.*)$/ },
  }

  $dn         = "cn=${name},ou=netgroup,${base}"
  $attributes = $required_attributes + $_members

  ldap_entity { $dn:
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

  # Order resource create/destruction properly
  case $ensure {
    'present': { Ldap_nis::Domain[$base]->Ldap_entity[$dn] }
    'absent':  { Ldap_entity[$dn]->Ldap_nis::Domain[$base] }
    default :  { fail("ensure must be present or absent, not ${ensure}") }
  }

}
