require File.dirname(__FILE__) + '/../../spec_helper'

describe OpenEHR::TerminologyService do
  after(:each) do
    OpenEHR::TerminologyService.provider = nil
  end

  describe 'default provider (no openehr-terminology gem installed)' do
    it 'valid_code? is permissive (always true)' do
      expect(OpenEHR::TerminologyService.valid_code?('ISO_639-1', 'not-a-real-code')).to be true
    end

    it 'has_code_for_group? is permissive (always true)' do
      expect(OpenEHR::TerminologyService.has_code_for_group?('composition category', '999999')).to be true
    end
  end

  describe 'a plugged-in provider' do
    let(:strict_provider) do
      Class.new do
        def valid_code?(terminology_id, code)
          terminology_id == 'ISO_639-1' && %w[en ja].include?(code)
        end

        def has_code_for_group?(group_id, code)
          group_id == 'composition category' && code == '433'
        end
      end.new
    end

    before(:each) { OpenEHR::TerminologyService.provider = strict_provider }

    it 'delegates valid_code? to the provider' do
      expect(OpenEHR::TerminologyService.valid_code?('ISO_639-1', 'en')).to be true
      expect(OpenEHR::TerminologyService.valid_code?('ISO_639-1', 'xx')).to be false
    end

    it 'delegates has_code_for_group? to the provider' do
      expect(OpenEHR::TerminologyService.has_code_for_group?('composition category', '433')).to be true
      expect(OpenEHR::TerminologyService.has_code_for_group?('composition category', '999')).to be false
    end
  end
end
