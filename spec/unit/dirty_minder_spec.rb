require 'spec_helper'
require 'ardm/property/support/dirty_minder'

describe Ardm::Property::DirtyMinder,'set!' do

  let(:property_class) do
    Class.new(Ardm::Property::Object) do
    end
  end

  let(:model) do
    property_class = self.property_class
    Class.new(Ardm::Record) do
      self.table_name = 'api_users'

      property :id, Ardm::Property::Serial
      property :name, property_class
    end
  end

  let(:resource) { model.new }

  let(:object) { model.properties[:name] }

  subject { object.set!(resource,value) }

  shared_examples_for 'a non hooked value' do
    it 'should not extend value with hook' do
      expect(value).not_to be_kind_of(Ardm::Property::DirtyMinder::Hooker)
    end
  end

  shared_examples_for 'a hooked value' do
    it 'should extend value with hook' do
      expect(value).to be_kind_of(Ardm::Property::DirtyMinder::Hooker)
    end
  end

  before do
    subject
  end

  context 'when setting nil' do
    let(:value) { nil }
    it_should_behave_like 'a non hooked value'
  end

  context 'when setting a String' do
    let(:value) { "The fred" }
    it_should_behave_like 'a non hooked value'
  end

  context 'when setting an Array' do
    let(:value) { ["The fred"] }
    it_should_behave_like 'a hooked value'
  end

  context 'when setting a Hash' do
    let(:value) { {"The" => "fred"} }
    it_should_behave_like 'a hooked value'
  end
end
