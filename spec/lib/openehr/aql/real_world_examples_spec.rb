require File.dirname(__FILE__) + '/../../../spec_helper'

# Real-world AQL queries, as opposed to the official spec's own textbook
# examples in examples_spec.rb. Production AQL exercises the grammar far
# more thoroughly than the spec's illustrative queries do (deep nodePredicate
# combinations, cross-path comparisons, boolean predicate groups, etc.), so
# this corpus exists to surface parser gaps the spec examples don't reach.
#
# Sources (both Apache License 2.0; verified against each repository's
# LICENSE file and, for the first source, the test file's own header):
#
# - Queries labelled "SDK:<methodName>" are copied verbatim from the query
#   string literals in AqlQueryParserTest.java, EHRbase's own AQL parser
#   test suite (Copyright vitasystems GmbH and Hannover Medical School):
#   https://github.com/ehrbase/openEHR_SDK/blob/develop/aql/src/test/java/org/ehrbase/openehr/sdk/aql/parser/AqlQueryParserTest.java
#   These are real queries EHRbase engineers wrote against a real
#   operational template ("Corona_Anamnese", COMPOSITION/SECTION/OBSERVATION
#   nesting) and a real archetype ("openEHR-EHR-OBSERVATION.sample_blood_pressure.v1"),
#   not queries invented for this gem.
#
# - The query labelled "EHRBASE:191_where_parenthesis" is copied verbatim
#   (only re-indented) from a standalone regression-test fixture:
#   https://github.com/ehrbase/ehrbase/blob/develop/service/src/test/resources/samples/191_where_parenthesis.aql
#
# Two queries from the SDK suite are deliberately NOT included here:
#   - parseContainsVersion (VERSION/LATEST_VERSION/ALL_VERSIONS containment)
#     is out of scope per this project's plan (version-aware AQL is
#     explicitly excluded from Phase 7/8).
#   - parseTerminology (uses a TERM_CODE literal, e.g. "ICD10::F10.3") needs
#     a TERM_CODE lexer token this gem doesn't implement yet (deferred,
#     same as DATE/TIME/DATETIME literals and CONTAINED_REGEX - see
#     lib/openehr/aql/lexer.rb's header comment).
describe 'OpenEHR::AQL real-world example queries' do
  {
    'SDK:parse' =>
      'SELECT c/context/other_context[at0001]/items[at0002]/value/value AS Bericht_ID__value, ' \
      'd/ehr_id/value AS ehr_id FROM EHR d CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.report.v1]',

    'SDK:parseEhrPredicate' =>
      "SELECT c/name/value, d/ehr_id/value AS ehr_id FROM EHR d[some_key='some_value'] " \
      'CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.report.v1]',

    'SDK:parseCompositionPredicate' =>
      "SELECT c/name/value, d/ehr_id/value AS ehr_id FROM EHR d CONTAINS COMPOSITION c[some_key='some_value']",

    'SDK:parsePredicateOr' =>
      'SELECT c[at001 or at002 or data=1] FROM COMPOSITION c',

    'SDK:parsePredicateAnd (1)' =>
      "SELECT c[at001 and archetype_node_id='at002' and data=1] FROM COMPOSITION c",

    'SDK:parsePredicateAnd (2)' =>
      "SELECT c[at001 and archetype_node_id='at002' and data=1 or at003 and archetype_node_id='at004'] " \
      'FROM COMPOSITION c',

    "SDK:parsePredicateNameValue (1)" =>
      "SELECT c[at001, 'Name'] FROM COMPOSITION c",

    'SDK:parsePredicateNameValue (2)' =>
      "SELECT c[at001, 'Name' OR at002, $Same] FROM COMPOSITION c",

    'SDK:parseNested' =>
      "SELECT c[content[name/value=$contentName]/data[name[value>'2' AND value<'200']/value = " \
      "protocol[at001]/name/value]/data/origin>'2013'] FROM COMPOSITION c",

    'SDK:parsePathComparePath' =>
      'SELECT c[at001 and archetype_node_id = name/value] FROM COMPOSITION c',

    'SDK:parseFromComposition' =>
      'SELECT c/name/value AS name FROM COMPOSITION c',

    'SDK:parseDoubleAlias' =>
      'SELECT e/ehr_id/value, c0 AS F1 FROM EHR e CONTAINS COMPOSITION c0[openEHR-EHR-COMPOSITION.report.v1]',

    'SDK:parseEhrAliasSwap' =>
      "SELECT c/name/value AS e FROM EHR[ehr_id/value!='anything'] CONTAINS COMPOSITION c",

    'SDK:parsePlainEhr' =>
      'SELECT c/name/value FROM EHR CONTAINS COMPOSITION c',

    'SDK:parseDefaultEhrAliasCollision' =>
      "SELECT e/name/value AS F1 FROM EHR[ehr_id/value!='anything'] CONTAINS COMPOSITION e",

    'SDK:parseDoubleAlias2' =>
      'SELECT c0 AS F1, e/ehr_id/value FROM EHR e CONTAINS COMPOSITION c0[openEHR-EHR-COMPOSITION.report.v1]',

    'SDK:parseObservation' =>
      'SELECT o FROM EHR e CONTAINS OBSERVATION o',

    'SDK:parseObservation2' =>
      'SELECT e/ehr_id/value AS F1, ' \
      'o/data[at0001]/events[at0002]/data[at0003]/items[at0022]/items[at0005]/value/value AS F2, ' \
      'o/data[at0001]/events[at0002]/data[at0003]/items[at0022]/items[at0004]/value/value AS F3 ' \
      'FROM EHR e CONTAINS (COMPOSITION c0 and (SECTION s4[openEHR-EHR-SECTION.adhoc.v1] ' \
      'CONTAINS OBSERVATION o[openEHR-EHR-OBSERVATION.symptom_sign_screening.v0])) ' \
      "WHERE (e/ehr_id/value MATCHES {'47dc21a2-7076-4a57-89dc-bd83729ed52f'} " \
      "and c0/archetype_details/template_id/value MATCHES {'Corona_Anamnese'})",

    'SDK:parseMultiWhere' =>
      'SELECT c0 AS openEHR_EHR_COMPOSITION_self_monitoring_v0, c1 AS openEHR_EHR_COMPOSITION_report_v1 ' \
      'FROM EHR e CONTAINS (COMPOSITION c0[openEHR-EHR-COMPOSITION.self_monitoring.v0] ' \
      'and COMPOSITION c1[openEHR-EHR-COMPOSITION.report.v1]) ' \
      "WHERE (e/ehr_id/value MATCHES {'b3a40b41-36e1-4802-8748-062d4000aaae'} " \
      "and c0/archetype_details/template_id/value MATCHES {'Corona_Anamnese'} " \
      "and c1/archetype_details/template_id/value MATCHES {'Corona_Anamnese'})",

    'SDK:parseMultiMixed' =>
      'SELECT c0 AS F1, e/ehr_id/value AS F2 FROM EHR e ' \
      'CONTAINS COMPOSITION c0[openEHR-EHR-COMPOSITION.report.v1] ' \
      'WHERE (e/ehr_id/value = $ehrid or (e/ehr_id/value = $ehrid2 and e/ehr_id/value = $ehrid3))',

    'SDK:parseMatches' =>
      'SELECT c/context/other_context[at0001]/items[at0002]/value/value AS Bericht_ID__value, ' \
      'd/ehr_id/value AS ehr_id FROM EHR d CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.report.v1] ' \
      "WHERE d/ehr_id/value MATCHES {'f4da8646-8e36-4d9d-869c-af9dce5935c7', " \
      "'61861e76-1606-48c9-adcf-49ebbb2c6bbd'}",

    'SDK:parseWithoutContains' =>
      'SELECT e/ehr_id/value FROM EHR e',

    'SDK:parseLimitOffset' =>
      'SELECT c/context/other_context[at0001]/items[at0002]/value/value AS Bericht_ID__value, ' \
      'd/ehr_id/value AS ehr_id FROM EHR d CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.report.v1] ' \
      'LIMIT 5 OFFSET 1',

    'SDK:parseWhere' =>
      'SELECT o0/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/magnitude AS Systolic__magnitude, ' \
      'e/ehr_id/value AS ehr_id FROM EHR e CONTAINS OBSERVATION o0[openEHR-EHR-OBSERVATION.sample_blood_pressure.v1] ' \
      'WHERE (o0/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/magnitude >= $magnitude ' \
      'and o0/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/magnitude < 1.1)',

    'SDK:parseContains' =>
      'SELECT c0/context/other_context[at0001]/items[at0002]/value/value AS Bericht_ID__value ' \
      'FROM EHR e CONTAINS COMPOSITION c0[openEHR-EHR-COMPOSITION.report.v1] ' \
      'CONTAINS OBSERVATION o0[openEHR-EHR-OBSERVATION.sample_blood_pressure.v1]',

    'SDK:parseContainsLogical' =>
      'SELECT c0/context/other_context[at0001]/items[at0002]/value/value ' \
      'AS Bezeichnung_des_Symptoms_oder_Anzeichens___value, ' \
      'o3/data[at0001]/events[at0002]/data[at0042]/items[at0055]/value/value AS Kommentar__value ' \
      'FROM EHR e CONTAINS COMPOSITION c0[openEHR-EHR-COMPOSITION.report.v1] ' \
      'CONTAINS (OBSERVATION o1[openEHR-EHR-OBSERVATION.story.v1] ' \
      'and OBSERVATION o2[openEHR-EHR-OBSERVATION.symptom_sign_screening.v0] ' \
      'or OBSERVATION o3[openEHR-EHR-OBSERVATION.exposure_assessment.v0])',

    'SDK:parseContainsLogical2' =>
      'SELECT c0/context/other_context[at0001]/items[at0002]/value/value ' \
      'AS Bezeichnung_des_Symptoms_oder_Anzeichens___value, ' \
      'o3/data[at0001]/events[at0002]/data[at0042]/items[at0055]/value/value AS Kommentar__value ' \
      'FROM EHR e CONTAINS COMPOSITION c0[openEHR-EHR-COMPOSITION.report.v1] ' \
      'CONTAINS (OBSERVATION o1[openEHR-EHR-OBSERVATION.story.v1] ' \
      'or OBSERVATION o2[openEHR-EHR-OBSERVATION.symptom_sign_screening.v0] ' \
      'and OBSERVATION o3[openEHR-EHR-OBSERVATION.exposure_assessment.v0])',

    'SDK:parseContainsLogical3' =>
      'SELECT c0/context/other_context[at0001]/items[at0002]/value/value ' \
      'AS Bezeichnung_des_Symptoms_oder_Anzeichens___value, ' \
      'o3/data[at0001]/events[at0002]/data[at0042]/items[at0055]/value/value AS Kommentar__value ' \
      'FROM EHR e CONTAINS COMPOSITION c0[openEHR-EHR-COMPOSITION.report.v1] ' \
      'CONTAINS ((OBSERVATION o1[openEHR-EHR-OBSERVATION.story.v1] ' \
      'or OBSERVATION o2[openEHR-EHR-OBSERVATION.symptom_sign_screening.v0]) ' \
      'and OBSERVATION o3[openEHR-EHR-OBSERVATION.exposure_assessment.v0])',

    'SDK:parseContainsLogical4' =>
      'SELECT c0/context/other_context[at0001]/items[at0002]/value/value ' \
      'AS Bezeichnung_des_Symptoms_oder_Anzeichens___value, ' \
      'o3/data[at0001]/events[at0002]/data[at0042]/items[at0055]/value/value AS Kommentar__value ' \
      'FROM EHR e CONTAINS COMPOSITION c0[openEHR-EHR-COMPOSITION.report.v1] ' \
      'CONTAINS (((OBSERVATION o1[openEHR-EHR-OBSERVATION.story.v1] CONTAINS CLUSTER) ' \
      'or OBSERVATION o2[openEHR-EHR-OBSERVATION.symptom_sign_screening.v0]) ' \
      'and OBSERVATION o3[openEHR-EHR-OBSERVATION.exposure_assessment.v0])',

    'SDK:parseLike' =>
      'SELECT c0 AS openEHR_EHR_COMPOSITION_self_monitoring_v0, c1 AS openEHR_EHR_COMPOSITION_report_v1 ' \
      'FROM EHR e CONTAINS (COMPOSITION c0[openEHR-EHR-COMPOSITION.self_monitoring.v0] ' \
      'AND COMPOSITION c1[openEHR-EHR-COMPOSITION.report.v1]) ' \
      "WHERE (e/ehr_id/value MATCHES {'b3a40b41-36e1-4802-8748-062d4000aaae'} " \
      "AND c1/archetype_details/template_id/value LIKE '%test%' " \
      'AND c1/archetype_details/archetype_id/value LIKE $archetype)',

    'SDK:testParseInvalidDateAsStringPrimitive' =>
      "SELECT '60000431' FROM EHR d",

    'SDK:testParseInvalidDateTimeAsStringPrimitive' =>
      "SELECT '60000431T654123' FROM EHR d",

    'EHRBASE:191_where_parenthesis' => <<~AQL
      select
          e/ehr_id,
          a_a/data[at0002]/events[at0003]/data[at0001]/items[at0004]/value/magnitude,
          a_a/data[at0002]/events[at0003]/time/value
      from EHR e
      contains COMPOSITION a
      contains OBSERVATION a_a[openEHR-EHR-OBSERVATION.body_temperature.v1]
      where a_a/data[at0002]/events[at0003]/data[at0001]/items[at0004]/value/magnitude>38
      AND  a_a/data[at0002]/events[at0003]/data[at0001]/items[at0004]/value/units = '°C'
      AND e/ehr_id/value MATCHES {
          '849bf097-bd16-44fc-a394-10676284a012',
          '34b2e263-00eb-40b8-88f1-823c87096457'}
          OR (a_a/data[at0002]/events[at0003]/data[at0001]/items[at0004]/value/units = '°C' AND a_a/data[at0002]/events[at0003]/data[at0001]/items[at0004]/value/units = '°C')
    AQL
  }.each do |description, aql|
    it "parses: #{description}" do
      expect { OpenEHR::AQL.parse(aql) }.not_to raise_error
    end
  end
end
