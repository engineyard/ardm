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

        expect(@resource.save).to be_truthy
        @resource.reload
      end

      it 'preserves property value' do
        expect(@resource.status).to eq(:confirmed)
      end
    end

    describe 'that is supplied a matching enumeration value' do
      before do
        @resource = Ardm::Fixtures::Ticket.new(:status => :assigned)
      end

      it 'typecasts it for outside reader' do
        expect(@resource.status).to eq(:assigned)
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
        expect(@resource.save).to be_truthy
      end

      it 'supports queries with equality operator on enumeration property' do
        expect(Ardm::Fixtures::Ticket.where(:status => :confirmed)).
          to include(@resource)
      end

      it 'supports queries with inequality operator on enumeration property' do
        expect(Ardm::Fixtures::Ticket.where(:status.not => :confirmed)).
          not_to include(@resource)
      end
    end

    describe 'with value unknown to enumeration property' do
      before do
        @resource = Ardm::Fixtures::Ticket.new
      end

      it "raises" do
        expect { @resource.status = :undecided }.to(raise_error(Ardm::Property::Enum::InvalidValueError) do |error|
          expect(error.message).to eq("Invalid value for ENUM Ardm::Fixtures::Ticket.status, given: undecided")
        end)
      end
    end
  end
end
