# ldap_nis::mailgroup - creates a nis style mail aliases
# ( 2.16.840.1.113730.3.2.4
#   NAME 'mailGroup'
#   SUP top
#   STRUCTURAL
#   MUST mail
#   MAY ( cn $ mailAlternateAddress $ mailHost $ mailRequireAuth $
#    mgrpAddHeader $ mgrpAllowedBroadcaster $ mgrpAllowedDomain $
#    mgrpApprovePassword $ mgrpBroadcasterModeration $ mgrpDeliverTo $
#    mgrpErrorsTo $ mgrpModerator $ mgrpMsgMaxSize $
#    mgrpMsgRejectAction $ mgrpMsgRejectText $ mgrpNoMatchAddrs $
#    mgrpRemoveHeader $ mgrpRFC822MailMember )
# )
define ldap_nis::mailgroup (
  # $name = groupname,
  $members,
  $ensure      = present,
  $objectclass = lookup('ldap_nis::mailgroup::objectclass', Array),
  $base        = lookup('ldap_nis::server::base'),
  $host        = lookup('ldap_nis::server::host'),
  $username    = lookup('ldap_nis::server::username'),
  $password    = lookup('ldap_nis::server::password'),
  $port        = lookup('ldap_nis::server::port'),
  $ssl         = lookup('ldap_nis::server::ssl'),
  $verify      = lookup('ldap_nis::server::base'),
) {

  ldap_entity { "mail=${name},ou=aliases,${base}":
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
      mail                 => $name,
      mgrprfc822mailmember => $members,
    },
  }

}
