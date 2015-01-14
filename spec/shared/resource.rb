shared_examples 'A public Resource' do
  before do
    @no_join = defined?(Ardm::Adapters::InMemoryAdapter) && @adapter.kind_of?(Ardm::Adapters::InMemoryAdapter) ||
               defined?(Ardm::Adapters::YamlAdapter)     && @adapter.kind_of?(Ardm::Adapters::YamlAdapter)

    # it seems like we'll always skip this because the adaper is never going to be the in memory adapter
    #relationship        = @user_model.relationships[:referrer]
    #@one_to_one_through = relationship.kind_of?(Ardm::ActiveRecord::Associations::OneToOne::Relationship) && relationship.respond_to?(:through)

    @skip = @no_join && @one_to_one_through
  end

  before do
    unless @skip
      %w[ @user_model @user @comment_model ].each do |ivar|
        raise "+#{ivar}+ should be defined in before block" unless instance_variable_get(ivar)
      end
    end
  end

  before do
    skip if @skip
  end

  [ :==, :=== ].each do |method|
    it { expect(@user).to respond_to(method) }

    describe "##{method}" do
      describe 'when comparing to the same resource' do
        before do
          @other  = @user
          @return = @user.__send__(method, @other)
        end

        it 'should return true' do
          expect(@return).to be(true)
        end
      end

      describe 'when comparing to an resource that does not respond to resource methods' do
        before do
          @other  = Object.new
          @return = @user.__send__(method, @other)
        end

        it 'should return false' do
          expect(@return).to be(false)
        end
      end

      describe 'when comparing to a resource with the same properties, but the model is a subclass' do
        before do
          rescue_if @skip do
            @other  = @author_model.new(@user.attributes)
            @return = @user.__send__(method, @other)
          end
        end

        it 'should return true' do
          expect(@return).to be(true)
        end
      end

      describe 'when comparing to a resource with the same repository, key and neither self or the other resource is dirty' do
        before do
          rescue_if @skip do
            @other  = @user_model.get(*@user.key)
            @return = @user.__send__(method, @other)
          end
        end

        it 'should return true' do
          expect(@return).to be(true)
        end
      end

      describe 'when comparing to a resource with the same repository, key but either self or the other resource is dirty' do
        before do
          rescue_if @skip do
            @user.age = 20
            @other  = @user_model.get(*@user.key)
            @return = @user.__send__(method, @other)
          end
        end

        it 'should return false' do
          expect(@return).to be(false)
        end
      end

      describe 'when comparing to a resource with the same properties' do
        before do
          rescue_if @skip do
            @other  = @user_model.new(@user.attributes)
            @return = @user.__send__(method, @other)
          end
        end

        it 'should return true' do
          expect(@return).to be(true)
        end
      end
    end
  end

  it { expect(@user).to respond_to(:<=>) }

  describe '#<=>' do
    describe 'when the default order properties are equal with another resource' do
      before do
        rescue_if @skip && RUBY_VERSION < '1.9.2' do
          @other = @user_model.new(:name => 'dbussink')
          @return = @user <=> @other
        end
      end

      it 'should return 0' do
        expect(@return).to eq(0)
      end
    end

    describe 'when the default order property values are sorted before another resource' do
      before do
        rescue_if @skip && RUBY_VERSION < '1.9.2' do
          @other = @user_model.new(:name => 'c')
          @return = @user <=> @other
        end
      end

      it 'should return 1' do
        expect(@return).to eq(1)
      end
    end

    describe 'when the default order property values are sorted after another resource' do
      before do
        rescue_if @skip && RUBY_VERSION < '1.9.2' do
          @other = @user_model.new(:name => 'e')
          @return = @user <=> @other
        end
      end

      it 'should return -1' do
        expect(@return).to eq(-1)
      end
    end

    describe 'when comparing an unrelated type of Object' do
      it 'should raise an exception' do
        expect { @user <=> @comment_model.new }.to raise_error(ArgumentError, "Cannot compare a #{@comment_model} instance with a #{@user_model} instance")
      end
    end
  end

  it { expect(@user).to respond_to(:attribute_get) }

  describe '#attribute_get' do

    it { expect(@user.attribute_get(:name)).to eq('dbussink') }

  end

  it { expect(@user).to respond_to(:attribute_set) }

  describe '#attribute_set' do

    before { @user.attribute_set(:name, 'dkubb') }

    it { expect(@user.name).to eq('dkubb') }

  end

  it { expect(@user).to respond_to(:attributes) }

  describe '#attributes' do
    describe 'with a new resource' do
      before do
        rescue_if @skip do
          @user = @user.model.new
        end
      end

      it 'should return the expected values' do
        expect(@user.attributes).to eq({})
      end
    end

    describe 'with a new resource with a property set' do
      before do
        rescue_if @skip do
          @user = @user.model.new
          @user.name = 'dbussink'
        end
      end

      it 'should return the expected values' do
        expect(@user.attributes).to eq({:name => 'dbussink'})
      end
    end

    describe 'with a saved resource' do
      it 'should return the expected values' do
        expect(Ardm::Ext::Hash.only(@user.attributes, :name, :description, :age)).to eq(
          { :name => 'dbussink', :description => 'Test', :age => 25 }
        )
      end
    end
  end

  it { expect(@user).to respond_to(:attributes=) }

  describe '#attributes=' do
    describe 'when a public mutator is specified' do
      before do
        rescue_if @skip do
          @user.attributes = { :name => 'dkubb' }
        end
      end

      it 'should set the value' do
        expect(@user.name).to eql('dkubb')
      end
    end

    describe 'when a non-public mutator is specified' do
      it 'should raise an exception' do
        expect {
          @user.attributes = { :admin => true }
        }.to raise_error(ArgumentError, "The attribute \'admin\' is not accessible in #{@user_model}")
      end
    end
  end

  [ :destroy, :destroy! ].each do |method|
    it { expect(@user).to respond_to(:destroy) }

    describe "##{method}" do
      describe 'on a single resource' do
        before do
          @resource = @user_model.create(:name => 'hacker', :age => 20, :comment => @comment)

          @return = @resource.__send__(method)
        end

        it 'should successfully remove a resource' do
          expect(@return).to be(true)
        end

        it 'should mark the destroyed resource as readonly' do
          expect(@resource).to be_readonly
        end

        it "should return true when calling #{method} on a destroyed resource" do
          expect(@resource.__send__(method)).to be(true)
        end

        it 'should remove resource from persistent storage' do
          expect(@user_model.get(*@resource.key)).to be_nil
        end
      end

      describe 'with has relationship resources' do
        it 'should raise an exception'
      end
    end
  end

  it { expect(@user).to respond_to(:dirty?) }

  describe '#dirty?' do
    describe 'on a record, with dirty attributes' do
      before { @user.age = 100 }

      it { expect(@user).to be_dirty }
    end

    describe 'on a record, with no dirty attributes, and dirty parents' do
      before do
        rescue_if @skip do
          expect(@user).not_to be_dirty

          parent = @user.parent = @user_model.new(:name => 'Parent')
          expect(parent).to be_dirty
        end
      end

      it { expect(@user).to be_dirty }
    end

    describe 'on a record, with no dirty attributes, and dirty children' do
      before do
        rescue_if @skip do
          expect(@user).not_to be_dirty

          child = @user.children.new(:name => 'Child')
          expect(child).to be_dirty
        end
      end

      it { expect(@user).to be_dirty }
    end

    describe 'on a record, with no dirty attributes, and dirty siblings' do
      before do
        rescue_if @skip do
          expect(@user).not_to be_dirty

          parent = @user_model.create(:name => 'Parent', :comment => @comment)
          expect(parent).not_to be_dirty

          @user.update(:parent => parent)
          expect(@user).not_to be_dirty

          sibling = parent.children.new(:name => 'Sibling')
          expect(sibling).to be_dirty
          expect(parent).to be_dirty
        end
      end

      it { expect(@user).not_to be_dirty }
    end

    describe 'on a saved record, with no dirty attributes' do
      it { expect(@user).not_to be_dirty }
    end

    describe 'on a new record, with no dirty attributes, no default attributes, and no identity field' do
      before { @user = @user_model.new }

      it { expect(@user).not_to be_dirty }
    end

    describe 'on a new record, with no dirty attributes, no default attributes, and an identity field' do
      before { @comment = @comment_model.new }

      it { expect(@comment).to be_dirty }
    end

    describe 'on a new record, with no dirty attributes, default attributes, and no identity field' do
      before { @default = Default.new }

      it { expect(@default).to be_dirty }
    end

    describe 'on a record with itself as a parent (circular dependency)' do
      before do
        rescue_if @skip do
          @user.parent = @user
        end
      end

      it 'should not raise an exception' do
        expect {
          expect(@user.dirty?).to be(true)
        }.not_to raise_error
      end
    end

    describe 'on a record with itself as a child (circular dependency)' do
      before do
        rescue_if @skip do
          @user.children = [ @user ]
        end
      end

      it 'should not raise an exception' do
        expect {
          expect(@user.dirty?).to be(true)
        }.not_to raise_error
      end
    end

    describe 'on a record with a parent as a child (circular dependency)' do
      before do
        rescue_if @skip do
          @user.children = [ @user.parent = @user_model.new(:name => 'Parent', :comment => @comment) ]
          expect(@user.save).to be(true)
        end
      end

      it 'should not raise an exception' do
        expect {
          expect(@user.dirty?).to be(true)
        }.not_to raise_error
      end
    end
  end

  it { expect(@user).to respond_to(:eql?) }

  describe '#eql?' do
    describe 'when comparing to the same resource' do
      before do
        @other  = @user
        @return = @user.eql?(@other)
      end

      it 'should return true' do
        expect(@return).to be(true)
      end
    end

    describe 'when comparing to an resource that does not respond to model' do
      before do
        @other  = Object.new
        @return = @user.eql?(@other)
      end

      it 'should return false' do
        expect(@return).to be(false)
      end
    end

    describe 'when comparing to a resource with the same properties, but the model is a subclass' do
      before do
        rescue_if @skip do
          @other  = @author_model.new(@user.attributes)
          @return = @user.eql?(@other)
        end
      end

      it 'should return false' do
        expect(@return).to be(false)
      end
    end

    describe 'when comparing to a resource with a different key' do
      before do
        @other  = @user_model.create(:name => 'dkubb', :age => 33, :comment => @comment)
        @return = @user.eql?(@other)
      end

      it 'should return false' do
        expect(@return).to be(false)
      end
    end

    describe 'when comparing to a resource with the same repository, key and neither self or the other resource is dirty' do
      before do
        rescue_if @skip do
          @other  = @user_model.get(*@user.key)
          @return = @user.eql?(@other)
        end
      end

      it 'should return true' do
        expect(@return).to be(true)
      end
    end

    describe 'when comparing to a resource with the same repository, key but either self or the other resource is dirty' do
      before do
        rescue_if @skip do
          @user.age = 20
          @other  = @user_model.get(*@user.key)
          @return = @user.eql?(@other)
        end
      end

      it 'should return false' do
        expect(@return).to be(false)
      end
    end

    describe 'when comparing to a resource with the same properties' do
      before do
        rescue_if @skip do
          @other  = @user_model.new(@user.attributes)
          @return = @user.eql?(@other)
        end
      end

      it 'should return true' do
        expect(@return).to be(true)
      end
    end
  end

  it { expect(@user).to respond_to(:inspect) }

  describe '#inspect' do

    before do
      rescue_if @skip do
        @user = @user_model.get(*@user.key)
        @inspected = @user.inspect
      end
    end

    it { expect(@inspected).to match(/^#<#{@user_model}/) }

    it { expect(@inspected).to match(/name="dbussink"/) }

    it { expect(@inspected).to match(/age=25/) }

    it { expect(@inspected).to match(/description=<not loaded>/) }

  end

  it { expect(@user).to respond_to(:key) }

  describe '#key' do

    before do
      rescue_if @skip do
        @key = @user.key
        @user.name = 'dkubb'
      end
    end

    it { expect(@key).to be_kind_of(Array) }

    it 'should always return the key value persisted in the back end' do
      expect(@key.first).to eql("dbussink")
    end

    it { expect(@user.key).to eql(@key) }

  end

  it { expect(@user).to respond_to(:new?) }

  describe '#new?' do

    describe 'on an existing record' do

      it { expect(@user).not_to be_new }

    end

    describe 'on a new record' do

      before { @user = @user_model.new }

      it { expect(@user).to be_new }

    end

  end

  it { expect(@user).to respond_to(:reload) }

  describe '#reload' do
    before do
      # reset the user for each spec
      rescue_if(@skip) do
        @user.update(:name => 'dbussink', :age => 25, :description => 'Test')
      end
    end

    subject { rescue_if(@skip) { @user.reload } }

    describe 'on a resource not persisted' do
      before do
        @user.attributes = { :description => 'Changed' }
      end

      it { is_expected.to be_kind_of(Ardm::Resource) }

      it { is_expected.to equal(@user) }

      it { is_expected.to be_clean }

      it 'reset the changed attributes' do
        expect(method(:subject)).to change(@user, :description).from('Changed').to('Test')
      end
    end

    describe 'on a resource where the key is changed, but not persisted' do
      before do
        @user.attributes = { :name => 'dkubb' }
      end

      it { is_expected.to be_kind_of(Ardm::Resource) }

      it { is_expected.to equal(@user) }

      it { is_expected.to be_clean }

      it 'reset the changed attributes' do
        expect(method(:subject)).to change(@user, :name).from('dkubb').to('dbussink')
      end
    end

    describe 'on a resource that is changed outside another resource' do
      before do
        rescue_if @skip do
          @user.clone.update(:description => 'Changed')
        end
      end

      it { is_expected.to be_kind_of(Ardm::Resource) }

      it { is_expected.to equal(@user) }

      it { is_expected.to be_clean }

      it 'should reload the resource from the data store' do
        expect(method(:subject)).to change(@user, :description).from('Test').to('Changed')
      end
    end

    describe 'on an anonymous resource' do
      before do
        rescue_if @skip do
          @user = @user.model.first(:fields => [ :description ])
          expect(@user.description).to eq('Test')
        end
      end

      it { is_expected.to be_kind_of(Ardm::Resource) }

      it { is_expected.to equal(@user) }

      it { is_expected.to be_clean }

      it 'should not reload any attributes' do
        expect(method(:subject)).not_to change(@user, :attributes)
      end
    end
  end

  it { expect(@user).to respond_to(:readonly?) }

  describe '#readonly?' do
    describe 'on a new resource' do
      before do
        rescue_if @skip do
          @user = @user.model.new
        end
      end

      it 'should return false' do
        expect(@user.readonly?).to be(false)
      end
    end

    describe 'on a saved resource' do
      before do
        rescue_if @skip do
          expect(@user).to be_saved
        end
      end

      it 'should return false' do
        expect(@user.readonly?).to be(false)
      end
    end

    describe 'on a destroyed resource' do
      before do
        rescue_if @skip do
          expect(@user.destroy).to be(true)
        end
      end

      it 'should return true' do
        expect(@user.readonly?).to be(true)
      end
    end

    describe 'on an anonymous resource' do
      before do
        rescue_if @skip do
          # load the user without a key
          @user = @user.model.first(:fields => @user_model.properties - @user_model.key)
        end
      end

      it 'should return true' do
        expect(@user.readonly?).to be(true)
      end
    end
  end

  [ :save, :save! ].each do |method|
    it { expect(@user).to respond_to(method) }

    describe "##{method}" do
      before do
        @user_model.class_eval do
          attr_accessor :save_hook_call_count

          before :save do
            @save_hook_call_count ||= 0
            @save_hook_call_count += 1
          end
        end
      end

      describe 'on a new, not dirty resource' do
        before do
          @user = @user_model.new
          @return = @user.__send__(method)
        end

        it 'should return false' do
          expect(@return).to be(false)
        end

        it 'should call save hook expected number of times' do
          expect(@user.save_hook_call_count).to be_nil
        end
      end

      describe 'on a not new, not dirty resource' do
        before do
          rescue_if @skip do
            @return = @user.__send__(method)
          end
        end

        it 'should return true even when resource is not dirty' do
          expect(@return).to be(true)
        end

        it 'should call save hook expected number of times' do
          expect(@user.save_hook_call_count).to be_nil
        end
      end

      describe 'on a not new, dirty resource' do
        before do
          rescue_if @skip do
            @user.age = 26
            @return = @user.__send__(method)
          end
        end

        it 'should save a resource succesfully when dirty' do
          expect(@return).to be(true)
        end

        it 'should actually store the changes to persistent storage' do
          expect(@user.attributes).to eq(@user.reload.attributes)
        end

        it 'should call save hook expected number of times' do
          expect(@user.save_hook_call_count).to eq(method == :save ? 1 : nil)
        end
      end

      describe 'on a new, invalid resource' do
        before do
          @user = @user_model.new(:name => nil)
          expect { @user.__send__(method) }.to(raise_error(Ardm::Property::InvalidValueError) do |error|
            expect(error.property).to eq(@user_model.properties[:name])
          end)
        end

        it 'should call save hook expected number of times' do
          expect(@user.save_hook_call_count).to eq(method == :save ? 1 : nil)
        end
      end

      describe 'on a dirty invalid resource' do
        before do
          rescue_if @skip do
            @user.name = nil
          end
        end

        it 'should not save an invalid resource' do
          expect { @user.__send__(method) }.to(raise_error(Ardm::Property::InvalidValueError) do |error|
            expect(error.property).to eq(@user_model.properties[:name])
          end)
        end

        it 'should call save hook expected number of times' do
          expect(@user.save_hook_call_count).to eq(method == :save ? 1 : nil)
        end
      end

      describe 'with new resources in a has relationship' do
        before do
          rescue_if 'TODO: fix for one to one association', !@user.respond_to?(:comments) do
            @initial_comments = @user.comments.size
            @first_comment    = @user.comments.new(:body => "DM is great!")
            @second_comment   = @comment_model.new(:user => @user, :body => "is it really?")
            @return           = @user.__send__(method)
          end
        end

        it 'should save resource' do
          if @user.respond_to?(:comments)
            expect(@return).to be(true)
          end
        end

        it 'should save the first resource created through new' do
          if @user.respond_to?(:comments)
            expect(@first_comment.new?).to be(false)
          end
        end

        it 'should save the correct foreign key for the first resource' do
          if @user.respond_to?(:comments)
            expect(@first_comment.user).to eql(@user)
          end
        end

        it 'should save the second resource created through the constructor' do
          skip "Changing a belongs_to parent should add the resource to the correct association" do
            expect(@second_comment.new?).to be(false)
          end
        end

        it 'should save the correct foreign key for the second resource' do
          if @user.respond_to?(:comments)
            expect(@second_comment.user).to eql(@user)
          end
        end

        it 'should create 2 extra resources in persistent storage' do
          skip "Changing a belongs_to parent should add the resource to the correct association" do
            expect(@user.comments.size).to eq(@initial_comments + 2)
          end
        end
      end

      describe 'with dirty resources in a has relationship' do
        before do
          rescue_if 'TODO: fix for one to one association', !@user.respond_to?(:comments) do
            @first_comment  = @user.comments.create(:body => 'DM is great!')
            @second_comment = @comment_model.create(:user => @user, :body => 'is it really?')

            @first_comment.body  = 'It still has rough edges'
            @second_comment.body = 'But these cool specs help fixing that'
            @second_comment.user = @user_model.create(:name => 'dkubb')

            @return = @user.__send__(method)
          end
        end

        it 'should return true' do
          if @user.respond_to?(:comments)
            expect(@return).to be(true)
          end
        end

        it 'should not be dirty' do
          expect(@user).not_to be_dirty
        end

        it 'should have saved the first child resource' do
          if @user.respond_to?(:comments)
            expect(@first_comment.model.get(*@first_comment.key).body).to eq('It still has rough edges')
          end
        end

        it 'should not have saved the second child resource' do
          if @user.respond_to?(:comments)
            expect(@second_comment.model.get(*@second_comment.key).body).to eq('is it really?')
          end
        end
      end

      describe 'with a new dependency' do
        before do
          @first_comment      = @comment_model.new(:body => "DM is great!")
          @first_comment.user = @user_model.new(:name => 'dkubb')
        end

        it 'should not raise an exception when saving the resource' do
          skip do
            expect { expect(@first_comment.send(method)).to be(false) }.not_to raise_error
          end
        end
      end

      describe 'with a dirty dependency' do
        before do
          rescue_if @skip do
            @user.name = 'dbussink-the-second'

            @first_comment = @comment_model.new(:body => 'DM is great!')
            @first_comment.user = @user

            @return = @first_comment.__send__(method)
          end
        end

        it 'should succesfully save the resource' do
          expect(@return).to be(true)
        end

        it 'should not have a dirty dependency' do
          expect(@user).not_to be_dirty
        end

        it 'should succesfully save the dependency' do
          expect(@user.name).to eq(@user_model.get(*@user.key).name)
        end
      end

      describe 'with a new resource and new relations' do
        before do
          @article = @article_model.new(:body => "Main")
          rescue_if 'TODO: fix for one to one association', (!@article.respond_to?(:paragraphs)) do
            @paragraph = @article.paragraphs.new(:text => 'Content')

            @article.__send__(method)
          end
        end

        it 'should not be dirty' do
          if @article.respond_to?(:paragraphs)
            expect(@article).not_to be_dirty
          end
        end

        it 'should not be dirty' do
          if @article.respond_to?(:paragraphs)
            expect(@paragraph).not_to be_dirty
          end
        end

        it 'should set the related resource' do
          if @article.respond_to?(:paragraphs)
            expect(@paragraph.article).to eq(@article)
          end
        end

        it 'should set the foreign key properly' do
          if @article.respond_to?(:paragraphs)
            expect(@paragraph.article_id).to eq(@article.id)
          end
        end
      end

      describe 'with a dirty resource with a changed key' do
        before do
          rescue_if @skip do
            @original_key = @user.key
            @user.name = 'dkubb'
            @return = @user.__send__(method)
          end
        end

        it 'should save a resource succesfully when dirty' do
          expect(@return).to be(true)
        end

        it 'should actually store the changes to persistent storage' do
          expect(@user.name).to eq(@user.reload.name)
        end

        it 'should update the identity map' do
          expect(@user.repository.identity_map(@user_model)).to have_key(%w[ dkubb ])
        end

        it 'should remove the old entry from the identity map' do
          expect(@user.repository.identity_map(@user_model)).not_to have_key(@original_key)
        end
      end

      describe 'on a new resource with unsaved parent and grandparent' do
        before do
          @grandparent = @user_model.new(:name => 'dkubb',       :comment => @comment)
          @parent      = @user_model.new(:name => 'ashleymoran', :comment => @comment, :referrer => @grandparent)
          @child       = @user_model.new(:name => 'mrship',      :comment => @comment, :referrer => @parent)

          @response = @child.__send__(method)
        end

        it 'should return true' do
          expect(@response).to be(true)
        end

        it 'should save the child' do
          expect(@child).to be_saved
        end

        it 'should save the parent' do
          expect(@parent).to be_saved
        end

        it 'should save the grandparent' do
          expect(@grandparent).to be_saved
        end

        it 'should relate the child to the parent' do
          expect(@child.model.get(*@child.key).referrer).to eq(@parent)
        end

        it 'should relate the parent to the grandparent' do
          expect(@parent.model.get(*@parent.key).referrer).to eq(@grandparent)
        end

        it 'should relate the grandparent to nothing' do
          expect(@grandparent.model.get(*@grandparent.key).referrer).to be_nil
        end
      end

      describe 'on a destroyed resource' do
        before do
          rescue_if @skip do
            @user.destroy
          end
        end

        it 'should raise an exception' do
          expect {
            @user.__send__(method)
          }.to raise_error(Ardm::PersistenceError, "#{@user.model}##{method} cannot be called on a destroyed resource")
        end
      end

      describe 'on a record with itself as a parent (circular dependency)' do
        before do
          rescue_if @skip do
            @user.parent = @user
          end
        end

        it 'should not raise an exception' do
          expect {
            expect(@user.__send__(method)).to be(true)
          }.not_to raise_error
        end
      end

      describe 'on a record with itself as a child (circular dependency)' do
        before do
          rescue_if @skip do
            @user.children = [ @user ]
          end
        end

        it 'should not raise an exception' do
          expect {
            expect(@user.__send__(method)).to be(true)
          }.not_to raise_error
        end
      end

      describe 'on a record with a parent as a child (circular dependency)' do
        before do
          rescue_if @skip do
            @user.children = [ @user.parent = @user_model.new(:name => 'Parent', :comment => @comment) ]
          end
        end

        it 'should not raise an exception' do
          expect {
            expect(@user.__send__(method)).to be(true)
          }.not_to raise_error
        end
      end
    end
  end

  it { expect(@user).to respond_to(:saved?) }

  describe '#saved?' do

    describe 'on an existing record' do

      it { expect(@user).to be_saved }

    end

    describe 'on a new record' do

      before { @user = @user_model.new }

      it { expect(@user).not_to be_saved }

    end

  end

  [ :update, :update! ].each do |method|
    it { expect(@user).to respond_to(method) }

    describe "##{method}" do
      describe 'with attributes' do
        before do
          rescue_if @skip do
            @attributes = { :description => 'Changed' }
            @return = @user.__send__(method, @attributes)
          end
        end

        it 'should return true' do
          expect(@return).to be(true)
        end

        it 'should update attributes of Resource' do
          @attributes.each { |key, value| expect(@user.__send__(key)).to eq(value) }
        end

        it 'should persist the changes' do
          resource = @user_model.get(*@user.key)
          @attributes.each { |key, value| expect(resource.__send__(key)).to eq(value) }
        end
      end

      describe 'with attributes where one is a parent association' do
        before do
          rescue_if @skip do
            @attributes = { :referrer => @user_model.create(:name => 'dkubb', :age => 33, :comment => @comment) }
            @return = @user.__send__(method, @attributes)
          end
        end

        it 'should return true' do
          expect(@return).to be(true)
        end

        it 'should update attributes of Resource' do
          @attributes.each { |key, value| expect(@user.__send__(key)).to eq(value) }
        end

        it 'should persist the changes' do
          resource = @user_model.get(*@user.key)
          @attributes.each { |key, value| expect(resource.__send__(key)).to eq(value) }
        end
      end

      describe 'with attributes where a value is nil for a property that does not allow nil' do
        before do
          expect { @user.__send__(method, :name => nil) }.to(raise_error(Ardm::Property::InvalidValueError) do |error|
            expect(error.property).to eq(@user_model.properties[:name])
          end)
        end

        it 'should not persist the changes' do
          expect(@user.reload.name).not_to be_nil
        end
      end

      describe 'on a new resource' do
        before do
          rescue_if @skip do
            @user = @user.model.new(@user.attributes)
            @user.age = 99
          end
        end

        it 'should raise an exception' do
          expect {
            @user.__send__(method, :admin => true)
          }.to raise_error(Ardm::UpdateConflictError, "#{@user.model}##{method} cannot be called on a new resource")
        end
      end

      describe 'on a dirty resource' do
        before do
          rescue_if @skip do
            @user.age = 99
          end
        end

        it 'should raise an exception' do
          expect {
            @user.__send__(method, :admin => true)
          }.to raise_error(Ardm::UpdateConflictError, "#{@user.model}##{method} cannot be called on a dirty resource")
        end
      end
    end
  end

  describe 'lazy loading' do
    before do
      rescue_if @skip do
        @user.name    = 'dkubb'
        @user.age     = 33
        @user.summary = 'Programmer'

        # lazy load the description
        @user.description
      end
    end

    it 'should not overwrite dirty attribute' do
      expect(@user.age).to eq(33)
    end

    it 'should not overwrite dirty lazy attribute' do
      expect(@user.summary).to eq('Programmer')
    end

    it 'should not overwrite dirty key' do
      skip do
        expect(@user.name).to eq('dkubb')
      end
    end
  end
end
