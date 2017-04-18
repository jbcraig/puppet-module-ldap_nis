# ldap_nis::user - creates a nis style user account
# objectclass ( 1.3.6.1.1.1.2.0 NAME 'posixAccount'
#   DESC 'Abstraction of an account with POSIX attributes'
#   SUP top AUXILIARY
#   MUST ( cn $ uid $ uidNumber $ gidNumber $ homeDirectory )
#   MAY ( userPassword $ loginShell $ gecos $ description ) )
#
# objectclass ( 1.3.6.1.1.1.2.1 NAME 'shadowAccount'
#   DESC 'Additional attributes for shadow passwords'
#   SUP top AUXILIARY
#   MUST uid
#   MAY ( userPassword $ shadowLastChange $ shadowMin $
#         shadowMax $ shadowWarning $ shadowInactive $
#         shadowExpire $ shadowFlag $ description ) )
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

  $base       = lookup('ldap_nis::server::base'),
  $host       = lookup('ldap_nis::server::host'),
  $username   = lookup('ldap_nis::server::username'),
  $password   = lookup('ldap_nis::server::password'),
  $port       = lookup('ldap_nis::server::port'),
  $ssl        = lookup('ldap_nis::server::ssl'),
  $ssl_cacert = lookup('ldap_nis::server::ssl_cacert'),
  $verify     = lookup('ldap_nis::server::verify'),
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

  $dn         = "uid=${name},ou=${container},${base}"
  $attributes = $required_attributes + $_employeenumber + $_userpassword +
    $_gecos + $_loginshell

  ldap_entity { $dn:
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

  # Order resource create/destruction properly
  case $ensure {
    'present': { Ldap_nis::Domain[$base]->Ldap_entity[$dn] }
    'absent':  { Ldap_entity[$dn]->Ldap_nis::Domain[$base] }
    default :  { fail("ensure must be present or absent, not ${ensure}") }
  }

}
