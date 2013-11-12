require 'spec_helper'

module ::ModelBlog
  class Article < Ardm::Record
    self.table_name = "articles"

    property :id,       Serial
    property :title,    String, :required => true, :default => 'Default Title'
    property :body,     Text

    belongs_to :original, self, :required => false
    has n, :revisions, self, :child_key => [ :original_id ]
    has 1, :previous,  self, :child_key => [ :original_id ], :order => [ :id.desc ]
    #has n, :publications, :through => Resource
  end

  class Publication < Ardm::Record
    self.table_name = "api_users" # same set of fields, so even though it's a little weird, I'm going to reuse for now.

    property :id,   Serial
    property :name, String

    #has n, :articles, :through => Resource
  end
end

describe 'Ardm::Record' do
  #extend DataMapper::Spec::CollectionHelpers::GroupMethods

  before do
    @article_model     = ModelBlog::Article
    @publication_model = ModelBlog::Publication
  end

  def model?; true end

  before do
    @articles = @article_model

    @original = @articles.create(:title => 'Original Article')
    @article  = @articles.create(:title => 'Sample Article', :body => 'Sample', :original => @original)
    @other    = @articles.create(:title => 'Other Article',  :body => 'Other')
  end

  describe '#new' do
    subject { model.new(*args) }

    let(:model) { @article_model }

    context 'with no arguments' do
      let(:args) { [] }

      it { should be_instance_of(model) }

      it { subject.title.should == 'Default Title' }
    end

    context 'with an empty Hash' do
      let(:args) { [ {} ] }

      it { should be_instance_of(model) }

      it { subject.title.should == 'Default Title' }
    end

    context 'with a non-empty Hash' do
      let(:attributes) { { :title => 'A Title' } }
      let(:args)       { [ attributes ]          }

      it { should be_instance_of(model) }

      it { subject.title.should == 'A Title' }
    end

    context 'with nil' do
      let(:args) { [ nil ] }

      it { should be_instance_of(model) }

      it { subject.title.should == 'Default Title' }
    end
  end

  [ :create, :create! ].each do |method|
    describe "##{method}" do
      subject { model.send(method, *args) }

      let(:model) { @article_model }

      context 'with no arguments' do
        let(:args) { [] }

        it { should be_instance_of(model) }

        it { should be_saved }
      end

      context 'with an empty Hash' do
        let(:args) { [ {} ] }

        it { should be_instance_of(model) }

        it { should be_saved }
      end

      context 'with a non-empty Hash' do
        let(:attributes) { { :title => 'A Title' } }
        let(:args)       { [ attributes ]          }

        it { should be_instance_of(model) }

        it { should be_saved }

        its(:title) { should == attributes[:title] }
      end

      context 'with nil' do
        let(:args) { [ nil ] }

        it { should be_instance_of(model) }

        it { should be_saved }
      end
    end
  end

  [ :destroy, :destroy! ].each do |method|
    describe "##{method}" do
      subject { model.send(method) }

      let(:model) { @article_model }

      it 'should remove all resources' do
        method(:subject).should change { model.any? }.from(true).to(false)
      end
    end
  end

  [ :update, :update! ].each do |method|
    describe "##{method}" do
      subject { model.send(method, *args) }

      let(:model) { @article_model }

      context 'with attributes' do
        let(:attributes) { { :title => 'Updated Title' } }
        let(:args)       { [ attributes ]                }

        it { should be(true) }

        it 'should persist the changes' do
          subject
          model.all(:fields => [ :title ]).map { |resource| resource.title }.uniq.should == [ attributes[:title] ]
        end
      end

      context 'with attributes where one is a parent association' do
        let(:attributes) { { :original => @other } }
        let(:args)       { [ attributes ]          }

        it { should be(true) }

        it 'should persist the changes' do
          subject
          model.all(:fields => [ :original_id ]).map { |resource| resource.original }.uniq.should == [ attributes[:original] ]
        end
      end

      context 'with attributes where a required property is nil' do
        let(:attributes) { { :title => nil } }
        let(:args)       { [ attributes ]    }

        it 'should raise InvalidValueError' do
          expect { subject }.to(raise_error(Ardm::Property::InvalidValueError) do |error|
            error.property.should == model.properties[:title]
          end)
        end
      end
    end
  end

  #it_should_behave_like 'Finder Interface'
end
