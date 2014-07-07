require 'spec_helper'

describe Ardm::Property::Float do
  let(:name)          { :rating }
  let(:type)          { described_class }
  let(:options)       { {} }
  let(:value)         { 0.1 }
  let(:other_value)   { 0.2 }
  let(:invalid_value) { '1' }
  let(:model) { Blog::Article }
  let(:property) { type.new(model, name, options) }

  it_should_behave_like 'A semipublic Property'

  describe '#typecast' do
    it 'returns same value if a float' do
      value = 24.0
      expect(property.typecast(value)).to equal(value)
    end

    it 'returns float representation of a zero string integer' do
      expect(property.typecast('0')).to eql(0.0)
    end

    it 'returns float representation of a positive string integer' do
      expect(property.typecast('24')).to eql(24.0)
    end

    it 'returns float representation of a negative string integer' do
      expect(property.typecast('-24')).to eql(-24.0)
    end

    it 'returns float representation of a zero string float' do
      expect(property.typecast('0.0')).to eql(0.0)
    end

    it 'returns float representation of a positive string float' do
      expect(property.typecast('24.35')).to eql(24.35)
    end

    it 'returns float representation of a negative string float' do
      expect(property.typecast('-24.35')).to eql(-24.35)
    end

    it 'returns float representation of a zero string float, with no leading digits' do
      expect(property.typecast('.0')).to eql(0.0)
    end

    it 'returns float representation of a positive string float, with no leading digits' do
      expect(property.typecast('.41')).to eql(0.41)
    end

    it 'returns float representation of a zero integer' do
      expect(property.typecast(0)).to eql(0.0)
    end

    it 'returns float representation of a positive integer' do
      expect(property.typecast(24)).to eql(24.0)
    end

    it 'returns float representation of a negative integer' do
      expect(property.typecast(-24)).to eql(-24.0)
    end

    it 'returns float representation of a zero decimal' do
      expect(property.typecast(BigDecimal('0.0'))).to eql(0.0)
    end

    it 'returns float representation of a positive decimal' do
      expect(property.typecast(BigDecimal('24.35'))).to eql(24.35)
    end

    it 'returns float representation of a negative decimal' do
      expect(property.typecast(BigDecimal('-24.35'))).to eql(-24.35)
    end

    [ Object.new, true, '0.', '-.0', 'string' ].each do |value|
      it "does not typecast non-numeric value #{value.inspect}" do
        expect(property.typecast(value)).to equal(value)
      end
    end
  end
end
