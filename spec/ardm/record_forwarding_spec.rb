require 'spec_helper'
require 'ardm/data_mapper/record'

describe Ardm::DataMapper::Record do
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
