require 'spec_helper'

describe Ardm::Property::Time do
  let(:name)          { :deleted_at }
  let(:type)          { described_class }
  let(:options)       { {} }
  let(:value)         { Time.now }
  let(:other_value)   { Time.now + 15 }
  let(:invalid_value) { 1 }
  let(:model) { Blog::Article }
  let(:property) { type.new(model, name, options) }

  it_should_behave_like 'A semipublic Property'

  describe '#typecast' do
    describe 'and value given as a hash with keys like :year, :month, etc' do
      it 'builds a Time instance from hash values' do
        result = property.typecast(
          :year  => '2006',
          :month => '11',
          :day   => '23',
          :hour  => '12',
          :min   => '0',
          :sec   => '0'
        )

        expect(result).to be_kind_of(Time)
        expect(result.year).to  eql(2006)
        expect(result.month).to eql(11)
        expect(result.day).to   eql(23)
        expect(result.hour).to  eql(12)
        expect(result.min).to   eql(0)
        expect(result.sec).to   eql(0)
      end
    end

    describe 'and value is a string' do
      it 'parses the string' do
        result = property.typecast('22:24')
        expect(result.hour).to eql(22)
        expect(result.min).to eql(24)
      end
    end

    it 'does not typecast non-time values' do
      expect(property.typecast('not-time')).to eql('not-time')
    end
  end
end
