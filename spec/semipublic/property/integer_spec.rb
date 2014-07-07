require 'spec_helper'

describe Ardm::Property::Integer do
  let(:name)          { :age }
  let(:type)          { described_class }
  let(:options)       { {} }
  let(:value)         { 1 }
  let(:other_value)   { 2 }
  let(:invalid_value) { '1' }
  let(:model) { Blog::Article }
  let(:property) { type.new(model, name, options) }

  it_should_behave_like 'A semipublic Property'

  describe '#typecast' do
    it 'returns same value if an integer' do
      value = 24
      expect(property.typecast(value)).to equal(value)
    end

    it 'returns integer representation of a zero string integer' do
      expect(property.typecast('0')).to eql(0)
    end

    it 'returns integer representation of a positive string integer' do
      expect(property.typecast('24')).to eql(24)
    end

    it 'returns integer representation of a negative string integer' do
      expect(property.typecast('-24')).to eql(-24)
    end

    it 'returns integer representation of a zero string float' do
      expect(property.typecast('0.0')).to eql(0)
    end

    it 'returns integer representation of a positive string float' do
      expect(property.typecast('24.35')).to eql(24)
    end

    it 'returns integer representation of a negative string float' do
      expect(property.typecast('-24.35')).to eql(-24)
    end

    it 'returns integer representation of a zero string float, with no leading digits' do
      expect(property.typecast('.0')).to eql(0)
    end

    it 'returns integer representation of a positive string float, with no leading digits' do
      expect(property.typecast('.41')).to eql(0)
    end

    it 'returns integer representation of a zero float' do
      expect(property.typecast(0.0)).to eql(0)
    end

    it 'returns integer representation of a positive float' do
      expect(property.typecast(24.35)).to eql(24)
    end

    it 'returns integer representation of a negative float' do
      expect(property.typecast(-24.35)).to eql(-24)
    end

    it 'returns integer representation of a zero decimal' do
      expect(property.typecast(BigDecimal('0.0'))).to eql(0)
    end

    it 'returns integer representation of a positive decimal' do
      expect(property.typecast(BigDecimal('24.35'))).to eql(24)
    end

    it 'returns integer representation of a negative decimal' do
      expect(property.typecast(BigDecimal('-24.35'))).to eql(-24)
    end

    [ Object.new, true, '0.', '-.0', 'string' ].each do |value|
      it "does not typecast non-numeric value #{value.inspect}" do
        expect(property.typecast(value)).to equal(value)
      end
    end
  end
end
