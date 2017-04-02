require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'net/ldap' if Puppet.features.net_ldap?
require 'net/ldap/dn' if Puppet.features.net_ldap?

Puppet::Type.type(:ldap_entity).provide(:ldap) do
  confine :feature => :net_ldap

  public

  def attributes=(value)
    value.each do |k, v|
      if @property_hash[:attributes].has_key?(k)
        # skip if current value matches new
        next if [@property_hash[:attributes][k]].flatten.sort == [v].flatten.sort

        # skip if attribute is marked as mutable
        next if [resource[:mutable]].flatten.include? k
        ldap_replace_attribute([resource[:host], resource[:port], resource[:username], resource[:password],
                    [resource[:name], k, v]])
      else
        ldap_add_attribute([resource[:host], resource[:port], resource[:username], resource[:password],
                      [resource[:name], k, v]])
      end
    end
    @property_hash[:attributes]=value
  end
  #
  def attributes
    @property_hash[:attributes]
  end

  def exists?
    status, result = ldap_search([resource[:host], resource[:port],
      resource[:username], resource[:password], {
        :base => resource[:name], :scope => Net::LDAP::SearchScope_BaseObject,
        :attributes => attributes_keys(resource[:attributes])
      }])
    if status == LDAP_NIS::NoSuchObject
      Puppet.debug("LDAP exists? expect #{resource[:ensure]==:absent ? false :
            true}; #{resource[:name]} is false")
      return false
    elsif status == LDAP_NIS::Success
      if Net::LDAP::DN.new(result.dn).to_a.map(&:downcase) ==
                Net::LDAP::DN.new(resource[:name]).to_a.map(&:downcase)

        # We have a match, store attributes
        entry = Hash.new
        result.each_attribute do |attribute, value|
          next if attribute == :dn

          # Force ojectclass values to lowercase
          value.map!(&:downcase) if attribute == :objectclass

          # Store values
          entry[attribute.to_s.downcase]=value
        end
        @property_hash[:attributes] = entry
        Puppet.debug("LDAP exists? expect #{resource[:ensure]==:absent ? false : true} #{resource[:name]} is true")
        return true
      else
        Puppet.debug("LDAP exists? expect #{resource[:ensure]==:absent ? false : true} #{resource[:name]} is false")
        return false
      end
    else
      raise "LDAP Error #{status}: #{result}. Check server log for more info."
    end
  end

  def destroy
    Puppet.info("LDAP destroy #{resource[:name]}")
    resource[:ensure] = :absent
    status, message = ldap_remove([resource[:host], resource[:port], resource[:username], resource[:password],
          {:dn => resource[:name]}])
    raise "LDAP Error #{status}: #{message}. Check server log for more info." unless status == LDAP_NIS::Success
  end

  def create
    Puppet.info("LDAP create #{resource[:name]}")
    status, message = ldap_add([resource[:host], resource[:port], resource[:username], resource[:password],
                        {:dn => resource[:name], :attributes => resource[:attributes]}])
    raise "LDAP Error #{status}: #{message}. Check server log for more info." unless status == LDAP_NIS::Success
  end

  private

  def ldap(args)
    host, port, admin_user, admin_password, _ = args
    ldap = Net::LDAP.new(
      { :host => host,
        :port => port,
        :auth => {
          :method => :simple,
          :username => admin_user,
          :password => admin_password}}.
          merge(resource[:ssl] ? {:encryption => {:method => :simple_tls}.
            merge(resource[:verify] ?
              {:tls_options =>  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS} :
              {:tls_options => {:verify_mode => OpenSSL::SSL::VERIFY_NONE}} )} : {}))
    Puppet.debug("Connecting to LDAP server ldaps://#{host}:#{port}")
    ldap.bind
    ldap
  end

  def attributes_keys(attrs)
    return [] unless resource[:attributes]
    attrs.keys.map(&:to_s)
  end

  def ldap_search(args)
    ldap = ldap(args)
    Puppet.debug("LDAP Search: #{params(args).inspect}")
    args = params(args)
    results = ldap.search(args)
    code, message = return_code_and_message(ldap)

    if(code == LDAP_NIS::Success)
      [code, results.first]
    else
      [code, message]
    end
  end

  def ldap_add(args)
    ldap = ldap(args)
    Puppet.info("LDAP Add: #{params(args).inspect}")
    ldap.add(params(args))
    return_code_and_message(ldap)
  end

  def ldap_remove(args)
    ldap = ldap(args)
    Puppet.info("LDAP Remove: #{params(args).inspect}")
    ldap.delete(params(args))
    return_code_and_message(ldap)
  end

  def ldap_add_attribute(args)
    ldap = ldap(args)
    Puppet.info("LDAP Add Attribute: #{params(args).inspect}")
    ldap.add_attribute(*params(args))
    return_code_and_message(ldap)
  end

  def ldap_replace_attribute(args)
    ldap = ldap(args)
    Puppet.info("LDAP Replace Attribute: #{params(args).inspect}")
    ldap.replace_attribute(*params(args))
    return_code_and_message(ldap)
  end

  def params(args)
    args[4]
  end

  def return_code_and_message(ldap)
    result = ldap.get_operation_result
    return result.code, LDAP_NIS.lookup_error(result.code)
  end

  # For more, see http://www.zytrax.com/books/ldap/ch12/
  module LDAP_NIS
    Success                      = 0
    OperationsError              = 1
    ProtocolError                = 2
    TimeLimitExceeded            = 3
    SizeLimitExceeded            = 4
    CompareFalse                 = 5
    CompareTrue                  = 6
    StrongAuthNotSupported       = 7
    StrongAuthRequired           = 8
    OnlyPartialResultsReturned   = 9
    LdapReferral                 = 10
    AdminLimitExceeded           = 11
    UnavailableCriticalExtension = 12
    ConfidentialityRequired      = 13
    SaslBindInProgress           = 14
    NoSuchAttribute              = 16
    UndefinedAttributeType       = 17
    InappropriateMatching        = 18
    ConstraintViolation          = 19
    AttributeOrValueExists       = 20
    InvalidSyntax                = 21
    NoSuchObject                 = 32
    AliasProblem                 = 33
    InvalidDNSyntax              = 34
    ObjectIsLeaf                 = 35
    AliasDereferenceProblem      = 36
    InappropriateAuthentication  = 48
    InvalidCredentials           = 49
    InsufficientAccessRights     = 50
    Busy                         = 51
    Unavailable                  = 52
    UnwillingToPerform           = 53
    LoopDetected                 = 54
    NamingViolation              = 64
    ObjectClassViolation         = 65
    NotAllowedOnNonLeaf          = 66
    NotAllowedOnRDN              = 67
    EntryAlreadyExists           = 68
    NoObjectClassModifications   = 69
    ResultsTooLarge              = 70
    AffectsMultipleDSAs          = 71
    UnknownError                 = 80

    def self.lookup_error(code)
      Hash[constants.collect{|c| [
        LDAP_NIS.const_get(c), c.to_s.gsub(/([A-Z])/, ' \1').strip
      ]}][code]
    end
  end
end
