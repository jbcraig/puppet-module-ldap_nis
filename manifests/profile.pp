# ldap_nis::profile
# objectclass ( 1.3.6.1.4.1.11.1.3.1.2.4
#   NAME 'DUAConfigProfile'
#   DESC 'Abstraction of a base configuration for a DUA'
#   STRUCTURAL
#   MUST cn
#   MAY ( defaultServerList $ preferredServerList $ defaultSearchBase $
#     defaultSearchScope $ searchTimeLimit $ bindTimeLimit $ credentialLevel $
#     authenticationMethod $ followReferrals $ serviceSearchDescriptor $
#     serviceCredentialLevel $ serviceAuthenticationMethod $ objectclassMap $
#     attributeMap $ profileTTL ) )
define ldap_nis::profile (
  # required attributes
  # cn = name/title

  $ensure      = present,
  $objectclass = lookup('ldap_nis::profile::objectclass'),
  $mutable     = [],

  # optional
  $defaultserverlist           = undef,
  $preferredserverlist         = undef,
  $defaultsearchbase           = undef,
  $defaultsearchscope          = undef,
  $searchtimelimit             = undef,
  $bindtimelimit               = undef,
  $credentiallevel             = undef,
  $authenticationmethod        = undef,
  $followreferrals             = undef,
  $servicesearchdescriptor     = undef,
  $serviceauthenticationmethod = undef,
  $objectclassmap              = undef,
  $attributemap                = undef,
  $profilettl                  = undef,

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
  }

  if $defaultserverlist {
    $_defaultserverlist = { 'defaultserverlist' => $defaultserverlist }
  }
  else {
    $_defaultserverlist = {}
  }

  if $preferredserverlist {
    $_preferredserverlist = { 'preferredserverlist' => $preferredserverlist }
  }
  else {
    $_preferredserverlist = {}
  }

  if $defaultsearchbase {
    $_defaultsearchbase = { 'defaultsearchbase' => $defaultsearchbase }
  }
  else {
    $_defaultsearchbase = {}
  }

  if $defaultsearchscope {
    $_defaultsearchscope = { 'defaultsearchscope' => $defaultsearchscope }
  }
  else {
    $_defaultsearchscope = {}
  }

  if $searchtimelimit {
    $_searchtimelimit = { 'searchtimelimit' => $searchtimelimit}
  }
  else {
    $_searchtimelimit = {}
  }

  if $bindtimelimit {
    $_bindtimelimit = { 'bindtimelimit' => $bindtimelimit }
  }
  else {
    $_bindtimelimit = {}
  }

  if $credentiallevel {
    $_credentiallevel = { 'credentiallevel' => $credentiallevel }
  }
  else {
    $_credentiallevel = {}
  }

  if $authenticationmethod {
    $_authenticationmethod = { 'authenticationmethod' => $authenticationmethod}
  }
  else {
    $_authenticationmethod = {}
  }

  if $followreferrals {
    $_followreferrals = { 'followreferrals' => $followreferrals }
  }
  else {
    $_followreferrals = {}
  }

  if $servicesearchdescriptor { # Array
    $_servicesearchdescriptor = { 'servicesearchdescriptor' => $servicesearchdescriptor }
  }
  else {
    $_servicesearchdescriptor = {}
  }

  if $serviceauthenticationmethod {
    $_serviceauthenticationmethod = {
        'serviceauthenticationmethod' => $serviceauthenticationmethod }
  }

  if $objectclassmap { # Array
    $_objectclassmap = { 'objectclassmap' => $objectclassmap }
  }
  else {
    $_objectclassmap = {}
  }

  if $attributemap { # Array
    $_attributemap = { 'attributemap' => $attributemap }
  }
  else {
    $_attributemap = {}
  }

  if $profilettl {
    $_profilettl = { 'profilettl' => $profilettl }
  }
  else {
    $_profilettl = {}
  }

  $attributes = $required_attributes + $_defaultserverlist +
        $_preferredserverlist + $_defaultsearchbase + $_defaultsearchscope +
        $_searchtimelimit + $_bindtimelimit + $_credentiallevel +
        $_authenticationmethod + $_followreferrals +
        $_servicesearchdescriptor + $_serviceauthenticationmethod +
        $_objectclassmap + $_attributemap + $_profilettl

  ldap_entity { "cn=${name},ou=profile,${base}":
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
