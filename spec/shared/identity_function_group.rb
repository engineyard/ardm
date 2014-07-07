shared_examples_for "identity function" do
  it "returns value unchanged" do
    expect(@result).to eq(@input)
  end
end
