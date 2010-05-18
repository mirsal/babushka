require 'spec_support'
require 'version_str_support'

def compare_with operator
  pairs.zip(results[operator]).each {|pair,expected|
    result = VersionStr.new(pair.first).send operator, VersionStr.new(pair.last)
    it "#{pair.first} #{operator} #{pair.last}: #{result}" do
      result.should == expected
    end
  }
end

%w[== != > < >= <= ~>].each do |operator|
  describe operator do
    compare_with operator
  end
end

describe "comparing" do
  it "should work with other VersionStrs" do
    (VersionStr.new('0.3.1') > VersionStr.new('0.2.9')).should be_true
  end
  
  it "should work with strings" do
    (VersionStr.new('0.3.1') > '0.2.9').should be_true
  end
  
  it "should treat strings as less than no piece" do
    (VersionStr.new('3.0.0') > VersionStr.new('3.0.0.beta')).should be_true
  end
  
  it "should allow for integers in strings and sort correctly" do
    (
      VersionStr.new('3.0.0.beta12') > VersionStr.new('3.0.0.beta2')
    ).should be_true
  end
end

describe "parsing" do
  it "should parse the version number" do
    VersionStr.new('0.2').pieces.should == [0, 2]
    VersionStr.new('0.3.10.2').pieces.should == [0, 3, 10, 2]
    VersionStr.new('1.9.1-p243').pieces.should == [1, 9, 1, 'p243']
    VersionStr.new('3.0.0.beta').pieces.should == [3, 0, 0, 'beta']
    VersionStr.new('3.0.0.beta3').pieces.should == [3, 0, 0, 'beta3']
  end
  it "should parse the operator if supplied" do
    v = VersionStr.new('>= 0.2')
    v.pieces.should == [0, 2]
    v.operator.should == '>='

    v = VersionStr.new(' ~>  0.3.10.2')
    v.pieces.should == [0, 3, 10, 2]
    v.operator.should == '~>'
  end
  it "should convert = to ==" do
    v = VersionStr.new('= 0.2')
    v.pieces.should == [0, 2]
    v.operator.should == '=='

    v = VersionStr.new('== 0.2')
    v.pieces.should == [0, 2]
    v.operator.should == '=='
  end
  it "should reject invalid operators" do
    L{
      VersionStr.new('~ 0.2')
    }.should raise_error "Bad input: '~ 0.2'"

    L{
      VersionStr.new('>> 0.2')
    }.should raise_error "Bad input: '>> 0.2'"
  end
end

describe 'rendering' do
  it "should render just the version number with no operator" do
    VersionStr.new('0.3.1').to_s.should == '0.3.1'
  end
  it "should render the full string with an operator" do
    VersionStr.new('= 0.3.1').to_s.should == '= 0.3.1'
    VersionStr.new('== 0.3.1').to_s.should == '= 0.3.1'
    VersionStr.new('~> 0.3.1').to_s.should == '~> 0.3.1'
  end
  it "should keep string pieces" do
    VersionStr.new('3.0.0.beta').to_s.should == '3.0.0.beta'
  end
  it "should preserve the original formatting" do
    VersionStr.new('1.8.7-p174-src').to_s.should == '1.8.7-p174-src'
    VersionStr.new('3.0.0-beta').to_s.should == '3.0.0-beta'
  end
end
