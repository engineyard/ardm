require 'spec_helper'

module LookupFoo
  class OtherProperty < Ardm::Property::String; end
end

describe Ardm::Property::Lookup do
  before do
    @klass = Class.new(ActiveRecord::Base) do
      self.table_name = "articles"
    end
  end

  it 'should provide access to Property classes' do
    @klass::Serial.should == Ardm::Property::Serial
  end

  it 'should provide access to Property classes from outside of the Property namespace' do
    @klass::OtherProperty.should eq(LookupFoo::OtherProperty)
  end

  it 'should not provide access to unknown Property classes' do
    lambda {
      @klass::Bla
    }.should raise_error(NameError)
  end
end
