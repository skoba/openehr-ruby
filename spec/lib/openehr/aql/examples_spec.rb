require File.dirname(__FILE__) + '/../../../spec_helper'

# Acceptance-test corpus for the AQL parser. Every query below is copied
# verbatim from the official AQL specification examples
# (https://specifications.openehr.org/releases/QUERY/latest/AQL.html),
# minus the illustrative "..." path-shortening some of the prose examples
# use (not valid concrete syntax). This is the outer TDD loop for Phase 7 -
# it defines "done" for the parser and is expected to stay red across
# several inner-loop milestones (see the plan's M0-M9 ladder) before it
# turns fully green.
describe 'OpenEHR::AQL official example queries' do
  {
    'blood pressure values with WHERE OR, literal EHR id' => <<~AQL,
      SELECT
         o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude,
         o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude
      FROM
         EHR [ehr_id/value='1234']
            CONTAINS COMPOSITION [openEHR-EHR-COMPOSITION.encounter.v1]
               CONTAINS OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1]
      WHERE
         o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude >= 140 OR
         o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude >= 90
    AQL

    'blood pressure values, no WHERE clause' => <<~AQL,
      SELECT
         o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude
      FROM
         EHR [ehr_id/value='1234']
            CONTAINS COMPOSITION [openEHR-EHR-COMPOSITION.encounter.v1]
               CONTAINS OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1]
    AQL

    'LIKE operator on a start_time path' => <<~AQL,
      SELECT
         e/ehr_id/value, c/context/start_time
      FROM
         EHR e
            CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.administrative_encounter.v1]
               CONTAINS ADMIN_ENTRY admission[openEHR-EHR-ADMIN_ENTRY.admission.v1]
      WHERE
         c/context/start_time LIKE '2019-0?-*'
    AQL

    'MATCHES against a literal value set' => <<~AQL,
      SELECT
         o/data[at0002]/events[at0003]/data/items[at0015]/items[at0018]/name
      FROM
         EHR [uid=$ehrUid]
            CONTAINS Composition c
               CONTAINS Observation o[openEHR-EHR-OBSERVATION.microbiology.v1]
      WHERE
         o/data[at0002]/events[at0003]/data/items[at0015]/items[at0018]/items[at0019]/items[at0021]/name/defining_code/code_string matches {'18919-1', '18961-3', '19000-9'}
    AQL

    'MATCHES against a terminology:// URI reference' => <<~AQL,
      SELECT
         e/ehr_status/subject/external_ref/id/value, diagnosis/data/items[at0002.1]/value
      FROM
         EHR e
            CONTAINS Composition c[openEHR-EHR-COMPOSITION.problem_list.v1]
               CONTAINS Evaluation diagnosis[openEHR-EHR-EVALUATION.problem-diagnosis.v1]
      WHERE
         c/name/value='Current Problems' AND
         diagnosis/data/items[at0002.1]/value/defining_code matches { terminology://snomed-ct/hierarchy?rootConceptId=50043002 }
    AQL

    'MATCHES against a TERMINOLOGY(...) function call' => <<~AQL,
      SELECT
         c/context/start_time, p/data/items[at0002]/value
      FROM
         EHR e[ehr_id/value='1234']
            CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.problem_list.v1]
               CONTAINS EVALUATION p[openEHR-EHR-EVALUATION.problem-diagnosis.v1]
      WHERE
         c/name/value='Current Problems' AND
         p/data/items[at0002]/value/defining_code/code_string matches TERMINOLOGY('expand', 'hl7.org/fhir/4.0', 'http://snomed.info/sct?fhir_vs=isa/50697003')
    AQL

    'NOT ( EXISTS ... AND ... )' => <<~AQL,
      SELECT
         e/ehr_id/value
      FROM
         EHR e
            CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.administrative_encounter.v1]
               CONTAINS ADMIN_ENTRY admission[openEHR-EHR-ADMIN_ENTRY.admission.v1]
      WHERE
         NOT (EXISTS c/content[openEHR-EHR-ADMIN_ENTRY.discharge.v1] AND
         e/ehr_status/subject/external_ref/namespace = 'CEC')
    AQL

    'NOT EXISTS ... OR ... (De Morgan variant)' => <<~AQL,
      SELECT
         e/ehr_id/value
      FROM
         EHR e
            CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.administrative_encounter.v1]
               CONTAINS ADMIN_ENTRY admission[openEHR-EHR-ADMIN_ENTRY.admission.v1]
      WHERE
         NOT EXISTS c/content[openEHR-EHR-ADMIN_ENTRY.discharge.v1] OR
         e/ehr_status/subject/external_ref/namespace != 'CEC'
    AQL

    'NOT CONTAINS in the containment tree' => <<~AQL,
      SELECT
         e/ehr_id/value
      FROM
         EHR e
            CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.administrative_encounter.v1]
               NOT CONTAINS ADMIN_ENTRY admission[openEHR-EHR-ADMIN_ENTRY.admission.v1]
      WHERE
         e/ehr_status/subject/external_ref/namespace != 'CEC'
    AQL

    'NOT EXISTS, simple form' => <<~AQL,
      SELECT
         e/ehr_id/value
      FROM
         EHR e
            CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.administrative_encounter.v1]
               CONTAINS ADMIN_ENTRY admission[openEHR-EHR-ADMIN_ENTRY.admission.v1]
      WHERE
         NOT EXISTS c/content[openEHR-EHR-ADMIN_ENTRY.discharge.v1]
    AQL

    'aggregate functions MAX/MIN/AVG with AS aliases' => <<~AQL,
      SELECT
          MAX(o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude) AS maxValue,
          MIN(o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude) AS minValue,
          AVG(o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude) AS meanValue
      FROM
          EHR e CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.encounter.v1]
              CONTAINS OBSERVATION o[openEHR-EHR-OBSERVATION.blood_pressure.v1]
    AQL

    'parameter equality on a plain (non-CONTAINS) path' => <<~AQL,
      SELECT
         e/ehr_id/value
      FROM
         EHR e
            CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.referral.v1]
      WHERE
         c/archetype_details/template_id/value = $templateId
    AQL

    'multi-column select without WHERE' => <<~AQL,
      SELECT
         c/name/value AS Name, c/context/start_time AS date_time, c/composer/name AS Composer
      FROM
         EHR e[ehr_id/value=$ehrUid]
             CONTAINS COMPOSITION c
    AQL

    'whole-class select (SELECT c)' => <<~AQL,
      SELECT c
      FROM EHR e[ehr_id/value=$ehrUid]
          CONTAINS COMPOSITION c
    AQL

    'literal boolean/string primitives and COUNT(*)' => <<~AQL,
      SELECT
          true AS dangerousBP, "alert" as indication, count(*) as counter
      FROM
          EHR [ehr_id/value=$ehrUid]
              CONTAINS COMPOSITION [openEHR-EHR-COMPOSITION.encounter.v1]
                  CONTAINS OBSERVATION obs [openEHR-EHR-OBSERVATION.blood_pressure.v1]
      WHERE
          obs/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude>= 160 OR
          obs/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude>= 110
    AQL

    'SELECT DISTINCT' => <<~AQL,
      SELECT DISTINCT
         c/name/value AS Name, c/composer/name AS Composer
      FROM
         EHR e[ehr_id/value=$ehrUid]
            CONTAINS COMPOSITION c
    AQL

    'SELECT TOP 10 (deprecated form)' => <<~AQL,
      SELECT
         TOP 10 c/name/value AS Name, c/context/start_time AS date_time, c/composer/name AS Composer
      FROM
         EHR e[ehr_id/value=$ehrUid]
            CONTAINS COMPOSITION c
    AQL

    'ORDER BY with LIMIT/OFFSET' => <<~AQL,
      SELECT
         c/name/value AS Name, c/context/start_time AS date_time, c/composer/name AS Composer
      FROM
         EHR e[ehr_id/value=$ehrUid]
            CONTAINS COMPOSITION c
      ORDER BY c/context/start_time
      LIMIT 10 OFFSET 10
    AQL

    'ORDER BY DESC with LIMIT and an alias variable in FROM' => <<~AQL
      SELECT
         obs/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic,
         obs/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude AS diastlic,
         c/context/start_time AS date_time
      FROM
         EHR [ehr_id/value=$ehrUid] CONTAINS COMPOSITION c [openEHR-EHR-COMPOSITION.encounter.v1]
            CONTAINS OBSERVATION obs [openEHR-EHR-OBSERVATION.blood_pressure.v1]
      WHERE
         obs/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude >= 140 OR
         obs/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude >= 90
      ORDER BY
         c/context/start_time DESC
      LIMIT 5
    AQL
  }.each do |description, aql|
    it "parses: #{description}" do
      expect { OpenEHR::AQL.parse(aql) }.not_to raise_error
    end
  end
end
