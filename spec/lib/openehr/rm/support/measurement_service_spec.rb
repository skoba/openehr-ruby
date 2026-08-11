require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Support::Measurement

# MeasurementService here is a minimal UCUM-lite syntactic checker, not
# a full UCUM parser/conversion table: it validates that a units string
# is *shaped* like a UCUM unit (allowed characters, balanced brackets)
# and treats "equivalent" as exact string equality of two
# syntactically-valid units strings. It does not do unit conversion
# (e.g. it will not recognize "kg" and "1000g" as equivalent).
describe MeasurementService do
  describe '.is_valid_units_string?' do
    it 'accepts common UCUM unit strings' do
      %w[mm[Hg] kg m/s2 mg/dL % Cel 1 10*3/uL].each do |units|
        expect(MeasurementService.is_valid_units_string?(units)).to be true
      end
    end

    it 'rejects nil and empty strings' do
      expect(MeasurementService.is_valid_units_string?(nil)).to be false
      expect(MeasurementService.is_valid_units_string?('')).to be false
    end

    it 'rejects strings with whitespace or disallowed characters' do
      expect(MeasurementService.is_valid_units_string?('mm Hg')).to be false
      expect(MeasurementService.is_valid_units_string?('kg;drop table')).to be false
    end

    it 'rejects unbalanced brackets' do
      expect(MeasurementService.is_valid_units_string?('mm[Hg')).to be false
      expect(MeasurementService.is_valid_units_string?('mm]Hg[')).to be false
    end
  end

  describe '.units_equivalent?' do
    it 'is true for identical, syntactically-valid units strings' do
      expect(MeasurementService.units_equivalent?('mm[Hg]', 'mm[Hg]')).to be true
    end

    it 'is false for different units strings (no unit conversion is performed)' do
      expect(MeasurementService.units_equivalent?('kg', '1000g')).to be false
    end

    it 'is false when either units string is invalid' do
      expect(MeasurementService.units_equivalent?('kg', '')).to be false
      expect(MeasurementService.units_equivalent?('', 'kg')).to be false
    end
  end
end
