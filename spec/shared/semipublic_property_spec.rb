shared_examples 'A semipublic Property' do
  module ::Blog
    class Article < Ardm::Record
      self.table_name = "articles"
      property :id, Serial
      timestamps :at
    end
  end

  describe '.new' do
    describe 'when provided no options' do
      it 'should return a Property' do
        expect(property).to be_kind_of(type)
      end

      it 'should set the load_as' do
        expect(property.load_as).to be(type.load_as)
      end

      it 'should set the model' do
        expect(property.model).to equal(model)
      end

      it 'should set the options to the default' do
        expect(property.options).to eq(type.options.merge(options))
      end
    end

    [ :index, :unique_index, :unique, :lazy ].each do |attribute|
      [ true, false, :title, [ :title ] ].each do |value|
        opts = { attribute => value }
        describe "when provided #{opts.inspect}" do
          let(:property) { type.new(model, name, options.merge(opts)) }

          it 'should return a Property' do
            expect(property).to be_kind_of(type)
          end

          it 'should set the model' do
            expect(property.model).to equal(model)
          end

          it 'should set the load_as' do
            expect(property.load_as).to be(type.load_as)
          end

          it "should set the options to #{opts.inspect}" do
            expect(property.options).to eq(type.options.merge(options.merge(opts)))
          end
        end
      end

      [ [], nil ].each do |value|
        describe "when provided #{(invalid_options = { attribute => value }).inspect}" do
          it 'should raise an exception' do
            expect {
              type.new(model, name, options.merge(invalid_options))
            }.to raise_error(ArgumentError, "options[#{attribute.inspect}] must be either true, false, a Symbol or an Array of Symbols")
          end
        end
      end
    end
  end

  describe '#load' do
    subject { property.load(value) }

    before do
      expect(property).to receive(:typecast).with(value).and_return(value)
    end

    it { is_expected.to eql(value) }
  end

  describe "#typecast" do
    describe 'when value is nil' do
      it 'returns value unchanged' do
        expect(property.typecast(nil)).to be(nil)
      end

      describe 'when value is a Ruby primitive' do
        it 'returns value unchanged' do
          expect(property.typecast(value)).to eq(value)
        end
      end
    end
  end

  describe '#valid?' do
    describe 'when provided a valid value' do
      it 'should return true' do
        expect(property.valid?(value)).to be(true)
      end
    end

    describe 'when provide an invalid value' do
      it 'should return false' do
        expect(property.valid?(invalid_value)).to be(false)
      end
    end

    describe 'when provide a nil value when required' do
      it 'should return false' do
        property = type.new(model, name, options.merge(:required => true))
        expect(property.valid?(nil)).to be(false)
      end
    end

    describe 'when provide a nil value when not required' do
      it 'should return false' do
        property = type.new(model, name, options.merge(:required => false))
        expect(property.valid?(nil)).to be(true)
      end
    end
  end

  describe '#assert_valid_value' do
    subject do
      property.assert_valid_value(value)
    end

    shared_examples_for 'assert_valid_value on invalid value' do
      it 'should raise Ardm::Property::InvalidValueError' do
        expect { subject }.to(raise_error(Ardm::Property::InvalidValueError) do |error|
          expect(error.property).to eq(property)
        end)
      end
    end

    describe 'when provided a valid value' do
      it 'should return true' do
        expect(subject).to be(true)
      end
    end

    describe 'when provide an invalid value' do
      let(:value) { invalid_value }

      it_should_behave_like 'assert_valid_value on invalid value'
    end

    describe 'when provide a nil value when required' do
      let(:property) { type.new(model, name, options.merge(:required => true)) }

      let(:value) { nil }

      it_should_behave_like 'assert_valid_value on invalid value'
    end

    describe 'when provide a nil value when not required' do
      let(:property) { type.new(model, name, options.merge(:required => false)) }

      let(:value) { nil }

      it 'should return true' do
        expect(subject).to be(true)
      end
    end
  end
end
