# OpenEHR::TerminologyService is the seam RM classes call through to
# validate codes against openEHR/external terminologies (e.g.
# COMPOSITION.language against ISO_639-1, COMPOSITION.category against
# the openEHR "composition category" group). This gem carries no
# terminology data of its own - that lives in the separate
# openehr-terminology gem - so the default provider is fully
# permissive: every code is accepted.
#
# To get real validation, plug in an adapter:
#   OpenEHR::TerminologyService.provider = MyTerminologyAdapter.new
# where the adapter responds to:
#   #valid_code?(terminology_id, code)      -> Boolean
#   #has_code_for_group?(group_id, code)    -> Boolean
module OpenEHR
  module TerminologyService
    class NullProvider
      def valid_code?(_terminology_id, _code)
        true
      end

      def has_code_for_group?(_group_id, _code)
        true
      end
    end

    class << self
      def provider
        @provider ||= NullProvider.new
      end

      def provider=(provider)
        @provider = provider || NullProvider.new
      end

      def valid_code?(terminology_id, code)
        provider.valid_code?(terminology_id, code)
      end

      def has_code_for_group?(group_id, code)
        provider.has_code_for_group?(group_id, code)
      end
    end
  end
end
