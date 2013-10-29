require 'spec_helper'

describe Ardm::Property::Text do
  let(:name)          { :title }
  let(:type)          { described_class }
  let(:options)       { {} }
  let(:value)         { 'value' }
  let(:other_value)   { 'return value' }
  let(:invalid_value) { 1 }
  let(:model) { Blog::Article }
  let(:property) { type.new(model, name, options) }

  it_should_behave_like 'A semipublic Property'

  describe '#load' do
    before do
      @value = 'value'
    end

    subject { property.load(@value) }

    let(:property) { type.new(model, name) }

    it 'should delegate to #type.load' do
      return_value = 'return value'
      property.should_receive(:load).with(@value).and_return(return_value)
      subject.should == return_value
    end
  end
end
