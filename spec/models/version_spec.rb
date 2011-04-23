require 'spec_helper'

describe Version do
  before do
    @gem = Factory.create :rubygem
    @valid_attributes = {
      number: '1.0.0.0',
      rubygem: @gem,
      prerelease: false
    }
  end

  it "should accept valid attributes to create a new object" do
    Version.create! @valid_attributes
  end

  it 'should create the version even if prerelease is not supplied' do
    attrs = @valid_attributes.clone
    attrs.delete :prerelease
    v = Factory.build :version, attrs
    v.valid?.should be_true
    v.save.should be_true
    v.prerelease.should be_false
  end

  it 'should create a new version without prerelease defined' do
    attrs = @valid_attributes.clone
    attrs.delete :prerelease
    v = Version.new attrs
    v.save.should be_true
  end

  it 'should not create 2 of the same version #s within the scope of a rubygem' do
    Factory.create :version, number: '1.0.0', rubygem_id: @gem.id
    v = Factory.build :version, number: '1.0.0', rubygem_id: @gem.id
    v.save.should be_false
  end

  it 'should tag prerelease as false if supplied as nil' do
    t = Factory.build :version, prerelease: nil
    t.save
    t.prerelease.is_a?(FalseClass).should be_true
  end
  
  it 'should allow the same version #s outside the scope of a rubygem' do
    gem2 = Factory.create :rubygem
    Factory.create :version, number: '1.0.0', rubygem_id: @gem.id
    v = Factory.build :version, number: '1.0.0', rubygem_id: gem2.id
    v.save.should be_true
  end

  it 'should not allow a version without a number' do
    v = Factory.build :version, number: nil, rubygem: @gem
    v.save.should be_false
  end

  it 'should not allow a version with an empty number' do
    v = Factory.build :version, number: '', rubygem: @gem
    v.save.should be_false
  end
  
  it 'should not allow a version without a rubygem id' do
    v = Factory.build :version, rubygem: nil
    v.save.should be_false
  end

  it 'should count passes' do
    v = Factory.create :version, rubygem: @gem
    3.times { Factory.create :test_result, version: v, rubygem: @gem, result: true }
    2.times { Factory.create :test_result, version: v, rubygem: @gem, result: false }
    v.pass_count.should == 3
  end

  it 'should count failures' do
    v = Factory.create :version, rubygem: @gem
    1.times { Factory.create :test_result, version: v, rubygem: @gem, result: true }
    2.times { Factory.create :test_result, version: v, rubygem: @gem, result: false }
    v.fail_count.should == 2
  end

  it 'should sort properly with prerelease versions' do
    versions = []
    versions << Factory.create(:version, rubygem: @gem, number: '1.0')
    versions << Factory.create(:version, rubygem: @gem, number: '1.0rc', prerelease: true)
    versions.sort.first.number.should == '1.0rc'
  end
end
