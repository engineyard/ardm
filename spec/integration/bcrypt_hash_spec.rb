require 'spec_helper'

try_spec do

  require './spec/fixtures/person'

  describe Ardm::Fixtures::Person do
    before do
      @resource  = Ardm::Fixtures::Person.create!(:password => 'Ardm R0cks!')
      Ardm::Fixtures::Person.create!(:password => 'password1')

      @people = Ardm::Fixtures::Person.all
      @resource.reload
    end

    it 'persists the password on initial save' do
      expect(@resource.password).to       eq('Ardm R0cks!')
      expect(@people.last.password).to eq('password1')
    end

    it 'recalculates password hash on attribute update' do
      @resource.attribute_set(:password, 'bcryptic obscure')
      @resource.save

      @resource.reload
      expect(@resource.password).to     eq('bcryptic obscure')
      expect(@resource.password).not_to eq('Ardm R0cks!')
    end

    it 'does not change password value on reload' do
      resource = @people.last
      original = resource.password.to_s
      resource.reload
      expect(resource.password.to_s).to eq(original)
    end

    it 'uses cost of BCrypt::Engine::DEFAULT_COST' do
      expect(@resource.password.cost).to eq(BCrypt::Engine::DEFAULT_COST)
    end

    it 'allows Bcrypt::Password#hash to be an Integer' do
      expect(@resource.password.hash).to be_kind_of(Integer)
    end
  end
end
