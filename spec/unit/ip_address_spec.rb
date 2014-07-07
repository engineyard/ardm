require 'spec_helper'

require './spec/fixtures/network_node'

try_spec do
  describe Ardm::Property::IPAddress do
    before do
      @stored = '81.20.130.1'
      @input  = IPAddr.new(@stored)
      @property = Ardm::Fixtures::NetworkNode.properties[:ip_address]
    end

    describe '.dump' do
      describe 'when argument is an IP address given as Ruby object' do
        before do
          @result = @property.dump(@input)
        end

        it 'dumps input into a string' do
          expect(@result).to eq(@stored)
        end
      end

      describe 'when argument is nil' do
        before do
          @result = @property.dump(nil)
        end

        it 'returns nil' do
          expect(@result).to be_nil
        end
      end

      describe 'when input is a blank string' do
        before do
          @result = @property.dump('')
        end

        it 'retuns a blank string' do
          expect(@result).to eq('')
        end
      end
    end

    describe '.load' do
      describe 'when argument is a valid IP address as a string' do
        before do
          @result = @property.load(@stored)
        end

        it 'returns IPAddr instance from stored value' do
          expect(@result).to eq(@input)
        end
      end

      describe 'when argument is nil' do
        before do
          @result = @property.load(nil)
        end

        it 'returns nil' do
          expect(@result).to be_nil
        end
      end

      describe 'when argument is a blank string' do
        before do
          @result = @property.load('')
        end

        it 'returns IPAddr instance from stored value' do
          expect(@result).to eq(IPAddr.new('0.0.0.0'))
        end
      end

      describe 'when argument is an Array instance' do
        before do
          @operation = lambda { @property.load([]) }
        end

        it 'raises ArgumentError with a meaningful message' do
          expect(@operation).to raise_error(ArgumentError, '+value+ must be nil or a String')
        end
      end
    end

    describe '.typecast' do
      describe 'when argument is an IpAddr object' do
        before do
          @result = @property.typecast(@input)
        end

        it 'does not change the value' do
          expect(@result).to eq(@input)
        end
      end

      describe 'when argument is a valid IP address as a string' do
        before do
          @result = @property.typecast(@stored)
        end

        it 'instantiates IPAddr instance' do
          expect(@result).to eq(@input)
        end
      end
    end
  end
end
