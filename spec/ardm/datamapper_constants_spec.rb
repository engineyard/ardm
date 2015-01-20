require 'spec_helper'

describe Ardm::Ar::DataMapperConstantProxy do
  it 'defines Resource' do
    expect(described_class::Resource).to be_kind_of(Module)
  end

  it 'defines ObjectNotFoundError to ActiveRecord::RecordNotFound' do
    expect(described_class::ObjectNotFoundError).to be(ActiveRecord::RecordNotFound)
  end

  it 'defines SaveFailureError to ActiveRecord::RecordNotSaved' do
    expect(described_class::SaveFailureError).to be(ActiveRecord::RecordNotSaved)
  end

  it 'responds to finalize' do
    expect(described_class.respond_to?(:finalize)).to be_truthy
  end

  it 'responds to repository' do
    expect(described_class.respond_to?(:repository)).to be_truthy
  end

  it 'responds to logger' do
    expect(described_class.respond_to?(:logger)).to be_truthy
  end

  it 'responds to logger=' do
    expect(described_class.respond_to?(:logger=)).to be_truthy
  end
end
