require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'net/ldap' if Puppet.features.net_ldap?

Puppet::Type.newtype(:ldap_entity) do
  @doc = 'Type to manage LDAP entities'

  ensurable

  newparam(:name) do
    desc 'Name of LDAP entity i.e. cn=foo,ou=bar,dc=sampel,dc=com'
    isnamevar
  end

  newparam(:host) do
    desc 'Host Address (FQDN or IP) of the LDAP server'
  end

  newparam(:base) do
    desc 'LDAP tree base i.e. dc=foo,dc=co,dc=uk'
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, 'ldap_entity::base is not a string'
      end
    end
  end

  newparam(:port) do
    desc  'Port of the LDAP server (default 389)'
    defaultto 636
    validate do |value|
      unless (1..65535).include?(value.to_i)
        raise ArgumentError, 'ldap_entity::port is not a whole number in the range 1-65535'
      end
    end
  end

  newparam(:username) do
    desc 'Username of admin account on LDAP server'
    defaultto 'admin'
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, 'ldap_entity::username is not a string'
      end
    end
  end

  newparam(:password) do
    desc 'Password of admin account on LDAP server'
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, 'ldap_entity::password is not a string'
      end
    end
  end

  newproperty(:attributes) do
    desc 'LDAP entry attributes as a hash i.e. { :givenName => "Foo",
                                                 :objectClass =>
                                                   ["top", "person", "inetorgPerson"]}'
    validate do |value|
      unless value.is_a? Hash
        raise ArgumentError, 'ldap_entity::attributes is not a hash'
      end

      value.each_pair do |k,v|
        if k[/^[[:upper:]]*$/]
          raise ArgumentError, 'ldap_entity::attributes keys not all lowercase'
        end
        if k == "objectclass"
          raise ArgumentError, 'ldap_entity::attributes - objectclass must be an array' unless v.kind_of?(Array)
          v.each do |entry|
            raise ArgumentError, 'ldap_entity::attributes - objectclass values must be lowercase' if entry[/^[[:upper:]]*$/]
          end
        end
      end
    end

    def insync?(is)
      should.each do |k,v|
        return false unless [is[k]].flatten.sort == [should[k]].flatten.sort
      end
      return true
    end
  end

  newparam(:mutable, :array_matching => :all) do
    desc 'LDAP entry attribute(s) as an array which may be externally modified and therefore unamaged beyond the initial value'
    defaultto []

    validate do |value|
      unless value.is_a? Array
        raise ArgumentError, 'ldap_entity::mutable is not an array'
      end
    end
  end

  newparam(:verify) do
    desc 'Should the LDAP server certificate and host be verified'
    defaultto true
  end

  newparam(:ssl) do
    desc 'Whether the LDAP server uses SSL'
    defaultto true
  end

  newparam(:ssl_cacert) do
    desc 'Path to a CA file used to verify SSL certificates'
    defaultto String.new('')
  end

  # Add autorequire
  autorequire(:ldap_entry) do
    # Strip off the first dn to autorequire the parent
    self[:name].split(",").drop(1).join(",")
  end

end
