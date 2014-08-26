require 'spec_helper'

try_spec do

  require './spec/fixtures/tshirt'

  describe Ardm::Fixtures::TShirt do
    before do
      @resource = Ardm::Fixtures::TShirt.new(
        :writing     => 'Fork you',
        :has_picture => true,
        :picture     => :octocat,
        :color       => :white
      )
    end

    describe 'with the default value' do
      it 'returns it as an array', skip: true do
        skip "FIXME: This probably should pass" do
          expect(@resource.size).to eq([Ardm::Fixtures::TShirt.properties[:size].default])
        end
      end
    end

    describe 'with multiple sizes' do
      describe 'dumped and loaded' do
        before do
          @resource.size = [ :xs, :medium ]
          expect(@resource.save).to be_truthy
          @resource.reload
        end

        it 'returns size as array', pending: true do
          expect(@resource.size).to eq([ :xs, :medium ])
        end
      end
    end

    describe 'with a single size' do
      before do
        @resource.size = :large
      end

      describe 'dumped and loaded' do
        before do
          expect(@resource.save).to be_truthy
          @resource.reload
        end

        it 'returns size as array with a single value', pending: true do
          expect(@resource.size).to eq([:large])
        end
      end
    end

    # Flag does not add any auto validations
    describe 'without size' do
      before do
        expect(@resource).to be_valid
        @resource.size = nil
      end

      it 'is valid' do
        expect(@resource).to be_valid
      end

      it 'has no errors' do
        expect(@resource.errors).to be_empty
      end
    end
  end
end
