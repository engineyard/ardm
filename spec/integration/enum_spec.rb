require 'spec_helper'

try_spec do

  require './spec/fixtures/ticket'

  describe Ardm::Fixtures::Ticket do
    describe 'that is dumped and then loaded' do
      before do
        @resource = Ardm::Fixtures::Ticket.new(
          :title  => "Can't order by aggregated fields",
          :id     => 789,
          :body   => "I'm trying to use the aggregate method and sort the results by a summed field, but it doesn't work.",
          :status => 'confirmed'
        )

        @resource.save.should be_true
        @resource.reload
      end

      it 'preserves property value' do
        @resource.status.should == :confirmed
      end
    end

    describe 'that is supplied a matching enumeration value' do
      before do
        @resource = Ardm::Fixtures::Ticket.new(:status => :assigned)
      end

      it 'typecasts it for outside reader' do
        @resource.status.should == :assigned
      end
    end

    describe '#get' do
      before do
        @resource = Ardm::Fixtures::Ticket.new(
          :title  => '"sudo make install" of drizzle fails because it tries to chown mysql',
          :id     => 257497,
          :body   => "Note that at the very least, there should be a check to see whether or not the user is created before chown'ing a file to the user.",
          :status => 'confirmed'
        )
        @resource.save.should be_true
      end

      it 'supports queries with equality operator on enumeration property' do
        Ardm::Fixtures::Ticket.where(:status => :confirmed).
          should include(@resource)
      end

      it 'supports queries with inequality operator on enumeration property' do
        Ardm::Fixtures::Ticket.where(:status.not => :confirmed).
          should_not include(@resource)
      end
    end

    describe 'with value unknown to enumeration property' do
      before do
        @resource = Ardm::Fixtures::Ticket.new(:status => :undecided)
        @resource.valid?
      end

      # TODO: consider sharing shared spec exampels with dm-validations,
      #       which has 'invalid model' shared group
      it 'is invalid (auto validation for :within kicks in)' do
        @resource.should_not be_valid
      end

      it 'has errors' do
        @resource.errors.should_not be_empty
      end

      it 'has a meaningful error message on invalid property' do
        @resource.errors[:status].should include('must be one of unconfirmed, confirmed, assigned, resolved, not_applicable')
      end
    end
  end
end
