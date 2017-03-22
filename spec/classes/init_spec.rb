require 'spec_helper'
describe 'ldap_nis' do
  context 'with default values for all parameters' do
    it { should contain_class('ldap_nis') }
  end
end
