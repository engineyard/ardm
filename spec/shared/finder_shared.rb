shared_examples 'Finder Interface' do
  before do
    %w[ @article_model @article @other @articles ].each do |ivar|
      raise "+#{ivar}+ should be defined in before block" unless instance_variable_defined?(ivar)
      raise "+#{ivar}+ should not be nil in before block" unless instance_variable_get(ivar)
    end
  end

  before do
    @no_join = defined?(Ardm::Adapters::InMemoryAdapter) && @adapter.kind_of?(Ardm::Adapters::InMemoryAdapter) ||
               defined?(Ardm::Adapters::YamlAdapter)     && @adapter.kind_of?(Ardm::Adapters::YamlAdapter)

    @do_adapter = defined?(Ardm::Adapters::DataObjectsAdapter) && @adapter.kind_of?(Ardm::Adapters::DataObjectsAdapter)

    @many_to_many = false

    @skip = @no_join && @many_to_many
  end

  before do
    skip if @skip
  end

  def skip_if(message=nil, condition)
    skip(message) if condition
  end

  it 'should be Enumerable', :dm do
    expect(@articles).to be_kind_of(Enumerable)
  end

  [ :[], :slice ].each do |method|
    it { expect(@articles).to respond_to(method) }

    describe "##{method}" do
      before do
        1.upto(10) { |number| @articles.create(:body => "Article #{number}") }
        @copy = @articles.kind_of?(Class) ? @articles : @articles.dup
      end

      describe 'with a positive offset' do
        before do
          unless @skip
            @return = @resource = @articles.send(method, 0)
          end
        end

        it 'should return a Resource' do
          expect(@return).to be_kind_of(Ardm::Record)
        end

        it 'should return expected Resource' do
          expect(@return).to eq(@copy.entries.send(method, 0))
        end
      end

      describe 'with a positive offset and length' do
        before do
          @return = @resources = @articles.send(method, 5, 5)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
          @return.should be_kind_of(Ardm::Collection)
        end

        it 'should return the expected Resource' do
          expect(@return).to eq(@copy.entries.send(method, 5, 5))
        end

        it 'should scope the Collection', :dm do
          expect(@resources.reload).to eq(@copy.entries.send(method, 5, 5))
        end
      end

      describe 'with a positive range' do
        before do
          @return = @resources = @articles.send(method, 5..10)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return the expected Resources' do
          expect(@return).to eq(@copy.entries.send(method, 5..10))
        end

        it 'should scope the Collection', :dm do
          expect(@resources.reload).to eq(@copy.entries.send(method, 5..10))
        end
      end

      describe 'with a negative offset' do
        before do
          unless @skip
            @return = @resource = @articles.send(method, -1)
          end
        end

        it 'should return a Resource' do
          expect(@return).to be_kind_of(Ardm::Record)
        end

        it 'should return expected Resource' do
          expect(@return).to eq(@copy.entries.send(method, -1))
        end
      end

      describe 'with a negative offset and length' do
        before do
          @return = @resources = @articles.send(method, -5, 5)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return the expected Resources' do
          expect(@return).to eq(@copy.entries.send(method, -5, 5))
        end

        it 'should scope the Collection', :dm do
          expect(@resources.reload).to eq(@copy.entries.send(method, -5, 5))
        end
      end

      describe 'with a negative range' do
        before do
          @return = @resources = @articles.send(method, -5..-2)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return the expected Resources' do
          expect(@return.to_a).to eq(@copy.entries.send(method, -5..-2))
        end

        it 'should scope the Collection', :dm do
          expect(@resources.reload).to eq(@copy.entries.send(method, -5..-2))
        end
      end

      describe 'with an empty exclusive range' do
        before do
          @return = @resources = @articles.send(method, 0...0)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return the expected value' do
          expect(@return.to_a).to eq(@copy.entries.send(method, 0...0))
        end

        it 'should be empty' do
          expect(@return).to be_empty
        end
      end

      describe 'with an offset not within the Collection' do
        before do
          unless @skip
            @return = @articles.send(method, 99)
          end
        end

        it 'should return nil' do
          expect(@return).to be_nil
        end
      end

      describe 'with an offset and length not within the Collection', :dm do
        before do
          @return = @articles.send(method, 99, 1)
        end

        it 'should return a Collection' do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be empty' do
          expect(@return).to be_empty
        end
      end

      describe 'with a range not within the Collection', :dm do
        before do
          @return = @articles.send(method, 99..100)
        end

        it 'should return a Collection' do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be empty' do
          expect(@return).to be_empty
        end
      end
    end
  end

  it { expect(@articles).to respond_to(:all) }

  describe '#all' do
    describe 'with no arguments' do
      before do
        @copy = @articles.kind_of?(Class) ? @articles : @articles.dup

        @return = @collection = @articles.all
      end

      it 'should return a Collection', :dm do
        expect(@return).to be_kind_of(Ardm::Collection)
      end

      it 'should return a new instance' do
        expect(@return).not_to equal(@articles)
      end

      it 'should be expected Resources' do
        expect(@collection).to eq(@articles.entries)
      end

      it 'should not have a Query the same as the original', :dm do
        expect(@return.query).not_to equal(@articles.query)
      end

      it 'should have a Query equal to the original', :dm do
        expect(@return.query).to eql(@articles.query)
      end

      it 'should scope the Collection' do
        expect(@collection.reload).to eq(@copy.entries)
      end
    end

    describe 'with a query' do
      before do
        @new  = @articles.create(:body => 'New Article')
        @copy = @articles.kind_of?(Class) ? @articles : @articles.dup

        @return = @articles.all(:body => [ 'New Article' ])
      end

      it 'should return a Collection', :dm do
        expect(@return).to be_kind_of(Ardm::Collection)
      end

      it 'should return a new instance' do
        expect(@return).not_to equal(@articles)
      end

      it 'should be expected Resources' do
        expect(@return).to eq([ @new ])
      end

      it 'should have a different query than original Collection', :dm do
        expect(@return.query).not_to equal(@articles.query)
      end

      it 'should scope the Collection' do
        expect(@return.reload).to eq(@copy.entries.select { |resource| resource.body == 'New Article' })
      end
    end

    describe 'with a query using raw conditions' do
      before do
        skip unless defined?(Ardm::Adapters::DataObjectsAdapter) && @adapter.kind_of?(Ardm::Adapters::DataObjectsAdapter)
      end

      before do
        @new  = @articles.create(:subtitle => 'New Article')
        @copy = @articles.kind_of?(Class) ? @articles : @articles.dup

        @return = @articles.all(:conditions => [ 'subtitle = ?', 'New Article' ])
      end

      it 'should return a Collection', :dm do
        expect(@return).to be_kind_of(Ardm::Collection)
      end

      it 'should return a new instance' do
        expect(@return).not_to equal(@articles)
      end

      it 'should be expected Resources' do
        expect(@return).to eq([ @new ])
      end

      it 'should have a different query than original Collection' do
        expect(@return.query).not_to eq(@articles.query)
      end

      it 'should scope the Collection' do
        expect(@return.reload).to eq(@copy.entries.select { |resource| resource.subtitle == 'New Article' }.first(1))
      end
    end

    describe 'with a query that is out of range', :dm do
      it 'should raise an exception' do
        expect {
          @articles.all(:limit => 10).all(:offset => 10)
        }.to raise_error(RangeError, 'offset 10 and limit 0 are outside allowed range')
      end
    end

    describe 'with a query using a m:1 relationship' do
      describe 'with a Hash' do
        before do
          @return = @articles.all(:original => @original.attributes)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with a resource' do
        before do
          @return = @articles.all(:original => @original)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with a collection' do
        before do
          @collection = @article_model.all(
            Hash[ @article_model.key.zip(@original.key) ]
          )

          @return = @articles.all(:original => @collection)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end

      end

      describe 'with an empty Array' do
        before do
          @return = @articles.all(:original => [])
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be an empty Collection' do
          expect(@return).to be_empty
        end

        it 'should not have a valid query', :dm do
          expect(@return.query).not_to be_valid
        end
      end

      describe 'with a nil value' do
        before do
          @return = @articles.all(:original => nil)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @original ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end

        it 'should be equivalent to negated collection query' do
          skip_if 'Update RDBMS to match ruby behavior', @do_adapter && @articles.kind_of?(Ardm::Record) do
            # NOTE: the second query will not match any articles where original_id
            # is nil, while the in-memory/yaml adapters will.  RDBMS will explicitly
            # filter out NULL matches because we are matching on a non-NULL value,
            # which is not consistent with how DM/Ruby matching behaves.
            expect(@return).to eq(@articles.all(:original.not => @article_model.all))
          end
        end
      end

      describe 'with a negated nil value' do
        before do
          @return = @articles.all(:original.not => nil)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end

        it 'should be equivalent to collection query' do
          expect(@return.to_a).to eq(@articles.all(:original => @article_model.all).to_a)
        end
      end
    end

    describe 'with a query using a 1:1 relationship' do
      before do
        @new = @articles.create(:body => 'New Article', :original => @article)
      end

      describe 'with a Hash' do
        before do
          @return = @articles.all(:previous => @new.attributes)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with a resource' do
        before do
          @return = @articles.all(:previous => @new)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with a collection' do
        before do
          @collection = @article_model.all(
            Hash[ @article_model.key.zip(@new.key) ]
          )

          @return = @articles.all(:previous => @collection)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with an empty Array' do
        before do
          @return = @articles.all(:previous => [])
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be an empty Collection' do
          expect(@return).to be_empty
        end

        it 'should not have a valid query', :dm do
          expect(@return.query).not_to be_valid
        end
      end

      describe 'with a nil value' do
        before do
          @return = @articles.all(:previous => nil)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        if respond_to?(:model?) && model?
          it 'should be expected Resources' do
            expect(@return).to eq([ @other, @new ])
          end
        else
          it 'should be expected Resources' do
            expect(@return).to eq([ @new ])
          end
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end

        it 'should be equivalent to negated collection query' do
          expect(@return).to eq(@articles.all(:previous.not => @article_model.all(:original.not => nil)))
        end
      end

      describe 'with a negated nil value' do
        before do
          @return = @articles.all(:previous.not => nil)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @original, @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end

        it 'should be equivalent to collection query' do
          expect(@return).to eq(@articles.all(:previous => @article_model.all))
        end
      end
    end

    describe 'with a query using a 1:m relationship' do
      before do
        @new = @articles.create(:body => 'New Article', :original => @article)
      end

      describe 'with a Hash' do
        before do
          @return = @articles.all(:revisions => @new.attributes)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with a resource' do
        before do
          @return = @articles.all(:revisions => @new)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with a collection' do
        before do
          @collection = @article_model.all(
            Hash[ @article_model.key.zip(@new.key) ]
          )

          @return = @articles.all(:revisions => @collection)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with an empty Array' do
        before do
          @return = @articles.all(:revisions => [])
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be an empty Collection' do
          expect(@return).to be_empty
        end

        it 'should not have a valid query', :dm do
          expect(@return.query).not_to be_valid
        end
      end

      describe 'with a nil value' do
        before do
          @return = @articles.all(:revisions => nil)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        if respond_to?(:model?) && model?
          it 'should be expected Resources' do
            expect(@return).to eq([ @other, @new ])
          end
        else
          it 'should be expected Resources' do
            expect(@return).to eq([ @new ])
          end
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end

        #TODO? DM has funny ideas about has_many key => array value
        it 'should be equivalent to negated collection query', :dm do
          expect(@return).to eq(@articles.all(:revisions.not => @article_model.all(:original.not => nil)))
        end
      end

      describe 'with a negated nil value' do
        before do
          @return = @articles.all(:revisions.not => nil)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @original, @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end

        #TODO? DM has funny ideas about has_many key => array value
        it 'should be equivalent to collection query', :dm do
          expect(@return).to eq(@articles.all(:revisions => @article_model.all))
        end
      end
    end

    describe 'with a query using a m:m relationship' do
      before do
        @publication = @article.publications.create(:name => 'Ardm Now')
      end

      describe 'with a Hash' do
        before do
          @return = @articles.all(:publications => @publication.attributes)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with a resource' do
        before do
          @return = @articles.all(:publications => @publication)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with a collection' do
        before do
          @collection = @publication_model.all(
            Hash[ @publication_model.key.zip(@publication.key) ]
          )

          @return = @articles.all(:publications => @collection)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end
      end

      describe 'with an empty Array' do
        before do
          @return = @articles.all(:publications => [])
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be an empty Collection', focus: true do
          expect(@return).to be_empty
        end

        it 'should not have a valid query', :dm do
          expect(@return.query).not_to be_valid
        end
      end

      describe 'with a nil value' do
        before do
          @return = @articles.all(:publications => nil)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be empty', focus: true do
          skip "TODO: not why this is expected to be empty... there are some articles with nil publications"
          expect(@return).to be_empty
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end

        it 'should be equivalent to negated collection query' do
          expect(@return).to eq(@articles.all(:publications.not => @publication_model.all))
        end
      end

      describe 'with a negated nil value' do
        before do
          @return = @articles.all(:publications.not => nil)
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should be expected Resources' do
          expect(@return).to eq([ @article ])
        end

        it 'should have a valid query', :dm do
          expect(@return.query).to be_valid
        end

        it 'should be equivalent to collection query' do
          expect(@return).to eq(@articles.all(:publications => @publication_model.all))
        end
      end
    end
  end

  it { expect(@articles).to respond_to(:at) }

  describe '#at' do
    before do
      @copy = @articles.kind_of?(Class) ? @articles : @articles.dup
      @copy.to_a
    end

    describe 'with positive offset' do
      before do
        @return = @resource = @articles.at(0)
      end

      it 'should return a Resource' do
        expect(@return).to be_kind_of(Ardm::Record)
      end

      it 'should return expected Resource' do
        expect(@resource).to eq(@copy.entries.at(0))
      end
    end

    describe 'with negative offset' do
      before do
        @return = @resource = @articles.at(-1)
      end

      it 'should return a Resource' do
        expect(@return).to be_kind_of(Ardm::Record)
      end

      it 'should return expected Resource' do
        expect(@resource).to eq(@copy.entries.at(-1))
      end
    end
  end

  it { expect(@articles).to respond_to(:each) }

  describe '#each' do
    subject { @articles.each(&block) }

    let(:yields) { []                                       }
    let(:block)  { lambda { |resource| yields << resource } }

    before do
      @copy = @articles.kind_of?(Class) ? @articles : @articles.dup
      @copy.to_a
    end

    it { is_expected.to equal(@articles.to_a) }

    it { expect(method(:subject)).to change { yields.dup }.from([]).to(@copy.to_a) }
  end

  it { expect(@articles).to respond_to(:fetch) }

  describe '#fetch', :dm do
    subject { @articles.fetch(*args, &block) }

    let(:block) { nil }

    context 'with a valid index and no default' do
      let(:args) { [ 0 ] }

      before do
        @copy = @articles.kind_of?(Class) ? @articles : @articles.dup
        @copy.to_a
      end

      it { is_expected.to be_kind_of(Array) }

      it { is_expected.to eq(@copy.entries.values_at(*args)) }
    end

    describe 'with negative offset' do
      let(:args) { [ -1 ] }

      it { is_expected.to be_kind_of(Array) }

      it { is_expected.to eq(@copy.entries.values_at(*args)) }
    end
  end

  it 'should respond to a belongs_to relationship method with #method_missing' do
    skip_if 'Model#method_missing should delegate to relationships', @articles.kind_of?(Class) do
      expect(@articles).to respond_to(:original)
    end
  end

  it 'should respond to a has n relationship method with #method_missing' do
    skip_if 'Model#method_missing should delegate to relationships', @articles.kind_of?(Class) do
      expect(@articles).to respond_to(:revisions)
    end
  end

  it 'should respond to a has 1 relationship method with #method_missing' do
    skip_if 'Model#method_missing should delegate to relationships', @articles.kind_of?(Class) do
      expect(@articles).to respond_to(:previous)
    end
  end

  describe '#method_missing' do
    before do
      skip 'Model#method_missing should delegate to relationships' if @articles.kind_of?(Class)
    end

    describe 'with a belongs_to relationship method' do
      before do
        @articles.create(:body => 'Another Article', :original => @original)

        @return = @collection = @articles.originals
      end

      it 'should return a Collection', :dm do
        expect(@return).to be_kind_of(Ardm::Collection)
      end

      it 'should return expected Collection' do
        expect(@collection).to eq([ @original ])
      end

      it 'should set the association for each Resource' do
        skip "Umm... there are 3 @articles ... so not sure how calling map would ever result in an array of 2 objects"
        expect(@articles.map { |resource| resource.original }).to eq([ @original, @original ])
      end
    end

    describe 'with a has 1 relationship method' do
      before do
        unless @many_to_many
          skip %Q{
            So it seems this test is trying to make a new record AND modify 2 relationships
            ...and then without saving any of that to the database...
            it's trying to execute an association chain to find the corresponding (un-saved) correct things
            I don't think anything will ever work this way with ActiveRecord...
          }
        end
        # FIXME: create is necessary for m:m so that the intermediary
        # is created properly.  This does not occur with @new.save
        @new = @articles.send(@many_to_many ? :create : :new)

        @article.previous = @new
        @new.previous     = @other

        expect(@article.save).to be(true)
      end

      describe 'with no arguments' do
        before do
          @return = @articles.previous
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return expected Collection' do
          # association is sorted reverse by id
          expect(@return).to eq([ @new, @other ])
        end

        it 'should set the association for each Resource' do
          expect(@articles.map { |resource| resource.previous }).to eq([ @new, @other ])
        end
      end

      describe 'with arguments' do
        before do
          @return = @articles.previous(:fields => [ :id ])
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return expected Collection' do
          # association is sorted reverse by id
          expect(@return).to eq([ @new, @other ])
        end

        { :id => true, :title => false, :body => false }.each do |attribute, expected|
          it "should have query field #{attribute.inspect} #{'not' unless expected} loaded".squeeze(' ') do
            @return.each { |resource| expect(resource.attribute_loaded?(attribute)).to eq(expected) }
          end
        end

        it 'should set the association for each Resource' do
          expect(@articles.map { |resource| resource.previous }).to eq([ @new, @other ])
        end
      end
    end

    describe 'with a has n relationship method' do
      before do
        unless @many_to_many
          skip %Q{
            So it seems this test is trying to make a new record AND modify 2 relationships
            ...and then without saving any of that to the database...
            it's trying to execute an association chain to find the corresponding (un-saved) correct things
            I don't think anything will ever work this way with ActiveRecord...
          }
        end
        # FIXME: create is necessary for m:m so that the intermediary
        # is created properly.  This does not occur with @new.save
        @new = @articles.send(@many_to_many ? :create : :new)

        # associate the article with children
        @article.revisions << @new
        @new.revisions     << @other

        expect(@article.save).to be(true)
      end

      describe 'with no arguments' do
        before do
          @return = @collection = @articles.revisions
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return expected Collection' do
          expect(@collection).to eq([ @other, @new ])
        end

        it 'should set the association for each Resource' do
          expect(@articles.map { |resource| resource.revisions }).to eq([ [ @new ], [ @other ] ])
        end
      end

      describe 'with arguments' do
        before do
          @return = @collection = @articles.revisions(:fields => [ :id ])
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return expected Collection' do
          expect(@collection).to eq([ @other, @new ])
        end

        { :id => true, :title => false, :body => false }.each do |attribute, expected|
          it "should have query field #{attribute.inspect} #{'not' unless expected} loaded".squeeze(' ') do
            @collection.each { |resource| expect(resource.attribute_loaded?(attribute)).to eq(expected) }
          end
        end

        it 'should set the association for each Resource' do
          expect(@articles.map { |resource| resource.revisions }).to eq([ [ @new ], [ @other ] ])
        end
      end
    end

    describe 'with a has n :through relationship method' do
      before do
        @new = @articles.create

        @publication1 = @article.publications.create(:name => 'Ruby Today')
        @publication2 = @new.publications.create(:name => 'Inside Ardm')
      end

      describe 'with no arguments' do
        before do
          @return = @collection = @articles.publications
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return expected Collection' do
          skip_if @no_join do
            expect(@collection).to eq([ @publication1, @publication2 ])
          end
        end

        it 'should set the association for each Resource' do
          skip_if @no_join do
            expect(@articles.map { |resource| resource.publications }).to eq([ [ @publication1 ], [ @publication2 ] ])
          end
        end
      end

      describe 'with arguments' do
        before do
          @return = @collection = @articles.publications(:fields => [ :id ])
        end

        it 'should return a Collection', :dm do
          expect(@return).to be_kind_of(Ardm::Collection)
        end

        it 'should return expected Collection' do
          skip_if @no_join do
            expect(@collection).to eq([ @publication1, @publication2 ])
          end
        end

        { :id => true, :name => false }.each do |attribute, expected|
          it "should have query field #{attribute.inspect} #{'not' unless expected} loaded".squeeze(' '), :dm do
            @collection.each { |resource| expect(resource.attribute_loaded?(attribute)).to eq(expected) }
          end
        end

        it 'should set the association for each Resource' do
          skip_if @no_join do
            expect(@articles.map { |resource| resource.publications }).to eq([ [ @publication1 ], [ @publication2 ] ])
          end
        end
      end
    end

    describe 'with an unknown method' do
      it 'should raise an exception' do
        expect {
          @articles.unknown
        }.to raise_error(NoMethodError)
      end
    end
  end
end
