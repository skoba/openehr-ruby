# Shared fixture for AQL engine specs: builds small, spec-compliant RM
# object graphs entirely via the public RM constructors (no test doubles,
# no JSON) so engine specs exercise the exact same Pathable/Locatable
# machinery real integrations would. Two shapes are provided:
#
#   blood_pressure_composition  - COMPOSITION > OBSERVATION[blood_pressure]
#                                  > History[at0001] > PointEvent[at0006]
#                                  > ItemTree[at0003] > systolic[at0004] /
#                                  diastolic[at0005] DV_QUANTITY "mm[Hg]"
#   body_temperature_composition - COMPOSITION > OBSERVATION[body_temperature],
#                                  a negative case for archetype-predicate
#                                  matching (it is not a blood_pressure
#                                  observation).
#
# Both are wrapped in an openEHR-EHR-COMPOSITION.encounter.v1 root with a
# real EVENT_CONTEXT, so `c/context/start_time` is queryable too.
#
#   repeated_cluster_composition - synthetic (hand-authored, not derived
#                                  from any real artifact; design
#                                  authority: docs/design/round2-2.5.0-plan.md
#                                  section 3.1, issue #60). COMPOSITION >
#                                  OBSERVATION[zz_invented_request] >
#                                  History[at0001] > PointEvent[at0006] >
#                                  ItemTree[at0003] > one CLUSTER per given
#                                  name, all sharing the invented archetype
#                                  id openEHR-EHR-CLUSTER.zz_invented_party.v1
#                                  and told apart only by `name`; each holds
#                                  ELEMENT[at0001] DV_TEXT "<name> value".
#                                  The archetype ids are invented on purpose
#                                  so they can't be mistaken for real ones.
#
#   coded_value_composition      - synthetic (hand-authored, not derived
#                                  from any real artifact; design
#                                  authority: docs/design/round2-2.5.0-plan.md
#                                  section 3.6, issue #49). COMPOSITION >
#                                  OBSERVATION[zz_invented_assessment] >
#                                  History[at0001] > PointEvent[at0006] >
#                                  ItemTree[at0003] > ELEMENT[at0007]
#                                  DV_CODED_TEXT with the given display
#                                  label and local code. The archetype id
#                                  and the codes specs pass in are invented.
#
#   templated                    - synthetic (design authority:
#                                  docs/design/round3-plan.md section 3.1,
#                                  issue #70). Gives any composition built
#                                  here a root ARCHETYPED (archetype_details)
#                                  carrying the given template id. Specs pass
#                                  in invented template ids.
module OpenEHR
  module AQL
    module Fixtures
      module BloodPressureBuilder
        module_function

        def blood_pressure_composition(systolic:, diastolic:, start_time: '2024-01-01T10:00:00+09:00',
                                        composer_name: 'Dr. Test')
          systolic_element = element('at0004', 'Systolic', quantity(systolic, 'mm[Hg]'))
          diastolic_element = element('at0005', 'Diastolic', quantity(diastolic, 'mm[Hg]'))
          data = item_tree('at0003', 'Blood pressure', [systolic_element, diastolic_element])
          event = point_event('at0006', 'Any event', start_time, data)
          history = history_of('at0001', 'History', start_time, [event])
          observation = observation_of('openEHR-EHR-OBSERVATION.blood_pressure.v1', 'Blood pressure', history)
          encounter(observation, start_time: start_time, composer_name: composer_name)
        end

        def body_temperature_composition(celsius: 36.5, start_time: '2024-01-01T10:00:00+09:00',
                                          composer_name: 'Dr. Test')
          temperature_element = element('at0004', 'Temperature', quantity(celsius, 'Cel'))
          data = item_tree('at0003', 'Any event', [temperature_element])
          event = point_event('at0006', 'Any event', start_time, data)
          history = history_of('at0001', 'History', start_time, [event])
          observation = observation_of('openEHR-EHR-OBSERVATION.body_temperature.v1', 'Body temperature', history)
          encounter(observation, start_time: start_time, composer_name: composer_name)
        end

        def repeated_cluster_composition(names:, start_time: '2024-01-01T10:00:00+09:00', composer_name: 'Dr. Test')
          clusters = names.map do |name|
            cluster('openEHR-EHR-CLUSTER.zz_invented_party.v1', name, [element('at0001', 'Label', text("#{name} value"))])
          end
          data = item_tree('at0003', 'Tree', clusters)
          event = point_event('at0006', 'Any event', start_time, data)
          history = history_of('at0001', 'History', start_time, [event])
          observation = observation_of('openEHR-EHR-OBSERVATION.zz_invented_request.v1', 'Request', history)
          encounter(observation, start_time: start_time, composer_name: composer_name)
        end

        # --- building blocks (openEHR-EHR-COMPOSITION.encounter.v1 root) ---

        def coded_value_composition(label:, code:, start_time: '2024-01-01T10:00:00+09:00', composer_name: 'Dr. Test')
          coded = element('at0007', 'Certainty', coded_text(label, code_phrase('local', code)))
          data = item_tree('at0003', 'Tree', [coded])
          event = point_event('at0006', 'Any event', start_time, data)
          history = history_of('at0001', 'History', start_time, [event])
          observation = observation_of('openEHR-EHR-OBSERVATION.zz_invented_assessment.v1', 'Assessment', history)
          encounter(observation, start_time: start_time, composer_name: composer_name)
        end

        def templated(composition, template_id:)
          composition.archetype_details = RM::Common::Archetyped::Archetyped.new(
            archetype_id: RM::Support::Identification::ArchetypeID.new(value: composition.archetype_node_id),
            rm_version: '1.0.2',
            template_id: RM::Support::Identification::TemplateID.new(value: template_id)
          )
          composition
        end

        def encounter(*entries, start_time:, composer_name:)
          RM::Composition::Composition.new(
            archetype_node_id: 'openEHR-EHR-COMPOSITION.encounter.v1',
            name: text('Encounter'),
            language: code_phrase('ISO_639-1', 'en'),
            territory: code_phrase('ISO_3166-1', 'JP'),
            category: coded_text('event', code_phrase('openehr', '433')),
            composer: RM::Common::Generic::PartyIdentified.new(name: composer_name),
            content: entries,
            context: event_context(start_time)
          )
        end

        def event_context(start_time)
          RM::Composition::EventContext.new(
            start_time: date_time(start_time),
            setting: coded_text('other care', code_phrase('openehr', '238'))
          )
        end

        def observation_of(archetype_node_id, name, data)
          RM::Composition::Content::Entry::Observation.new(
            archetype_node_id: archetype_node_id,
            name: text(name),
            language: code_phrase('ISO_639-1', 'en'),
            encoding: code_phrase('IANA_character-sets', 'UTF-8'),
            subject: RM::Common::Generic::PartySelf.new,
            data: data
          )
        end

        def history_of(archetype_node_id, name, origin, events)
          RM::DataStructures::History::History.new(
            archetype_node_id: archetype_node_id,
            name: text(name),
            origin: date_time(origin),
            events: events
          )
        end

        def point_event(archetype_node_id, name, time, data)
          RM::DataStructures::History::PointEvent.new(
            archetype_node_id: archetype_node_id,
            name: text(name),
            time: date_time(time),
            data: data
          )
        end

        def item_tree(archetype_node_id, name, items)
          RM::DataStructures::ItemStructure::ItemTree.new(
            archetype_node_id: archetype_node_id,
            name: text(name),
            items: items
          )
        end

        def cluster(archetype_node_id, name, items)
          RM::DataStructures::ItemStructure::Representation::Cluster.new(
            archetype_node_id: archetype_node_id,
            name: text(name),
            items: items
          )
        end

        def element(archetype_node_id, name, value)
          RM::DataStructures::ItemStructure::Representation::Element.new(
            archetype_node_id: archetype_node_id,
            name: text(name),
            value: value
          )
        end

        def quantity(magnitude, units)
          RM::DataTypes::Quantity::DvQuantity.new(magnitude: magnitude, units: units)
        end

        def date_time(value)
          RM::DataTypes::Quantity::DateTime::DvDateTime.new(value: value)
        end

        def text(value)
          RM::DataTypes::Text::DvText.new(value: value)
        end

        def coded_text(value, defining_code)
          RM::DataTypes::Text::DvCodedText.new(value: value, defining_code: defining_code)
        end

        def code_phrase(terminology, code_string)
          RM::DataTypes::Text::CodePhrase.new(
            terminology_id: RM::Support::Identification::TerminologyID.new(value: terminology),
            code_string: code_string
          )
        end
      end
    end
  end
end
