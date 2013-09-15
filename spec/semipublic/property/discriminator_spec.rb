require 'spec_helper'

describe Ardm::Property::Discriminator do
  before :all do
    Object.send(:remove_const, :Foo) if defined?(Foo)
    Object.send(:remove_const, :Bar) if defined?(Bar)

    class ::Foo; end
    class ::Bar; end
  end

  let(:name)          { :type }
  let(:type)          { described_class }
  let(:options)       { {} }
  let(:value)         { Foo }
  let(:other_value)   { Bar }
  let(:invalid_value) { 1 }
  let(:model) { Blog::Article }
  let(:property) { type.new(model, name, options) }

  it_should_behave_like 'A semipublic Property'
end
