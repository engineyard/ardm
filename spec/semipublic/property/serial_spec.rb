require 'spec_helper'

describe Ardm::Property::Serial do
  let(:name)          { :id }
  let(:type)          { described_class }
  let(:options)       { {} }
  let(:value)         { 1 }
  let(:other_value)   { 2 }
  let(:invalid_value) { 'foo' }
  let(:model) { Blog::Article }
  let(:property) { type.new(model, name, options) }

  it_should_behave_like 'A semipublic Property'
end
