require 'spec_helper'

module ::ParanoidDateTimeBlog
  class Draft < Ardm::Record
    self.table_name = "articles"

    property :id,         Serial
    property :deleted_at, ParanoidDateTime
    timestamps :at

    before(:destroy, :before_destroy)

    def before_destroy; end
  end

  class Article < Draft; end

  class Review < Article; end
end


describe Ardm::Property::ParanoidDateTime do
  before do
    @model = ::ParanoidDateTimeBlog::Article
  end

  describe 'Model#destroy' do
    before do
      skip 'Does not work with < 1.8.7, see if backports fixes it' if RUBY_VERSION < '1.8.7'
    end

    subject { @resource.destroy }

    describe 'with a new resource' do
      before do
        @resource = @model.new
      end

      it 'should not delete the resource from the datastore' do
        expect(method(:subject)).not_to change { @model.with_deleted.size }.from(0)
      end

      it 'should not set the paranoid column' do
        expect(method(:subject)).not_to change { @resource.deleted_at }.from(nil)
      end

      it 'should run the destroy hook' do
        # NOTE: changed behavior because AR doesn't call hooks on destroying new objects
        expect(@resource).not_to receive(:before_destroy).with(no_args)
        subject
      end
    end

    describe 'with a saved resource' do
      before do
        @resource = @model.create
      end

      it { expect(subject).to be_truthy }

      it 'should not delete the resource from the datastore' do
        expect(method(:subject)).not_to change { @model.with_deleted.size }.from(1)
      end

      it 'should set the paranoid column' do
        expect(method(:subject)).to change { @resource.deleted_at }.from(nil)
      end

      it 'should run the destroy hook' do
        expect(@resource).to receive(:before_destroy).with(no_args)
        subject
      end
    end
  end

  describe 'Model#delete' do
    subject { @resource.delete }

    describe 'with a new resource' do
      before do
        @resource = @model.new
      end

      it 'should not delete the resource from the datastore' do
        expect(method(:subject)).not_to change { @model.with_deleted.size }.from(0)
      end

      it 'should not set the paranoid column' do
        expect(method(:subject)).not_to change { @resource.deleted_at }.from(nil)
      end

      it 'should not run the destroy hook' do
        expect(@resource).not_to receive(:before_destroy).with(no_args)
        subject
      end
    end

    describe 'with a saved resource' do
      before do
        @resource = @model.create
      end

      it { expect(subject).to be_truthy }

      it 'should delete the resource from the datastore' do
        expect(method(:subject)).to change { @model.with_deleted.size }.from(1).to(0)
      end

      it 'should not set the paranoid column' do
        expect(method(:subject)).not_to change { @resource.deleted_at }.from(nil)
      end

      it 'should not run the destroy hook' do
        expect(@resource).not_to receive(:before_destroy).with(no_args)
        subject
      end
    end
  end

  describe 'Model#with_deleted' do
    before do
      skip 'Does not work with < 1.8.7, see if backports fixes it' if RUBY_VERSION < '1.8.7'
      @resource = @model.create
      @resource.destroy
    end

    describe 'with a block' do
      subject { @model.with_deleted { @model.all } }

      it 'should scope the block to return all resources' do
        expect(subject.map { |resource| resource.key }).to eq([ @resource.key ])
      end
    end

    describe 'without a block' do
      subject { @model.with_deleted }

      it 'should return a collection scoped to return all resources' do
        expect(subject.map { |resource| resource.key }).to eq([ @resource.key ])
      end
    end
  end

  describe 'Model.inherited' do
    it 'sets @paranoid_properties' do
      expect(::ParanoidDateTimeBlog::Review.instance_variable_get(:@paranoid_properties)).to eq(
        ::ParanoidDateTimeBlog::Article.instance_variable_get(:@paranoid_properties)
      )
    end
  end
end
