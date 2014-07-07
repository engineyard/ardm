require 'spec_helper'

describe Ardm::Property::Class do
  before do
    Object.send(:remove_const, :Foo) if defined?(Foo)
    Object.send(:remove_const, :Bar) if defined?(Bar)

    class ::Foo; end
    class ::Bar; end

    @name          = :type
    @type          = described_class
    @load_as     = Class
    @value         = Foo
    @other_value   = Bar
    @invalid_value = 1
  end

  it_should_behave_like 'A public Property'

  describe '.options' do
    subject { described_class.options }

    it { is_expected.to be_kind_of(Hash) }

    it { is_expected.to eql(:load_as => @load_as, :dump_as => @load_as, :coercion_method => :to_constant) }
  end
end
