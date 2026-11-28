# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../fixtures/blood_pressure_builder'

# #151, resolution shape (a) bug: an absent ORDER BY value (nil) sorts
# after every real value whatever the direction (NULLS LAST, as the
# comment on Engine#compare_values says). compare_bindings negated the
# whole comparison for DESC, nil included, so DESC put those rows first.
# Written red-first against master eeb7341.
describe 'OpenEHR::AQL ORDER BY puts absent values last (#151)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  # The body temperature composition has no systolic value.
  let(:dataset) do
    OpenEHR::AQL::Dataset.of_compositions(
      [builder.body_temperature_composition,
       builder.blood_pressure_composition(systolic: 110, diastolic: 70),
       builder.blood_pressure_composition(systolic: 150, diastolic: 90)]
    )
  end

  def systolic = 'c/content[openEHR-EHR-OBSERVATION.blood_pressure.v1]/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude'

  def rows(order_by)
    OpenEHR::AQL.execute("SELECT #{systolic} AS s FROM EHR e CONTAINS COMPOSITION c ORDER BY #{order_by}", dataset).rows
  end

  # regression pin: ASC already put nil last before #151.
  it 'ASC puts the row without the value last' do
    expect(rows("#{systolic} ASC")).to eq [[110], [150], [nil]]
  end

  it 'DESC puts the row without the value last' do
    expect(rows("#{systolic} DESC")).to eq [[150], [110], [nil]]
  end

  # All three compositions share one start_time, so the second key decides.
  it 'DESC on a second key puts the row without the value last' do
    expect(rows("c/context/start_time/value, #{systolic} DESC")).to eq [[150], [110], [nil]]
  end

  # regression pin: ASC on a second key already put nil last before #151.
  it 'ASC on a second key puts the row without the value last' do
    expect(rows("c/context/start_time/value, #{systolic}")).to eq [[110], [150], [nil]]
  end
end
