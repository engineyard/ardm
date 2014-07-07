require 'spec_helper'

describe Ardm::Property::String do
  before do
    @name          = :name
    @type          = described_class
    @load_as     = String
    @value         = 'value'
    @other_value   = 'return value'
    @invalid_value = 1
  end

  it_should_behave_like 'A public Property'

  describe '.options' do
    subject { described_class.options }

    it { is_expected.to be_kind_of(Hash) }

    it { is_expected.to eql(:load_as => @load_as, :dump_as => @load_as, :coercion_method => :to_string, :length => 50) }
  end
end
