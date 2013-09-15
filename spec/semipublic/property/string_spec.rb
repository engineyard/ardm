require 'spec_helper'

describe Ardm::Property::String do
  let(:name)          { :name }
  let(:type)          { described_class }
  let(:options)       { {} }
  let(:value)         { 'value' }
  let(:other_value)   { 'return value' }
  let(:invalid_value) { 1 }
  let(:model) { Blog::Article }
  let(:property) { type.new(model, name, options) }

  it_should_behave_like 'A semipublic Property'
end
