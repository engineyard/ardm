require 'spec_helper'

require './spec/fixtures/bookmark'

try_spec do
  describe Ardm::Property::URI do
    before do
      @uri_str = 'http://example.com/path/to/resource/'
      @uri     = Addressable::URI.parse(@uri_str)

      @property = Ardm::Fixtures::Bookmark.properties[:uri]
    end

    describe '.dump' do
      it 'returns the URI as a String' do
        expect(@property.dump(@uri)).to eq(@uri_str)
      end

      describe 'when given nil' do
        it 'returns nil' do
          expect(@property.dump(nil)).to be_nil
        end
      end

      describe 'when given an empty string' do
        it 'returns an empty URI' do
          expect(@property.dump('')).to eq('')
        end
      end
    end

    describe '.load' do
      it 'returns the URI as Addressable' do
        expect(@property.load(@uri_str)).to eq(@uri)
      end

      describe 'when given nil' do
        it 'returns nil' do
          expect(@property.load(nil)).to be_nil
        end
      end

      describe 'if given an empty String' do
        it 'returns an empty URI' do
          expect(@property.load('')).to eq(Addressable::URI.parse(''))
        end
      end
    end

    describe '.typecast' do
      describe 'given instance of Addressable::URI' do
        it 'does nothing' do
          expect(@property.typecast(@uri)).to eq(@uri)
        end
      end

      describe 'when given a string' do
        it 'delegates to .load' do
          expect(@property.typecast(@uri_str)).to eq(@uri)
        end
      end
    end
  end
end
