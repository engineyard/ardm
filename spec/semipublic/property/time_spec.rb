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

        result.should be_kind_of(Time)
        result.year.should  eql(2006)
        result.month.should eql(11)
        result.day.should   eql(23)
        result.hour.should  eql(12)
        result.min.should   eql(0)
        result.sec.should   eql(0)
      end
    end

    describe 'and value is a string' do
      it 'parses the string' do
        result = property.typecast('22:24')
        result.hour.should eql(22)
        result.min.should eql(24)
      end
    end

    it 'does not typecast non-time values' do
      property.typecast('not-time').should eql('not-time')
    end
  end
end
