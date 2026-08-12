require_relative '../errors'

# OpenEHR::AQL::Dataset is the AQL engine's only input boundary, and the
# whole of its framework/ORM independence: everything under
# lib/openehr/aql/ talks to "wherever your data lives" exclusively
# through this class, which itself talks to nothing but the Ruby
# `Enumerable`/`#each` protocol and this gem's own RM classes. No
# ActiveRecord/Rails/Sequel/etc. is required or referenced anywhere
# here or downstream - see the project plan's "Dataset:
# フレームワーク/ORM非依存の契約" section for the full design rationale.
#
# Construction is cheap and never iterates its source (laziness is
# preserved end to end); each element is normalized into an EHRRecord
# only as #each_ehr actually walks it.
#
#   Dataset.new(ehrs:)                       # ehrs: anything #each-able
#   Dataset.of_compositions(compositions, ehr_id: nil)
#   Dataset.wrap(source)                     # Dataset / Composition-Enumerable / EHR-shaped-Enumerable
#
# Each element of `ehrs:` must be one of:
#   - a Hash (symbol or string keys): {ehr_id:, compositions:, ehr_status: (optional)}
#   - a duck-typed object responding to #ehr_id / #compositions (/ #ehr_status)
#   - a full OpenEHR::RM::EHR::EHR (unwrapped via ehr_id.value,
#     compositions.map { |vc| vc.latest_version.data }, and
#     ehr_status.latest_version.data)
#
# Every element yielded by a record's compositions MUST be
# is_a?(OpenEHR::RM::Common::Archetyped::Pathable) - anything else
# raises DatasetError immediately, naming the offending class and
# index. This is the deliberate anti-leak mechanism that keeps loose
# ActiveRecord rows (or any other non-RM object) from half-working via
# accidental duck typing.
module OpenEHR
  module AQL
    class Dataset
      EHRRecord = Struct.new(:ehr_id, :ehr, :ehr_status, :compositions, keyword_init: true)

      def self.of_compositions(compositions, ehr_id: nil)
        new(ehrs: [{ ehr_id: ehr_id, compositions: compositions }])
      end

      def self.wrap(source)
        return source if source.is_a?(Dataset)

        unless source.is_a?(Enumerable)
          raise DatasetError, "cannot build a Dataset from a #{source.class} (expected a Dataset or an Enumerable)"
        end

        first, rest = source.first, source
        return of_compositions(rest) if first.is_a?(OpenEHR::RM::Common::Archetyped::Pathable)

        new(ehrs: rest)
      end

      def initialize(ehrs:)
        @ehrs = ehrs
      end

      def each_ehr
        return enum_for(:each_ehr) unless block_given?

        @ehrs.each { |element| yield normalize(element) }
      end

      private

      def normalize(element)
        return from_ehr(element) if element.is_a?(OpenEHR::RM::EHR::EHR)
        return from_hash(element) if element.is_a?(Hash)

        from_record(element)
      end

      def from_hash(hash)
        stringified = hash.transform_keys(&:to_s)
        build_record(
          ehr_id: stringified['ehr_id'],
          ehr: nil,
          ehr_status: stringified['ehr_status'],
          compositions: stringified['compositions']
        )
      end

      def from_record(record)
        build_record(
          ehr_id: record.ehr_id,
          ehr: nil,
          ehr_status: record.respond_to?(:ehr_status) ? record.ehr_status : nil,
          compositions: record.compositions
        )
      end

      def from_ehr(ehr)
        build_record(
          ehr_id: ehr.ehr_id,
          ehr: ehr,
          ehr_status: ehr.ehr_status&.latest_version&.data,
          compositions: ehr.compositions.map { |versioned_composition| versioned_composition.latest_version.data }
        )
      end

      def build_record(ehr_id:, ehr:, ehr_status:, compositions:)
        compositions = Array(compositions)
        compositions.each_with_index do |composition, index|
          next if composition.is_a?(OpenEHR::RM::Common::Archetyped::Pathable)

          raise DatasetError,
                "Dataset compositions must be OpenEHR::RM RM objects (Pathable), " \
                "got #{composition.class} at index #{index}"
        end

        EHRRecord.new(ehr_id: unwrap_id(ehr_id), ehr: ehr, ehr_status: ehr_status, compositions: compositions)
      end

      def unwrap_id(id)
        return nil if id.nil?

        id.respond_to?(:value) ? id.value : id
      end
    end
  end
end
