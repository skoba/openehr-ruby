module OpenEHR
  module AM
    module OpenEHRProfile
      module DataTypes
        module Basic
          class CDvState
          end

          class StateMachine
          end

          class State
            attr_reader :name

            def initialize(args = { })
              self.name = args[:name]
            end

            def name=(name)
              if name.nil? or name.empty?
                raise ArgumentError, 'Invalid name'
              end
              @name = name
            end
          end

          class TerminalState < State
          end

          class NonTerminalState < State
          end

          class Transition
          end
        end
      end # of DataTypes
    end # of OpenEHR Profile
  end # of AM
end # of OpenEHR
