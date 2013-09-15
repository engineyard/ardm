require 'spec_helper'

describe Ardm::Property::Lookup do
  before :all do
    Object.send(:remove_const, :Foo) if defined?(Foo)
    @klass = Class.new(ActiveRecord::Base) do
      self.table_name = "articles"
    end

    module Foo
      class OtherProperty < Ardm::Property::String; end
    end
  end

  it 'should provide access to Property classes' do
    @klass::Serial.should == Ardm::Property::Serial
  end

  it 'should provide access to Property classes from outside of the Property namespace' do
    @klass::OtherProperty.should be(Foo::OtherProperty)
  end

  it 'should not provide access to unknown Property classes' do
    lambda {
      @klass::Bla
    }.should raise_error(NameError)
  end
end
