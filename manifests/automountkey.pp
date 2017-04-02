# ldap_nis::automountkeyyy - creates a nis style automountMap
# olcObjectClasses: (
#   1.3.6.1.1.1.2.17
#   NAME 'automount'
#   DESC 'Automount information'
#   SUP top
#   STRUCTURAL
#   MUST ( automountKey $ automountInformation )
#   MAY description
#   )
define ldap_nis::automountkey (
  # $name = automountKey
  $mapname,
  $info,
  $ensure   = present,
  $base     = hiera('ldap_nis::server::base'),
  $host     = hiera('ldap_nis::server::host'),
  $username = hiera('ldap_nis::server::username'),
  $password = hiera('ldap_nis::server::password'),
  $port     = hiera('ldap_nis::server::port'),
  $ssl      = hiera('ldap_nis::server::ssl'),
  $verify   = hiera('ldap_nis::server::verify'),
) {

  $objectclass = ['top', 'automount']

  ldap_entity { "automountkey=${name},automountmapname=${mapname},${base}":
    ensure     => $ensure,
    base       => $base,
    host       => $host,
    username   => $username,
    password   => $password,
    port       => $port,
    ssl        => $ssl,
    verify     => $verify,
    attributes => {
      objectclass          => $objectclass,
      automountkey         => $name,
      automountinformation => $info,
    },
    #require     => Ldap_entry["automountMapName=${mapname},${base}"],
    require    => Ldap_nis::Automountmap[$mapname],
  }

}
