# -*- coding: utf-8 -*-
require 'spec_helper'
require 'addressable/uri'

# instance methods
describe Ardm::Property do

  # define the model prior to supported_by
  before do
    class ::Track < Ardm::Record
      property :id,               Serial
      property :artist,           String, :lazy => false, :index => :artist_album
      property :title,            String, :field => 'name', :index => true
      property :album,            String, :index => :artist_album
      property :musicbrainz_hash, String, :unique => true, :unique_index => true
    end

    class ::Image < Ardm::Record
      property :md5hash,      String, :key => true, :length => 32
      property :title,        String, :required => true, :unique => true
      property :description,  Text,   :length => 1..1024, :lazy => [ :detail ]
      property :width,        Integer, :lazy => [:dimensions]
      property :height,       Integer, :lazy => [:dimensions]
      property :format,       String, :default => 'jpeg'
      property :taken_at,     Time,   :default => proc { Time.now }

      validates_presence_of :format
    end
  end

  describe '#field' do
    it 'returns @field value if it is present' do
      expect(Track.properties[:title].field).to eql('name')
    end
  end

  describe '#default_for' do
    it 'returns default value for non-callables' do
      expect(Image.properties[:format].default_for(Image.new)).to eq('jpeg')
    end

    it 'returns result of a call for callable values' do
      expect(Image.properties[:taken_at].default_for(Image.new).year).to eq(Time.now.year)
    end

    it "sets the default when the record is created" do
      img = Image.create!(title: 'My Picture')
      expect(img.format).to eq('jpeg')
    end
  end

  describe '#eql?' do
    it 'is true for properties with the same model and name' do
      expect(Track.properties[:title]).to eql(Track.properties[:title])
    end


    it 'is false for properties of different models' do
      expect(Track.properties[:title]).not_to eql(Image.properties[:title])
    end

    it 'is false for properties with different names' do
      expect(Track.properties[:title]).not_to eql(Track.properties[:id])
    end
  end

  describe '#get!' do
    before do
      @image = Image.new

      # now some dark Ruby magic
      @image.instance_variable_set(:@description, 'Is set by magic')
    end

    it 'gets instance variable value from the resource directly' do
      skip "support for this in ActiveRecord is questionable" do
        # if you know a better way to test direct instance variable access,
        # go ahead and make changes to this example
        expect(Image.properties[:description].get!(@image)).to eq('Is set by magic')
      end
    end
  end

  describe '#index' do
    it 'returns true when property has an index' do
      expect(Track.properties[:title].index).to be(true)
    end

    it 'returns index name when property has a named index' do
      expect(Track.properties[:album].index).to eql(:artist_album)
    end

    it 'returns false when property has no index' do
      expect(Track.properties[:musicbrainz_hash].index).to be(false)
    end
  end

  describe '#initialize' do
    describe 'when tracking strategy is explicitly given' do
      it 'uses tracking strategy from options'
    end
  end

  describe '#inspect' do
    before do
      @str = Track.properties[:title].inspect
    end

    it 'features model name' do
      expect(@str).to match(/@model=Track/)
    end

    it 'features property name' do
      expect(@str).to match(/@name=:title/)
    end
  end

  describe '#key?' do
    describe 'returns true when property is a ' do
      it 'serial key' do
        expect(Track.properties[:id].key?).to be(true)
      end
      it 'natural key' do
        expect(Image.properties[:md5hash].key?).to be(true)
      end
    end

    it 'returns true when property is a part of composite key'

    it 'returns false when property does not relate to a key' do
      expect(Track.properties[:title].key?).to be(false)
    end
  end

  describe '#lazy?' do
    it 'returns true when property is lazy loaded' do
      expect(Image.properties[:description].lazy?).to be(true)
    end

    it 'returns false when property is not lazy loaded' do
      expect(Track.properties[:artist].lazy?).to be(false)
    end
  end

  describe '#length' do
    it 'returns upper bound for Range values' do
      expect(Image.properties[:description].length).to eql(1024)
    end

    it 'returns value as is for integer values' do
      expect(Image.properties[:md5hash].length).to eql(32)
    end
  end

  describe '#min' do
    describe 'when :min and :max options not provided to constructor' do
      before do
        @property = Image.property(:integer_with_nil_min, Integer)
      end

      it 'should be nil' do
        expect(@property.min).to be_nil
      end
    end

    describe 'when :min option not provided to constructor, but :max is provided' do
      before do
        @property = Image.property(:integer_with_default_min, Integer, :max => 1)
      end

      it 'should be the default value' do
        expect(@property.min).to eq(0)
      end
    end

    describe 'when :min and :max options provided to constructor' do
      before do
        @min = 1
        @property = Image.property(:integer_with_explicit_min, Integer, :min => @min, :max => 2)
      end

      it 'should be the expected value' do
        expect(@property.min).to eq(@min)
      end
    end
  end

  describe '#max' do
    describe 'when :min and :max options not provided to constructor' do
      before do
        @property = Image.property(:integer_with_nil_max, Integer)
      end

      it 'should be nil' do
        expect(@property.max).to be_nil
      end
    end

    describe 'when :max option not provided to constructor, but :min is provided' do
      before do
        @property = Image.property(:integer_with_default_max, Integer, :min => 1)
      end

      it 'should be the default value' do
        expect(@property.max).to eq(2**31-1)
      end
    end

    describe 'when :min and :max options provided to constructor' do
      before do
        @max = 2
        @property = Image.property(:integer_with_explicit_max, Integer, :min => 1, :max => @max)
      end

      it 'should be the expected value' do
        expect(@property.max).to eq(@max)
      end
    end
  end

  describe '#allow_nil?' do
    it 'returns true when property can accept nil as its value' do
      expect(Track.properties[:artist].allow_nil?).to be(true)
    end

    it 'returns false when property nil value is prohibited for this property' do
      expect(Image.properties[:title].allow_nil?).to be(false)
    end
  end

  describe '#serial?' do
    it 'returns true when property is serial (auto incrementing)' do
      expect(Track.properties[:id].serial?).to be(true)
    end

    it 'returns false when property is NOT serial (auto incrementing)' do
      expect(Image.properties[:md5hash].serial?).to be(false)
    end
  end

  describe '#set' do
    before do
      # keep in mind we must run these examples with a
      # saved model instance
      @image = Image.create(
        :md5hash     => '5268f0f3f452844c79843e820f998869',
        :title       => 'Rome at the sunset',
        :description => 'Just wow'
      )

      @property = Image.properties[:title]
    end

    it 'triggers lazy loading for given resource'

    it 'type casts given value' do
      @property.set(@image, Addressable::URI.parse('http://test.example/'))
      # get a string that has been typecasted using #to_str
      expect(@image.title).to eq('http://test.example/')
    end

    it 'sets new property value' do
      @property.set(@image, 'Updated value')
      expect(@image.title).to eq('Updated value')
    end
  end

  describe '#set!' do
    before do
      @image = Image.new(:md5hash      => '5268f0f3f452844c79843e820f998869',
                         :title       => 'Rome at the sunset',
                         :description => 'Just wow')

      @property = Image.properties[:title]
    end

    it 'directly sets instance variable on given resource' do
      @property.set!(@image, 'Set with dark Ruby magic')
      expect(@image.title).to eq('Set with dark Ruby magic')
    end
  end

  describe '#unique?' do
    it 'is true for fields that explicitly given uniq index' do
      expect(Track.properties[:musicbrainz_hash].unique?).to be(true)
    end

    it 'is true for serial fields' do
      skip do
        expect(Track.properties[:title].unique?).should be(true)
      end
    end

    it 'is true for keys' do
      expect(Image.properties[:md5hash].unique?).to be(true)
    end
  end

  describe '#unique_index' do
    it 'returns true when property has unique index' do
      expect(Track.properties[:musicbrainz_hash].unique_index).to be(true)
    end

    it 'returns false when property has no unique index' do
      expect(Track.properties[:title].unique_index).to be(false)
    end

    it 'returns true when property is unique' do
      expect(Image.properties[:title].unique_index).to be(true)
    end

    it 'returns :key when property is a key' do
      expect(Track.properties[:id].unique_index).to eq(:key)
    end
  end
end
