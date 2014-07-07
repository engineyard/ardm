require 'spec_helper'

try_spec do
  describe Ardm::Property::Enum do
    before do
      class ::User < Ardm::Record
        property :id, Serial
      end

      @property_klass = Ardm::Property::Enum
    end

    it_should_behave_like "A property with flags"

    describe '.dump' do
      before do
        @enum = User.property(:enum, Ardm::Property::Enum[:first, :second, :third])
      end

      it 'should return the key of the value match from the flag map' do
        expect(@enum.dump(:first)).to eq(1)
        expect(@enum.dump(:second)).to eq(2)
        expect(@enum.dump(:third)).to eq(3)
      end

      describe 'when there is no match' do
        it 'should return nil' do
          expect(@enum.dump(:zero)).to be_nil
        end
      end
    end

    describe '.load' do
      before do
        @enum = User.property(:enum, Ardm::Property::Enum, :flags => [:uno, :dos, :tres])
      end

      it 'returns the value of the key match from the flag map' do
        expect(@enum.load(1)).to eq(:uno)
        expect(@enum.load(2)).to eq(:dos)
        expect(@enum.load(3)).to eq(:tres)
      end

      describe 'when there is no key' do
        it 'returns nil' do
          expect(@enum.load(-1)).to be_nil
        end
      end
    end

    describe '.typecast' do
      describe 'of Enum created from a symbol' do
        before do
          @enum = User.property(:enum, Ardm::Property::Enum, :flags => [:uno])
        end

        describe 'when given a symbol' do
          it 'uses Enum type' do
            expect(@enum.typecast(:uno)).to eq(:uno)
          end
        end

        describe 'when given a string' do
          it 'uses Enum type' do
            expect(@enum.typecast('uno')).to eq(:uno)
          end
        end

        describe 'when given nil' do
          it 'returns nil' do
            expect(@enum.typecast( nil)).to eq(nil)
          end
        end
      end

      describe 'of Enum created from integer list' do
        before do
          @enum = User.property(:enum, Ardm::Property::Enum, :flags => [1, 2, 3])
        end

        describe 'when given an integer' do
          it 'uses Enum type' do
            expect(@enum.typecast(1)).to eq(1)
          end
        end

        describe 'when given a float' do
          it 'uses Enum type' do
            expect(@enum.typecast(1.1)).to eq(1)
          end
        end

        describe 'when given nil' do
          it 'returns nil' do
            expect(@enum.typecast( nil)).to eq(nil)
          end
        end
      end

      describe 'of Enum created from a string' do
        before do
          @enum = User.property(:enum, Ardm::Property::Enum, :flags => ['uno'])
        end

        describe 'when given a symbol' do
          it 'uses Enum type' do
            expect(@enum.typecast(:uno)).to eq('uno')
          end
        end

        describe 'when given a string' do
          it 'uses Enum type' do
            expect(@enum.typecast('uno')).to eq('uno')
          end
        end

        describe 'when given nil' do
          it 'returns nil' do
            expect(@enum.typecast( nil)).to eq(nil)
          end
        end
      end
    end
  end
end
