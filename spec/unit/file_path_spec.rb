require 'spec_helper'
require './spec/fixtures/software_package'

try_spec do
  describe Ardm::Property::FilePath do
    before do
      @property = Ardm::Fixtures::SoftwarePackage.properties[:source_path]
    end

    before do
      @input = '/usr/bin/ruby'
      @path  = Pathname.new(@input)
    end

    describe '.dump' do
      describe 'when input is a string' do
        it 'does not modify input' do
          expect(@property.dump(@input)).to eq(@input)
        end
      end

      describe 'when input is nil' do
        it 'returns nil' do
          expect(@property.dump(nil)).to be_nil
        end
      end

      describe 'when input is a blank string' do
        it 'returns nil' do
          expect(@property.dump('')).to be_nil
        end
      end
    end

    describe '.load' do
      describe 'when value is a non-blank file path' do
        it 'returns Pathname for a path' do
          expect(@property.load(@input)).to eq(@path)
        end
      end

      describe 'when value is nil' do
        it 'return nil' do
          expect(@property.load(nil)).to be_nil
        end
      end

      describe 'when value is a blank string' do
        it 'returns nil' do
          expect(@property.load('')).to be_nil
        end
      end
    end

    describe '.typecast' do
      describe 'when a Pathname is given' do
        it 'does not modify input' do
          expect(@property.typecast(@path)).to eq(@path)
        end
      end

      describe 'when a nil is given' do
        it 'does not modify input' do
          expect(@property.typecast(nil)).to eq(nil)
        end
      end

      describe 'when a string is given' do
        it 'returns Pathname for given path' do
          expect(@property.typecast(@input)).to eq(@path)
        end
      end
    end
  end
end
