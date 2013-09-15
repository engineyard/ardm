require 'spec_helper'

# instance methods
describe Ardm::Property do
  describe ".find_class" do
    [ :Serial, :Text ].each do |type|
      describe "with #{type}" do
        subject { Ardm::Property.find_class(type) }

        it { subject.should be(Ardm::Property.const_get(type)) }
      end
    end
  end

  describe ".determine_class" do
    [ Integer, String, Float, Class, String, Time, DateTime, Date ].each do |type|
      describe "with #{type}" do
        subject { Ardm::Property.determine_class(type) }

        it { subject.should be(Ardm::Property.const_get(type.name)) }
      end
    end

    describe "with property subclasses" do
      before :all do
        Object.send(:remove_const, :CustomProps) if Object.const_defined?(:CustomProps)

        module ::CustomProps
          module Property
            class Hash   < Ardm::Property::Object; end
            class Other  < Ardm::Property::Object; end
            class Serial < Ardm::Property::Object; end
          end
        end
      end

      describe "with ::Foo::Property::Hash" do
        subject { Ardm::Property.determine_class(Hash) }

        it { subject.should be(::CustomProps::Property::Hash) }
      end

      describe "with ::Foo::Property::Other" do
        subject { Ardm::Property.determine_class(::CustomProps::Property::Other) }

        it { subject.should be(::CustomProps::Property::Other) }
      end

    end
  end
end
