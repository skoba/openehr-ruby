require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::URI

describe DvUri do
  before(:each) do
    @dv_uri = DvUri.new(:value => 
                        "http://www.openehr.jp/changeset/test?cmd=93#file0")
  end

  it 's fragment_id should be file0' do
    @dv_uri.fragment_id.should == 'file0'
  end

  it 's path should be /changeset/test' do
    @dv_uri.path.should == '/changeset/test'
  end

  it 's query should be cmd=93' do
    @dv_uri.query.should == 'cmd=93'
  end

  it 's scheme should be http' do
    @dv_uri.scheme.should == 'http'
  end

  it 's value should be http://www.openehr.jp/changeset/test?cmd=93#file0' do
    @dv_uri.value.should == 'http://www.openehr.jp/changeset/test?cmd=93#file0'
  end

  it 's value change' do
    lambda {
      @dv_uri.value="svn://www.openehr.jp/openehr-jp/"
    }.should change(@dv_uri, :value).to('svn://www.openehr.jp/openehr-jp/')
  end
end

