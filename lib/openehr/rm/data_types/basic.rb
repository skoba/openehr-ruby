# This module is implemented from this UML:
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109067591791_562382_3151Report.html
# Ticket refs #52
module OpenEHR
  module RM
    module DataTypes
      module Basic
        module CanonicalFragment
        end

        class DataValue
          include OpenEHR::RM::Support::Definition::BasicDefinition
          attr_accessor :value
          alias :v :value

          def initialize(args = {})
            self.value = args[:value]
          end

          def ==(other)
            return self.value == other.value
          end
        end

        class DvBoolean < DataValue
          def initialize(args)
            super(args)
          end

          def value=(value)
            raise ArgumentError, "value must not be nil" if value.nil?
            if value == true or value =~ /TRUE/i
              @value = true
            else
              @value = false
            end
          end

          def value?
            @value == true
          end
        end  # end of DvBoolean

        class DvState < DataValue
          attr_reader :is_terminal

          def initialize(args)            
            super(args)
            self.terminal = args[:is_terminal].nil? ? args[:terminal] : args[:is_terminal]
          end

          def value=(v)
            raise ArgumentError, "value should not be nil" if v.nil?
            @value = v
          end

          def is_terminal?
            @is_terminal
          end

          alias terminal? is_terminal?

          def is_terminal=(s)
            raise ArgumentError, "terminal should not be nil" if s.nil?
            @is_terminal = s
          end

          alias terminal= is_terminal=
        end # end of DvState

        class DvIdentifier < DataValue
          attr_reader :issuer, :assigner, :id, :type

          def initialize(args = {})
            self.issuer = args[:issuer]
            self.assigner = args[:assigner]
            self.id = args[:id]
            self.type = args[:type]
          end

          def issuer=(issuer)
            if issuer.nil? or issuer.empty?
              raise ArgumentError, 'issuer is mandatory'
            end
            @issuer = issuer
          end

          def assigner=(assigner)
            if assigner.nil? or assigner.empty?
              raise ArgumentError, 'assigner is mandatory'
            end
            @assigner = assigner
          end

          def id=(id)
            if id.nil? or id.empty?
              raise ArgumentError, 'id is manadtory'
            end
            @id = id
          end

          def type=(type)
            if type.nil? or type.empty?
              raise ArgumentError, 'type is mandatory'
            end
            @type = type
          end
        end #end of DvIdentifier
      end # end of Basic
    end # end of DataTypes
  end # end of RM
end # end of OpenEHR
