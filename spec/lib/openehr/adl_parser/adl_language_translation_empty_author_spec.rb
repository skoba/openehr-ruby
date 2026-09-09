require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

# #52 — resolution shape (a) bug: on master these examples went red with
# "ArgumentError: author is mandatory" (the dADL parser yields nil for an
# empty "author = < >" block and Language#translations= handed that nil
# straight to TranslationDetails), then green once the parser represents
# the empty block as an empty Hash. The RM invariant (author non-nil) is
# unchanged; only the accepting parser became tolerant.
#
# Fixture kind: reduced — the CKM export of
# openEHR-EHR-EVALUATION.problem_diagnosis.v1 (cid 1013.1.169, revision 1.7.4)
# with the language section kept verbatim and the description/ontology cut
# to English only (lineage in spec/fixtures/ckm/README.md). The triggering
# entry is the ["fi"] translation (lines 25-28 of both the source and the
# reduced file).
describe ADLParser do
  let(:ckm_fixture_dir) { File.expand_path('../../../fixtures/ckm', __dir__) }

  context 'a CKM archetype whose translation has an empty author block (#52)' do
    let(:adl_file) do
      File.join(ckm_fixture_dir, 'openEHR-EHR-EVALUATION.problem_diagnosis.v1.reduced.adl')
    end
    let(:archetype) { ADLParser.new(adl_file).parse }

    it 'parses instead of raising ArgumentError' do
      expect { archetype }.not_to raise_error
    end

    it 'represents the empty author as an empty Hash' do
      fi = archetype.translations['fi']
      expect(fi.language.code_string).to eq('fi')
      expect(fi.author).to eq({})
    end

    it 'keeps a populated translation author intact' do
      # Regression pin: populated authors already parsed before the #52 fix.
      de = archetype.translations['de']
      expect(de.author).to include('name', 'organisation')
    end
  end
end
