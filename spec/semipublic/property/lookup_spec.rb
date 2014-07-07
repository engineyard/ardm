require 'spec_helper'

module LookupFoo
  class OtherProperty < Ardm::Property::String; end
end

describe Ardm::Property::Lookup do
  before do
    @klass = Class.new(Ardm::Record) do
      self.table_name = "articles"
    end
  end

  it 'should provide access to Property classes' do
    expect(@klass::Serial).to eq(Ardm::Property::Serial)
  end

  it 'should provide access to Property classes from outside of the Property namespace' do
    expect(@klass::OtherProperty).to eq(LookupFoo::OtherProperty)
  end

  it 'should not provide access to unknown Property classes' do
    expect {
      @klass::Bla
    }.to raise_error(NameError)
  end
end
