require 'spec_helper'

describe Ardm::Property::Date do
  let(:name)          { :created_on }
  let(:type)          { described_class }
  let(:options)       { {} }
  let(:value)         { Date.today }
  let(:other_value)   { Date.today + 1 }
  let(:invalid_value) { 1 }
  let(:model) { Blog::Article }
  let(:property) { type.new(model, name, options) }

  it_should_behave_like 'A semipublic Property'

  describe '#typecast' do
    describe 'and value given as a hash with keys like :year, :month, etc' do
      it 'builds a Date instance from hash values' do
        result = property.typecast(
          :year  => '2007',
          :month => '3',
          :day   => '25'
        )

        result.should be_kind_of(Date)
        result.year.should eql(2007)
        result.month.should eql(3)
        result.day.should eql(25)
      end
    end

    describe 'and value is a string' do
      it 'parses the string' do
        result = property.typecast('Dec 20th, 2006')
        result.month.should == 12
        result.day.should == 20
        result.year.should == 2006
      end
    end

    it 'does not typecast non-date values' do
      property.typecast('not-date').should eql('not-date')
    end
  end
end
