# ldap_nis

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with ldap_nis](#setup)
    * [Installing the gem](#Installing the gems)
    * [Providing LDAP credentials](#Providing LDAP credentials)
    * [Beginning with ldap_nis](#beginning-with-ldap_nis)
1. [Usage - Configuration options and additional functionality](#usage)
1. [References](#reference)
  * [Types](#Types)
    * [ldap_entity](#ldap_entity) - a native type for creating arbitrary ldap entries
    * [ldap_nis::domain](#ldap_nis::domain) - domain object
    * [ldap_nis::host](#ldap_nis::host) - host entry
    * [ldap_nis::user](#ldap_nis::user) - user entry
    * [ldap_nis::group](#ldap_nis::group) - group entry
    * [ldap_nis::netgroup](#ldap_nis::netgroup) - netgroup entry
    * [ldap_nis::automountmap](#ldap_nis::automountmap) - automount map (auto_master, auto_direct, etc.)
    * [ldap_nis::automountentry](#ldap_nis::automountentry) - automount map mountpoint entry
    * [ldap_nis::mailgroup](#ldap_nis::mailgroup) - mail group aliases
    * [ldap_nis::network](#ldap_nis::network) - network entry
    * [ldap_nis::service](#ldap_nis::service) - ip services
  * [Functions](#Functions)
    * [domain2dn](#domain2dn)
    * [sha1digest](#sha1digest)
1. [Limitations](#limitations)
1. [Developmente](#development)

## Description

This module centers around an LDAP type/provider that allows creation of arbitrary ldap entries using the ruby net-ldap gem.  Layered on top of this is a series of defined types that support creation of NIS style entries for user, group, hosts, and more.

The use of the net-ldap gem means that any host which realizes LDAP entries must have that gem installed.  The provider detects the presence of this gem and will fail if undetected.  The gem is ldap implementation neutral and should work against any ldap compliant instance.

## Setup

### Installing the gem

Make sure the hosts creating ldap entries have access to the net-ldap gem.  This may be accomplished using the package gem provider.

    package { 'net-ldap':
      ensure   => present,
      provider => puppet_gem,
    }

### Providing LDAP credentials
While you may provide credentials for each resource definition it is easier to specify this information globally using hiera.

    ldap_nis::server::base:     'dc=yourdomain,dc=net'
    ldap_nis::server::host:     'localhost'
    ldap_nis::server::username: 'cn=admin,dc=yourdomain,dc=net'
    ldap_nis::server::password: 'plaintext'
    ldap_nis::server::port:     636
    ldap_nis::server::ssl:      true
    ldap_nis::server::ssl_cacert: '/etc/ssl/certs/myca-bundle.crt'
    ldap_nis::server::verify:   true


* `base` - root of the NIS object which holds the containers for the various NIS entries (ou=people, ou=hosts, etc.)
* `host` - hostname or ip of ldap server
* `username` - account with write privileges for the `base` structure
* `password` - associated password
* `port` - either the unencrypted port (389) or the ldaps:/// encrypted port (636) when using SSL
* `ssl` - whether or not to use ldaps:/// SSL encryption
* `ssl_cacert` - Path to a PEM file with your trusted CAs.
* `verify` - whether or not to verify the ssl certificate and/or server DNS entry

The `ssl` option only supports the ldaps:// interface on an ecrypted port (usually 636).  When using SSL you may choose to disable certificate validation by setting `verify` to false.  This disables all verification and opens up the possibility for man-in-the-middle attacks.  By default, the puppet net-ldap gem uses a private CA bundle to authenticate certificates.  This makes it impossible to simply add your certificate to the OS trust store.  The `ssl_cacert` allows you to specify your own list CA trusted certificates.

### Beginning with ldap_nis

The first object to create is the NIS domain object.  The following example is for a generic domain used my "yourdomian.net" and assumes the credentials listed above.

    $dns_name = 'yourdomain.net'
    $base     = domain2dn($dns_name)
    $domain   = 'yourdomain'

    ldap_nis::domain { $dns_name:
      ensure => present,
      dc     => $domain,
    }

This will create the NIS domain object and by default will create supporting containers (ou=people, ou=group, etc.).  You may now create additional entries for users, groups, netgroups, etc.

## Usage
### Attribute Mutability

It may be desirable to allow certain attributes to change after creation.  Attributes like passwords may be changed by the user or as a result of hashing during creation.  Marking an attribute mutable by including it in the `mutable` array causes the attribute to accept its specified value at creation but to otherwise be ignored.

## Reference

### Types
* [ldap_entity](#ldap_entity) - a native type for creating arbitrary ldap entries
* [ldap_nis::domain](#ldap_nis-domain) - domain object
* [ldap_nis::host](#ldap_nis::host) - host entry
* [ldap_nis::user](#ldap_nis::user) - user entry
* [ldap_nis::group](#ldap_nis::group) - group entry
* [ldap_nis::netgroup](#ldap_nis::netgroup) - netgroup entry
* [ldap_nis::automountmap](#ldap_nis::automountmap) - automount map (auto_master, auto_direct, etc.)
* [ldap_nis::automountentry](#ldap_nis::automountentry) - automount map mountpoint entry
* [ldap_nis::mailgroup](#ldap_nis::mailgroup) - mail group aliases
* [ldap_nis::network](#ldap_nis::network) - network entry
* [ldap_nis::service](#ldap_nis::service) - ip services

#### ldap_entity
Allows creation of raw ldap entries.  Here is an example of manually creating a domain entry for yourdomain.net:

    ldap_entity { 'dc=yourdomain,dc=net':
      ensure     => present,
      base       => 'dc=yourdomain,dc=net',
      host       => 'localhost',
      port       => '636'
      ssl        => true,
      verify     => true,
      username   => 'cn=admin,dc=yourdomain,dc=net',
      password   => 'plaintext',
      attributes => {
        objectclass  => [ 'top', 'domain', 'nisdomainobject' ],
        dc           => 'yourdomain',
        nisdomain    => 'yourdomain.net'
      }
    }

Then you would need to create each of the containers within the domain with entries like:

    ldap_entity { 'ou=people,dc=yourdomain,dc=net':
      ensure     => present,
      base       => 'dc=yourdomain,dc=net',
      host       => 'localhost',
      port       => '636'
      ssl        => true,
      verify     => true,
      username   => 'cn=admin,dc=yourdomain,dc=net',
      password   => 'plaintext',
      attributes => {
        objectclass  => [ 'top', 'organizationalunit' ],
        ou           => 'people',
      }
    }

#### ldap_nis::domain
DN format: `"${base}"`

Here is the entry to create the domain using the provided defined type:

    ldap_nis::domain { 'yourdomain.net':
      ensure => present,
      dc     => 'yourdomain',
    }

The provider creates the containers by default unless you specify:

  create_containers => false,

#### ldap_nis::host
DN format: `"cn=${name}+ipHostNumber=${iphostnumber},ou=hosts,${base}"`

    ldap_nis::host { 'myhost.yourdomain.net'
      ensure       => present,
      iphostnumber => '1.1.1.1',
    }

| Parameter       | Default | Description                  |
| :-------------- | :-----: | :--------------------------- |
| `name`          | `title` | The name should be the fully qualified domain name.  This is the primary name for the host and is what is returned for reverse ip lookups. Defaults to the titlebar value if not specified   |
|  `iphostnumber` |         | IP address of host            |
|  aliases        | []      | An array of hostname aliases |

#### ldap_nis::user
DN format: `"uid=${name},ou=${container},${base}"`

    ldap_nis::user { 'myuser':
      ensure => present,
      uidnumber     => '1000',
      gidnumber     => '1000',
      sn            => 'myuser',
      homedirectory => '/home/myuser',
    }

| Parameter       | Default | Description                  |
| :-------------- | :-----: | :--------------------------- |
| `name`          | `title` | Username for entry           |
| `uidnumber`     |         | UserID number                |
| `gidnumber`     |         | GroupID number               |
| `sn`            |         | Surname of the user          |
| `homedirectory` |         | Users home directory         |
| loginshell      | undef   | Path to the loginshell       |
| container       | people  | OU container for account.  Allows placing users into different containers.  By default **people** and **application** containers are provided. |
| employeenumber  | undef    | Employee number of the user |
| userpassword    | undef    | Password for the user       |
| gecos           | undef    | GECOS information for the user |

#### ldap_nis::group
DN format: `"cn=${name},ou=group,${base}"`

    ldap_nis::group { 'mygroup':
      gidnumber => 1000,
    }

| Parameter       | Default | Description                  |
| :-------------- | :-----: | :--------------------------- |
| `name`          | `title` | Group Name                   |
| `gidnumber`     |         | GroupID number               |
| gr_password     | undef   | Group Password               |
| members         | undef   | Array of member UIDs         |
| description     | undef   | Description of group         |

#### ldap_nis::netgroup
DN format: `"cn=${name},ou=netgroup,${base}`

    ldap_nis::netgroup { 'mynetgroup':
      ensure => present,
    }

| Parameter       | Default | Description                  |
| :-------------- | :-----: | :--------------------------- |
| `name`          | `title` | Name of netgroup             |
| members         | []      | Array of netgroup members which may include individual netgroup triples or the names of other netgroups |

#### ldap_nis::automountmap

DN format: `"automountmapname=${name},${base}"`

    ldap_nis::automountmap { 'my_map':
      ensure => present,
    }

| Parameter       | Default | Description                  |
| :-------------- | :-----: | :--------------------------- |
| `name`          | `title` | Name of Automount Map        |
| description     | undef   | Description for Automount Map |

#### ldap_nis::automountentry
DN format: `"automountkey=${name},automountmapname=${mapname},${base}"`

    ldap_nis::automountentry { '/my/applications':
      mapname => 'my_map',
      info    => '-rw,bg,retry=2,soft,vers=3 myappserver:/myapps',
    }

| Parameter       | Default | Description                  |
| :-------------- | :-----: | :--------------------------- |
| `name`          | `title` | Automount entry mountpoint directory|
| `mapname`       |         | Name of map for this entry   |
| `info`          |         | Mount information for entry  |
| description     | undef   | Description for this entry   |

#### ldap_nis::mailgroup
DN format: `"mail=${name},ou=aliases,${base}""`

    ldap_nis::mailgroup { 'mymailgroup':
      ensure => present,
      members => [ 'user1', 'user2' ],
    }

| Parameter       | Default | Description                  |
| :-------------- | :-----: | :--------------------------- |
| `name`          |         | Mail group name              |
| `members`       |         | Array of mailgroup member addresses |

#### ldap_nis::network
DN format: `"ipnetworknumber=${name},ou=networks,${base}"`

    ldap_nis::networks { '1.0.0.0':
      label       => 'RED1',
      description => 'The Big Red 1',
    }

| Parameter       | Default | Description                  |
| :-------------- | :-----: | :--------------------------- |
| `name`          | `title` | Network portion of address space |
| `label`         |         | Short name for network       |
| ipnetmask       | undef   | Netmask for network (CIDR Addressing) |
| description     | undef   | Description of network       |

#### ldap_nis::service
DN format: `"cn=${name}+ipserviceprotocol=${ipserviceprotocol},ou=services,${base}`

    ldap_nis { 'mytcpport':
      ipservicerport    => '1000',
      ipserviceprotocol => 'tcp',
    }

| Parameter       | Default | Description                  |
| :-------------- | :-----: | :--------------------------- |
| `name`          | `title` | IP Port Name                 |
| `ipserviceport` |         | IP Port Number               |
| `ipserviceprotocol` |     | IP Protocol                  |
| description     | undef   | Description of IP Port       |

## Functions

#### Hash a password with SHA-1 Digest

```ruby
sha1digest("secret") # => "{SHA}5en6G6MezRroT3XKqkdPOmY/BfQ="
```

#### Convert a dotted domain to a DN format suitable for LDAP

```ruby
domain2dn("yourdomain.net") # => "dc=yourdomain,dc=net"
```


## Limitations

The first iteration of this module assumes the use of an ldap server with solaris schema extensions installed.  These extensions for OpenLDAP are available in the files directory.  It is my intention to support other configurations in the future and time and energy permits.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc.

This module began life as an extension to the datacentred/ldap module and morphed into a general purpose ldap entry management tool.  The ldap_entity type/provider is a lightly overhauled version of the ldap_entry type found in that module.

### Running tests

<!--- TODO - need to work on tests --->
This project contains tests uses [rspec-puppet](http://rspec-puppet.com/) to verify functionality. Test coverage is minimal at best at this point, but should improve with time.

Quickstart:

    gem install bundler
    bundle install
    bundle exec rake spec
