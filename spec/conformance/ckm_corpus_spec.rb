require File.dirname(__FILE__) + '/../spec_helper'

# #56 - resolution shape (b) enhancement: an opt-in conformance smoke that
# parses every CKM archetype export in CKM_CORPUS_DIR and fails, per file,
# on any exception. Red was produced against a scratch directory holding
# one deliberately broken export (1 of 2 failed, naming the file), and
# against the v2.4.2 parser over the pinned 41-file reference corpus
# (9 failures, every one attributable to #50/#51/#52); green on master
# >= 2.4.3 (41/41) - see docs/reports/ckm-conformance-log.md R8.
#
# Corpus: not copied into this repo. README.md next to this file gives the
# pointer (skoba/openehr-japanese-translation) and the fetch procedure.
#
# Any exception, not only ParseError: #52's failure was an ArgumentError
# raised from an RM constructor during the build phase, after the grammar
# had accepted the text.
#
# With CKM_CORPUS_DIR unset the group contributes exactly one pending
# example, so the default `bundle exec rspec` stays hermetic and offline.
RSpec.describe OpenEHR::Parser::ADLParser do
  corpus_dir = ENV.fetch('CKM_CORPUS_DIR', '')

  if corpus_dir.empty?
    it 'parses every archetype of the CKM reference corpus' do
      skip 'set CKM_CORPUS_DIR=<dir of CKM *.adl exports> to run ' \
           '(see spec/conformance/README.md)'
    end
  else
    files = Dir[File.join(corpus_dir, '*.adl')] # Dir[] is sorted (Ruby >= 3.0)
    # A misspelt path must not look like a green run.
    raise ArgumentError, "CKM_CORPUS_DIR=#{corpus_dir}: no *.adl files found" if files.empty?

    files.each do |file|
      it "parses #{File.basename(file)} without raising" do
        expect { described_class.new(file).parse }.not_to raise_error
      end
    end
  end
end
