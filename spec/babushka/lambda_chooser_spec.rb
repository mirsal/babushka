require 'spec_support'


describe "lambda choosing" do
  it "should return the value of the block when there are no choices" do
    LambdaChooser.new(nil, :ours, :theirs) {
      "block value"
    }.choose(:ours, :on).should == "block value"
  end

  it "should choose the specified call" do
    LambdaChooser.new(nil, :ours, :theirs) {
      on :ours, "this is ours"
      on :theirs, "this is theirs"
    }.choose(:ours, :on).should == ["this is ours"]
    describe "with a block value" do
      LambdaChooser.new(nil, :ours, :theirs) {
        on :ours, "this is ours"
        on :theirs, "this is theirs"
        "block value"
      }.choose(:ours, :on).should == ["this is ours"]
    end
  end

  it "should pick the first choice from multiple choices" do
    LambdaChooser.new(nil, :ours, :yours, :theirs) {
      on :ours, "this is ours"
      on :yours, "this is yours"
      on :theirs, "this is theirs"
    }.choose([:ours, :yours], :on).should == ["this is ours"]
    LambdaChooser.new(nil, :ours, :yours, :theirs) {
      on :yours, "this is yours"
      on :ours, "this is ours"
      on :theirs, "this is theirs"
    }.choose([:ours, :yours], :on).should == ["this is ours"]
  end

  it "should default the choice method to #on" do
    LambdaChooser.new(nil, :ours, :theirs) {
      on :ours, "this is ours"
      on :theirs, "this is theirs"
    }.choose(:ours).should == ["this is ours"]
    LambdaChooser.new(nil, :ours, :theirs) {
      on :ours, "this is ours"
      on :theirs, "this is theirs"
    }.choose(:ours, nil).should == ["this is ours"]
  end

  it "should reject values and block together" do
    L{
      LambdaChooser.new(nil, :ours, :theirs) {
        on :ours, "this is ours"
        on :theirs, "this is theirs" do
          'another value'
        end
      }.choose(:ours, :on)
    }.should raise_error("You can supply values or a block, but not both.")
  end

  it "should reject unknown choosers" do
    L{
      LambdaChooser.new(nil, :ours, :theirs) {
        on :ours, "this is ours"
        on :someone_elses, "this is theirs"
      }.choose(:ours, :on)
    }.should raise_error("The choice 'someone_elses' isn't valid.")
  end

  it "should return the data intact" do
    {
      "string" => ["string"],
      %w[a r r a y] => %w[a r r a y],
      {:h => 'a', :s => 'h'} => {:h => 'a', :s => 'h'}
    }.each_pair {|input, expected|
      LambdaChooser.new(nil, :ours, :theirs) {
        on :ours, input
        on :theirs, "this is theirs"
      }.choose(:ours, :on).should == expected
    }
  end
end
