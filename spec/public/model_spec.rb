require 'spec_helper'

module ::ModelBlog
  class ArticlePublication < Ardm::Record
    self.table_name = "article_publications"

    property :id, Serial

    belongs_to :article,     model: 'ModelBlog::Article'
    belongs_to :publication, model: 'ModelBlog::Publication'
  end

  class Article < Ardm::Record
    self.table_name = "articles"

    property :id,       Serial
    property :title,    String, :required => true, :default => 'Default Title'
    property :body,     Text

    belongs_to :original, self, :required => false
    has n, :revisions, self, :child_key => [ :original_id ]
    has 1, :previous,  self, :child_key => [ :original_id ], :order => [ :id.desc ]
    has n, :article_publications, model: 'ArticlePublication'
    has n, :publications, :through => :article_publications
  end

  class Publication < Ardm::Record
    self.table_name = "api_users" # same set of fields, so even though it's a little weird, I'm going to reuse for now.

    property :id,   Serial
    property :name, String

    has n, :article_publications, model: ArticlePublication
    has n, :articles, :through => :article_publications
  end
end

Ardm::Record.finalize

describe 'Ardm::Record' do
  before do
    @article_model     = ModelBlog::Article
    @publication_model = ModelBlog::Publication
  end

  def model?; true end

  before do
    @articles = @article_model

    @original = @articles.create(:title => 'Original Article')
    @article  = @articles.create(:title => 'Sample Article', :body => 'Sample', :original => @original)
    expect(@article.reload.original).to eq(@original)
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
        expect { model.send(method) }.to change { model.any? }.from(true).to(false)
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

  describe "finders" do
    before(:each) do
      ModelBlog::Article.destroy
      @articles = ModelBlog::Article.all
      @article  = @articles.create(:title => 'Sample Article', :body => 'Sample')
    end

    include_examples 'Finder Interface'
  end

  it 'Ardm::Record should respond to raise_on_save_failure' do
    Ardm::Record.should respond_to(:raise_on_save_failure)
  end

  describe '.raise_on_save_failure' do
    subject { Ardm::Record.raise_on_save_failure }

    it { should be(false) }
  end

  it 'Ardm::Record should respond to raise_on_save_failure=' do
    Ardm::Record.should respond_to(:raise_on_save_failure=)
  end

  it 'A model should respond to raise_on_save_failure' do
    @article_model.should respond_to(:raise_on_save_failure)
  end

  describe '#raise_on_save_failure' do
    after do
      # reset to the default value
      reset_raise_on_save_failure(Ardm::Record)
      reset_raise_on_save_failure(@article_model)
    end

    subject { @article_model.raise_on_save_failure }

    describe 'when Ardm::Record.raise_on_save_failure has not been set' do
      it { should be(false) }
    end

    describe 'when Ardm::Record.raise_on_save_failure has been set to true' do
      before do
        Ardm::Record.raise_on_save_failure = true
      end

      it { should be(true) }
    end

    describe 'when model.raise_on_save_failure has been set to true' do
      before do
        @article_model.raise_on_save_failure = true
      end

      it { should be(true) }
    end
  end

  it 'A model should respond to raise_on_save_failure=' do
    @article_model.should respond_to(:raise_on_save_failure=)
  end
end
