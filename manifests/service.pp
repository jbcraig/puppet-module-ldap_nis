# ldap_nis::service
# objectclass ( 1.3.6.1.1.1.2.3 NAME 'ipService'
#   DESC 'Abstraction an Internet Protocol service'
#   SUP top STRUCTURAL
#   MUST ( cn $ ipServicePort $ ipServiceProtocol )
#   MAY ( description ) )
define ldap_nis::service (
  # Required
  ## portname = name/title
  String $ipserviceport,
  String $ipserviceprotocol,

  # Optional
  $description = undef,

  # class
  $ensure = present,
  Array $mutable = [],
  Array $objectclass = lookup('ldap_nis::service::objectclass', Array),

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
    objectclass       => $objectclass,
    cn                => $name,
    ipserviceport     => $ipserviceport,
    ipserviceprotocol => $ipserviceprotocol,
  }

  if $description {
    $_description = { 'description' => $description }
  }
  else {
    $_description = {}
  }

  $attributes = $required_attributes + $_description

  ldap_entity { "cn=${name}+ipserviceprotocol=${ipserviceprotocol},ou=services,${base}":
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
