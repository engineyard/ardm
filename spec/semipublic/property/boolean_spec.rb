require 'spec_helper'

describe Ardm::Property::Boolean do
  let(:name)          { :active }
  let(:type)          { described_class }
  let(:options)       { {:set => [true, false]} }
  let(:value)         { true }
  let(:other_value)   { false }
  let(:invalid_value) { 1 }
  let(:model) { Blog::Article }
  let(:property) { type.new(model, name, options) }

  it_should_behave_like 'A semipublic Property'

  describe '#valid?' do
    [ true, false ].each do |value|
      it "returns true when value is #{value.inspect}" do
        expect(property.valid?(value)).to be(true)
      end
    end

    [ 'true', 'TRUE', '1', 1, 't', 'T', 'false', 'FALSE', '0', 0, 'f', 'F' ].each do |value|
      it "returns false for #{value.inspect}" do
        expect(property.valid?(value)).to be(false)
      end
    end
  end

  describe '#typecast' do
    [ true, 'true', 'TRUE', '1', 1, 't', 'T' ].each do |value|
      it "returns true when value is #{value.inspect}" do
        expect(property.typecast(value)).to be(true)
      end
    end

    [ false, 'false', 'FALSE', '0', 0, 'f', 'F' ].each do |value|
      it "returns false when value is #{value.inspect}" do
        expect(property.typecast(value)).to be(false)
      end
    end

    [ 'string', 2, 1.0, BigDecimal('1.0'), DateTime.now, Time.now, Date.today, Class, Object.new, ].each do |value|
      it "does not typecast value #{value.inspect}" do
        expect(property.typecast(value)).to equal(value)
      end
    end
  end
end
