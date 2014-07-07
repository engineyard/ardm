require 'spec_helper'

try_spec do
  require './spec/fixtures/api_user'

  describe Ardm::Fixtures::APIUser do
    subject { described_class.new(:name => 'alice') }

    let(:original_api_key) { subject.api_key }

    it "should have a default value" do
      expect(original_api_key).not_to be_nil
    end

    it "should preserve the default value" do
      expect(subject.api_key).to eq(original_api_key)
    end

    it "should generate unique API Keys for each resource" do
      other_resource = described_class.new(:name => 'eve')

      expect(other_resource.api_key).not_to eq(original_api_key)
    end
  end
end
