# ldap::entry - specify the defaults for entries
class ldap::entry (
  $base,
  $host,
  $port,
  $username,
  $password,
  $ssl         = false,
  $self_signed = false,
) {
  # Validate Input
  echo { "entry::port = ${port}": }

}
