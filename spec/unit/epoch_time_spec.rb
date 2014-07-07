require 'spec_helper'

describe Ardm::Property::EpochTime do
  before do
    class ::User < Ardm::Record
      property :id,   Serial
      property :bday, EpochTime
    end

    @property = User.properties[:bday]
  end

  describe '#dump' do
    subject { @property.dump(value) }

    describe 'with a Time instance' do
      let(:value) { Time.now }

      it { is_expected.to eq(value.to_i) }
    end

    describe 'with nil' do
      let(:value) { nil }

      it { is_expected.to eq(value) }
    end
  end

  describe '#typecast' do
    subject { @property.typecast(value) }

    describe 'with a DateTime instance' do
      let(:value) { DateTime.now }

      it { is_expected.to eq(Time.parse(value.to_s)) }
    end

    describe 'with a number' do
      let(:value) { Time.now.to_i }

      it { is_expected.to eq(::Time.at(value)) }
    end

    describe 'with a numeric string' do
      let(:value) { Time.now.to_i.to_s }

      it { is_expected.to eq(::Time.at(value.to_i)) }
    end

    describe 'with a DateTime string' do
      let(:value) { '2011-07-11 15:00:04 UTC' }

      it { is_expected.to eq(::Time.parse(value)) }
    end
  end

  describe '#load' do
    subject { @property.load(value) }

    describe 'with a number' do
      let(:value) { Time.now.to_i }

      it { is_expected.to eq(Time.at(value)) }
    end

    describe 'with nil' do
      let(:value) { nil }

      it { is_expected.to eq(value) }
    end
  end
end
