require 'spec_helper'

try_spec do

  require './spec/fixtures/software_package'

  describe Ardm::Fixtures::SoftwarePackage do
    describe 'with source path at /var/cache/apt/archives/linux-libc-dev_2.6.28-11.40_i386.deb' do
      before do
        @source_path = '/var/cache/apt/archives/linux-libc-dev_2.6.28-11.40_i386.deb'
        @resource    = Ardm::Fixtures::SoftwarePackage.new(:source_path => @source_path)
      end

      describe 'when is a new record' do
        before do
        end

        it 'points to original path' do
          expect(@resource.source_path.to_s).to eq(@source_path)
        end

        it 'responds to :directory?' do
          expect(@resource.source_path).to respond_to(:directory?)
        end

        it 'responds to :file?' do
          expect(@resource.source_path).to respond_to(:file?)
        end

        it 'responds to :dirname' do
          expect(@resource.source_path).to respond_to(:dirname)
        end

        it 'responds to :absolute?' do
          expect(@resource.source_path).to respond_to(:absolute?)
        end

        it 'responds to :readable?' do
          expect(@resource.source_path).to respond_to(:readable?)
        end

        it 'responds to :size' do
          expect(@resource.source_path).to respond_to(:size)
        end
      end
    end

    describe 'with destination path at /usr/local' do
      before do
        @destination_path = '/usr/local'
        @resource         = Ardm::Fixtures::SoftwarePackage.new(:destination_path => @destination_path)
      end

      describe 'when saved and reloaded' do
        before do
          expect(@resource.save).to be true
          @resource.reload
        end

        it 'points to original path' do
          expect(@resource.destination_path.to_s).to eq(@destination_path)
        end

        it 'responds to :directory?' do
          expect(@resource.destination_path).to respond_to(:directory?)
        end

        it 'responds to :file?' do
          expect(@resource.destination_path).to respond_to(:file?)
        end

        it 'responds to :dirname' do
          expect(@resource.destination_path).to respond_to(:dirname)
        end

        it 'responds to :absolute?' do
          expect(@resource.destination_path).to respond_to(:absolute?)
        end

        it 'responds to :readable?' do
          expect(@resource.destination_path).to respond_to(:readable?)
        end

        it 'responds to :size' do
          expect(@resource.destination_path).to respond_to(:size)
        end
      end
    end

    describe 'with no (nil) source path' do
      before do
        @source_path = nil
        @resource    = Ardm::Fixtures::SoftwarePackage.new(:source_path => @source_path)
      end

      describe 'when saved and reloaded' do
        before do
          expect(@resource.save).to be true
          @resource.reload
        end

        it 'has nil source path' do
          expect(@resource.source_path).to be_nil
        end
      end
    end

    describe 'with a blank source path' do
      before do
        @source_path = ''
        @resource    = Ardm::Fixtures::SoftwarePackage.new(:source_path => @source_path)
      end

      describe 'when saved and reloaded' do
        before do
          expect(@resource.save).to be true
          @resource.reload
        end

        it 'has nil source path' do
          expect(@resource.source_path).to be_nil
        end
      end
    end

    describe 'with a source path assigned to an empty array' do
      before do
        @source_path = []
        @resource    = Ardm::Fixtures::SoftwarePackage.new(:source_path => @source_path)
      end

      describe 'when saved and reloaded' do
        before do
          expect(@resource.save).to be true
          @resource.reload
        end

        it 'has nil source path' do
          expect(@resource.source_path).to be_nil
        end
      end
    end

    describe 'with a source path assigned to a Hash' do
      before do
        @source_path = { :guitar => 'Joe Satriani' }
      end

      describe 'when instantiated' do
        it 'raises an exception' do
          expect do
            Ardm::Fixtures::SoftwarePackage.new(:source_path => @source_path)
          end.to raise_error(TypeError)
        end
      end
    end
  end
end
