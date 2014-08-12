require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::URI

describe DvUri do
  before(:each) do
    @dv_uri = DvUri.new(:value => 
                        "http://www.openehr.jp/changeset/test?cmd=93#file0")
  end

  it 's fragment_id should be file0' do
    expect(@dv_uri.fragment_id).to eq('file0')
  end

  it 's path should be /changeset/test' do
    expect(@dv_uri.path).to eq('/changeset/test')
  end

  it 's query should be cmd=93' do
    expect(@dv_uri.query).to eq('cmd=93')
  end

  it 's scheme should be http' do
    expect(@dv_uri.scheme).to eq('http')
  end

  it 's value should be http://www.openehr.jp/changeset/test?cmd=93#file0' do
    expect(@dv_uri.value).to eq('http://www.openehr.jp/changeset/test?cmd=93#file0')
  end

  it 's value change' do
    expect {
      @dv_uri.value="svn://www.openehr.jp/openehr-jp/"
    }.to change(@dv_uri, :value).to('svn://www.openehr.jp/openehr-jp/')
  end
end

