require 'spec_helper'

module ::ModelBlog
  # FIXME: load order in tests is being problematic
  class ArticlePublication < Ardm::Record
  end

  class Article < Ardm::Record
    self.table_name = "articles"

    property :id,       Serial
    property :title,    String, :required => true, :default => 'Default Title'
    property :body,     Text
    timestamps :at

    belongs_to :original, self, :required => false
    has n, :revisions, self, :child_key => [ :original_id ]
    has 1, :previous,  self, :child_key => [ :original_id ], :order => [ :id.desc ]
    has n, :article_publications, model: ::ModelBlog::ArticlePublication
    has n, :publications, :through => :article_publications
  end

  class Publication < Ardm::Record
    self.table_name = "api_users" # same set of fields, so even though it's a little weird, I'm going to reuse for now.

    property :id,   Serial
    property :name, String

    has n, :article_publications, model: ::ModelBlog::ArticlePublication
    has n, :acticles, :through => :article_publications
  end

  class ArticlePublication < Ardm::Record
    self.table_name = "article_publications"

    belongs_to :acticle,     model: '::ModelBlog::Article'
    belongs_to :publication, model: '::ModelBlog::Publication'
  end
end

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
    @other    = @articles.create(:title => 'Other Article',  :body => 'Other')
  end

  describe '#new' do
    subject { model.new(*args) }

    let(:model) { @article_model }

    context 'with no arguments' do
      let(:args) { [] }

      it { is_expected.to be_instance_of(model) }

      it { expect(subject.title).to eq('Default Title') }
    end

    context 'with an empty Hash' do
      let(:args) { [ {} ] }

      it { is_expected.to be_instance_of(model) }

      it { expect(subject.title).to eq('Default Title') }
    end

    context 'with a non-empty Hash' do
      let(:attributes) { { :title => 'A Title' } }
      let(:args)       { [ attributes ]          }

      it { is_expected.to be_instance_of(model) }

      it { expect(subject.title).to eq('A Title') }
    end

    context 'with nil' do
      let(:args) { [ nil ] }

      it { is_expected.to be_instance_of(model) }

      it { expect(subject.title).to eq('Default Title') }
    end
  end

  [ :create, :create! ].each do |method|
    describe "##{method}" do
      subject { model.send(method, *args) }

      let(:model) { @article_model }

      context 'with no arguments' do
        let(:args) { [] }

        it { is_expected.to be_instance_of(model) }

        it { is_expected.to be_saved }
      end

      context 'with an empty Hash' do
        let(:args) { [ {} ] }

        it { is_expected.to be_instance_of(model) }

        it { is_expected.to be_saved }
      end

      context 'with a non-empty Hash' do
        let(:attributes) { { :title => 'A Title' } }
        let(:args)       { [ attributes ]          }

        it { is_expected.to be_instance_of(model) }

        it { is_expected.to be_saved }

        it { expect(subject.title).to eq attributes[:title] }
      end

      context 'with nil' do
        let(:args) { [ nil ] }

        it { is_expected.to be_instance_of(model) }

        it { is_expected.to be_saved }
      end
    end
  end

  [ :destroy, :destroy! ].each do |method|
    describe "##{method}" do
      it 'should remove all resources' do
        expect { @article_model.send(method) }.to change { @article_model.any? }.from(true).to(false)
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

        it { is_expected.to be(true) }

        it 'should persist the changes' do
          subject
          expect(model.all(:fields => [ :title ]).map { |resource| resource.title }.uniq).to eq([ attributes[:title] ])
        end
      end

      context 'with attributes where one is a parent association' do
        let(:attributes) { { :original => @other } }
        let(:args)       { [ attributes ]          }

        it { is_expected.to be(true) }

        it 'should persist the changes' do
          subject
          expect(model.all(:fields => [ :original_id ]).map { |resource| resource.original }.uniq).to eq([ attributes[:original] ])
        end
      end

      context 'with attributes where a required property is nil' do
        let(:attributes) { { :title => nil } }
        let(:args)       { [ attributes ]    }

        it 'should raise InvalidValueError' do
          expect { subject }.to(raise_error(Ardm::Property::InvalidValueError) do |error|
            expect(error.property).to eq(model.properties[:title])
          end)
        end
      end
    end
  end

  # FIXME: these are very broken right now
  #it_should_behave_like 'Finder Interface'

end
