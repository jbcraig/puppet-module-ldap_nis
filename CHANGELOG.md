##  Release 0.1.0 - 2017-04-15
#### Summary
Initial release with support for Solaris NIS Schema

Features
- Native Type/Provider ldap_entity supports arbitrary ldap entries
- Defined Types for Core NIS entries
  - ldap_nis::domain
  - ldap_nis::host
  - ldap_nis::user
  - ldap_nis::group
  - ldap_nis::netgroup
  - ldap_nis::automountmap
  - ldap_nis::automountentry
  - ldap_nis::mailgroup
  - ldap_nis::network
- Parser Functions
  - domain2dn
  - sha1digest
