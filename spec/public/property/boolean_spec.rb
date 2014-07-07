require 'spec_helper'
require './spec/fixtures/tshirt'

describe Ardm::Property::Boolean do
  before do
    @name          = :active
    @type          = described_class
    @load_as     = TrueClass
    @value         = true
    @other_value   = false
    @invalid_value = 1
  end

  it_should_behave_like 'A public Property'

  describe '.options' do
    subject { described_class.options }

    it { is_expected.to be_kind_of(Hash) }

    it { is_expected.to eql(:load_as => @load_as, :dump_as => @load_as, :coercion_method => :to_boolean) }
  end

  describe "default" do
    it "should set has_picture to the default (booleans are specifically weird in rails because presence validation fails for false)" do
      tshirt = Ardm::Fixtures::TShirt.create!
      expect(tshirt).not_to have_picture
    end
  end
end
