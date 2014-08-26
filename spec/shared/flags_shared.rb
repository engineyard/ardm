shared_examples "A property with flags" do
  before do
    %w[ @property_klass ].each do |ivar|
      raise "+#{ivar}+ should be defined in before block" unless instance_variable_defined?(ivar)
    end

    @flags = [ :one, :two, :three ]

    class ::User < Ardm::Record
    end

    @property = User.property :item, @property_klass[@flags], :key => true
  end

  describe ".generated_classes" do
    it "should cache the generated class" do
      expect(@property_klass.generated_classes[@flags]).not_to be_nil
    end
  end

  it "should include :flags in accepted_options" do
    expect(@property_klass.accepted_options).to include(:flags)
  end

  it "should respond to :generated_classes" do
    expect(@property_klass).to respond_to(:generated_classes)
  end

  it "should respond to :flag_map" do
    expect(@property).to respond_to(:flag_map)
  end

  it "should be custom" do
    expect(@property.custom?).to be(true)
  end
end
