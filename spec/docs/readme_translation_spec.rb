# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'

# #145 (R-20261127-28), resolution shape (c) pin/hardening: README.ja.rdoc
# is the Japanese translation of README.rdoc. A PR that changes the README
# fixes the translation in the same PR (CLAUDE.md); this spec keeps the
# two from drifting apart in their structure. regression pin: the property
# is created by the same PR that adds this spec, so it was red only
# because README.ja.rdoc did not exist yet.
describe 'README translation (#145)' do
  def readme(name)
    path = File.expand_path("../../#{name}", __dir__)
    File.exist?(path) ? File.read(path, encoding: 'UTF-8') : ''
  end

  # An RDoc heading is a line starting with '='.
  def headings(text) = text.lines.grep(/\A=+/)

  let(:english) { readme('README.rdoc') }
  let(:japanese) { readme('README.ja.rdoc') }

  it 'has a non-empty English and Japanese README' do
    expect(english.strip).not_to be_empty
    expect(japanese.strip).not_to be_empty
  end

  it 'links the English README to the Japanese one, near the top' do
    expect(english.lines.first(5).join).to include('README.ja.rdoc')
  end

  it 'links the Japanese README back to the English one, near the top' do
    expect(japanese.lines.first(5).join).to include('README.rdoc')
  end

  it 'says the Japanese README is a translation and the English one wins' do
    expect(japanese.lines.first(10).join).to include('英語版が正')
  end

  it 'has the same number of headings in both' do
    expect(headings(japanese).size).to eq(headings(english).size)
  end
end
