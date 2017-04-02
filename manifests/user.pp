# ldap_nis::user - creates a nis style user account
# olcObjectClasses: (
#   1.3.6.1.1.1.2.15
#   NAME 'nisDomainObject'
#   DESC 'Associates a NIS domain with a naming context'
#   SUP top
#   AUXILIARY
#   MUST nisDomain
#   )
define ldap_nis::user (
  # required attributes
  $uidnumber,
  $gidnumber,
  $sn,
  $homedirectory,
  $ensure      = present,
  $objectclass = lookup('ldap_nis::user::objectclass', Array),
  $uid         = $name,
  $cn          = $name,
  $loginshell  = undef,
  $container   = 'people',

  # optional attributes
  $employeenumber = undef,
  $userpassword   = undef,
  $gecos          = undef,

  $mutable        = undef,

  $base     = lookup('ldap_nis::server::base'),
  $host     = lookup('ldap_nis::server::host'),
  $username = lookup('ldap_nis::server::username'),
  $password = lookup('ldap_nis::server::password'),
  $port     = lookup('ldap_nis::server::port'),
  $ssl      = lookup('ldap_nis::server::ssl'),
  $verify   = lookup('ldap_nis::server::verify'),
) {

  $required_attributes = {
    objectclass   => $objectclass,
    uid           => $uid,
    uidnumber     => $uidnumber,
    cn            => $container,
    sn            => $sn,
    gidnumber     => $gidnumber,
    homedirectory => $homedirectory,
  }

  if $employeenumber {
    $_employeenumber = { 'employeenumber' => $employeenumber }
  }
  else {
    $_employeenumber = {}
  }

  if $userpassword {
    $_userpassword = { 'userpassword' => $userpassword }
  }
  else {
    $_userpassword = {}
  }

  if $gecos {
    $_gecos = { 'gecos' => $gecos }
  }
  else {
    $_gecos = {}
  }

  if $loginshell {
    $_loginshell = { 'loginshell' => $loginshell }
  }
  else {
    $_loginshell = {}
  }

  # $attributes = merge($required_attributes, $_employeenumber, $_userpassword,
  #   $_gecos, $_loginshell)
  $attributes = $required_attributes + $_employeenumber + $_userpassword +
    $_gecos + $_loginshell

  ldap_entity { "uid=${name},ou=${container},${base}":
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
