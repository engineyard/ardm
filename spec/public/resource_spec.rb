require 'spec_helper'

describe Ardm::Record do
  require './spec/fixtures/resource_blog'

  before do
    @user_model      = ResourceBlog::User
    @author_model    = ResourceBlog::Author
    @comment_model   = ResourceBlog::Comment
    @article_model   = ResourceBlog::Article
    @paragraph_model = ResourceBlog::Paragraph

    user = @user_model.create!(:name => 'dbussink', :age => 25, :description => 'Test')

    @user = @user_model.get!(user.key)
  end

  # FIXME
  #it_should_behave_like 'A public Resource'
  #it_should_behave_like 'A Resource supporting Strategic Eager Loading'

  it 'A resource should respond to raise_on_save_failure' do
    expect(@user).to respond_to(:raise_on_save_failure)
  end

  describe '#raise_on_save_failure' do
    after do
      # reset to the default value
      reset_raise_on_save_failure(@user_model)
      reset_raise_on_save_failure(@user)
    end

    subject { @user.raise_on_save_failure }

    describe 'when model.raise_on_save_failure has not been set' do
      it { is_expected.to be_falsey }
    end

    describe 'when model.raise_on_save_failure has been set to true' do
      before do
        @user_model.raise_on_save_failure = true
      end

      it { is_expected.to be true }
    end

    describe 'when resource.raise_on_save_failure has been set to true' do
      before do
        @user.raise_on_save_failure = true
      end

      it { is_expected.to be true }
    end
  end

  it 'A model should respond to raise_on_save_failure=' do
    expect(@user_model).to respond_to(:raise_on_save_failure=)
  end

  describe '#raise_on_save_failure=' do
    after do
      # reset to the default value
      reset_raise_on_save_failure(@user_model)
    end

    describe 'with a true value' do
      subject { @user_model.raise_on_save_failure = true }

      it { is_expected.to be true }

      it 'should set raise_on_save_failure' do
        expect { subject }.to change {
          @user_model.raise_on_save_failure
        }.from(false).to(true)
      end
    end

    describe 'with a false value' do
      subject { @user_model.raise_on_save_failure = false }

      it { is_expected.to be false }

      it 'should set raise_on_save_failure' do
        expect { subject }.to_not change {
          @user_model.raise_on_save_failure
        }
      end
    end
  end

  [ :save, :save! ].each do |method|
    describe "##{method}" do
      subject { @user.__send__(method) }

      describe 'when raise_on_save_failure is true' do
        before do
          @user.raise_on_save_failure = true
        end

        describe 'and it is a savable resource' do
          it { is_expected.to be true }
        end

        # FIXME: We cannot trigger a failing save with invalid properties anymore.
        # Invalid properties will result in their own exception.
        # So Im mocking here, but a better approach is needed.

        describe 'and it is an invalid resource', pending: true do
          before do
            Ardm::Record.any_instance.stub(:save).and_return(false)
            expect(@user).to receive(:save_self).and_return(false)
          end

          it 'should raise an exception' do
            expect { subject }.to raise_error(Ardm::SaveFailureError, "Blog::User##{method} returned false, Blog::User was not saved") { |error|
              error.resource.should equal(@user)
            }
          end
        end
      end
    end
  end

  [ :update, :update! ].each do |method|
    describe 'with attributes where one is a foreign key', :pending => "#relationships not needed" do
      before do
        @dkubb = @user_model.create(:name => 'dkubb', :age => 33)
        @user.referrer = @dkubb
        @user.save
        @user = @user_model.get(@user.key)
        expect(@user.referrer).to eq(@dkubb)

        @solnic = @user_model.create(:name => 'solnic', :age => 28)

        @attributes = {}

        relationship = @user_model.relationships[:referrer]

        # Original datamapper implementation:
        #relationship.child_key.to_a.each_with_index do |k, i|
        #  @attributes[k.name] = relationship.parent_key.to_a[i].get(@solnic)
        #end

        # #key returns an array even though there's only one value.
        @attributes[relationship.foreign_key] = @solnic.key.first

        @return = @user.__send__(method, @attributes)
      end

      it 'should return true' do
        expect(@return).to be true
      end

      it 'should update attributes of Resource' do
        @attributes.each { |key, value| expect(@user.__send__(key)).to eq(value) }
      end

      it 'should persist the changes' do
        resource = @user_model.get(@user.key)
        @attributes.each { |key, value| expect(resource.__send__(key)).to eq(value) }
      end

      it 'should return correct parent' do
        resource = @user_model.get(@user.key)
        expect(resource.referrer).to eq(@solnic)
      end
    end
  end

  describe '#attribute_get' do
    subject { object.attribute_get(name) }

    let(:object) { @user }

    context 'with a known property' do
      let(:name) { :name }

      it 'returns the attribute value' do
        is_expected.to eq('dbussink')
      end
    end

    context 'with an unknown property' do
      let(:name) { :unknown }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end

  describe '#attribute_set' do
    subject { object.attribute_set(name, value) }

    let(:object) { @user.clone }

    context 'with a known property' do
      let(:name)  { :name   }
      let(:value) { 'dkubb' }

      it 'sets the attribute' do
        expect { subject }.to change { object.name }.from('dbussink').to('dkubb')
      end

      it 'makes the object dirty' do
        expect { subject }.to change { object.dirty? }.from(false).to(true)
      end
    end

    context 'with an unknown property' do
      let(:name)  { :unknown              }
      let(:value) { double('Unknown Value') }

      it 'does not set the attribute' do
        expect { subject }.to_not change { object.attributes.dup }
      end

      it 'does not make the object dirty' do
        expect { subject }.to_not change { object.dirty? }
      end
    end
  end
end
