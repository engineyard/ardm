require 'spec_helper'

try_spec do

  require './spec/fixtures/person'

  describe Ardm::Fixtures::Person do
    before do
      @resource = Ardm::Fixtures::Person.new(:name => 'Thomas Edison')
    end

    describe 'with no positions information' do
      before do
        @resource.positions = nil
      end

      describe 'when dumped and loaded again' do
        before do
          expect(@resource.save).to be_truthy
          @resource.reload
        end

        it 'has nil positions list' do
          expect(@resource.positions).to be_nil
        end
      end
    end

    describe 'with a few items on the positions list' do
      before do
        @resource.positions = [
          { :company => 'The Death Star, Inc', :title => 'Light sabre engineer'    },
          { :company => 'Sane Little Company', :title => 'Chief Curiosity Officer' },
        ]
      end

      describe 'when dumped and loaded again' do
        before do
          expect(@resource.save).to be_truthy
          @resource.reload
        end

        it 'loads positions list to the state when it was dumped/persisted with keys being strings' do
          expect(@resource.positions).to eq([
            { 'company' => 'The Death Star, Inc',  'title' => 'Light sabre engineer'    },
            { 'company'  => 'Sane Little Company', 'title' => 'Chief Curiosity Officer' },
          ])
        end
      end
    end

    describe 'with positions information given as empty list' do
      before do
        @resource.positions = []
      end

      describe 'when dumped and loaded again' do
        before do
          expect(@resource.save).to be_truthy
          @resource.reload
        end

        it 'has empty positions list' do
          expect(@resource.positions).to eq([])
        end
      end
    end

  end
end
