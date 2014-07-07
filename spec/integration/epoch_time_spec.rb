require 'spec_helper'

try_spec do

  require './spec/fixtures/person'

  describe Ardm::Fixtures::Person do
    before do
      @resource = Ardm::Fixtures::Person.new(:name => '')
    end

    describe 'with a birthday' do
      before do
        @resource.birthday = '1983-05-03'
      end

      describe 'after typecasting string input' do
        it 'has a valid birthday' do
          expect(@resource.birthday).to eq(::Time.parse('1983-05-03'))
        end
      end

      describe 'when dumped and loaded again' do
        before do
          expect(@resource.save).to be true
          @resource.reload
        end

        it 'has a valid birthday' do
          expect(@resource.birthday).to eq(::Time.parse('1983-05-03'))
        end
      end
    end

    describe 'without a birthday' do
      before do
        @resource.birthday = nil
      end

      describe 'after typecasting nil' do
        it 'has a nil value for birthday' do
          expect(@resource.birthday).to be_nil
        end
      end

      describe 'when dumped and loaded again' do
        before do
          expect(@resource.save).to be true
          @resource.reload
        end

        it 'has a nil value for birthday' do
          expect(@resource.birthday).to be_nil
        end
      end
    end

  end
end
