require 'spec_helper'

describe Ardm::Property::Decimal do
  before do
    @name          = :rate
    @type          = described_class
    @options       = { :precision => 5, :scale => 2 }
    @load_as     = BigDecimal
    @value         = BigDecimal('1.0')
    @other_value   = BigDecimal('2.0')
    @invalid_value = true
  end

  it_should_behave_like 'A public Property'

  describe '.options' do
    subject { described_class.options }

    it { is_expected.to be_kind_of(Hash) }

    it { is_expected.to eql(:load_as => @load_as, :dump_as => @load_as, :coercion_method => :to_decimal, :precision => 10, :scale => 0) }
  end
end
