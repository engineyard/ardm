require 'spec_helper'

try_spec do

  require './spec/fixtures/person'

  describe Ardm::Fixtures::Person do
    before do
      @resource = Ardm::Fixtures::Person.new(:name => '')
    end

    describe 'with no interests information' do
      before do
        @resource.interests = nil
      end

      describe 'when dumped and loaded again' do
        before do
          expect(@resource.save).to be true
          @resource.reload
        end

        it 'has no interests' do
          expect(@resource.interests).to eq(nil)
        end
      end
    end

    describe 'with no interests information' do
      before do
        @resource.interests = []
      end

      describe 'when dumped and loaded again' do
        before do
          expect(@resource.save).to be true
          @resource.reload
        end

        it 'has empty interests list' do
          expect(@resource.interests).to eq([])
        end
      end
    end

    describe 'with interests information given as a Hash' do
      it 'raises ArgumentError' do
        expect do
          @resource.interests = { :hash => 'value' }
          @resource.save
        end.to raise_error(ArgumentError, /must be a string, an array or nil/)
      end
    end

    describe 'with a few items on the interests list' do
      before do
        @input = 'fire, water, fire, a whole lot of other interesting things, ,,,'
        @resource.interests = @input
      end

      describe 'when dumped and loaded again' do
        before do
          expect(@resource.save).to be true
          @resource.reload
        end

        it 'includes "fire" in interests' do
          expect(@resource.interests).to include('fire')
        end

        it 'includes "water" in interests' do
          expect(@resource.interests).to include('water')
        end

        it 'includes "a whole lot of other interesting things" in interests' do
          expect(@resource.interests).to include('a whole lot of other interesting things')
        end

        it 'has blank entries removed' do
          expect(@resource.interests.any? { |i| Ardm::Ext.blank?(i) }).to be false
        end
      end
    end
  end
end
