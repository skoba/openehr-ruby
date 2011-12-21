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
            attr_reader :event, :action, :guard, :next_state

            def initialize(args = { })
              self.event = args[:event]
              self.guard = args[:guard]
              self.action = args[:action]
              self.next_state = args[:next_state]
            end

            def event=(event)
              if event.nil? or event.empty?
                raise ArgumentError, 'event is mandatory'
              end
              @event = event
            end

            def guard=(guard)
              if !guard.nil? && guard.empty?
                raise ArgumentError, 'guard should not be empty'
              end
              @guard = guard
            end

            def action=(action)
              if !action.nil? && action.empty?
                raise ArgumentError, 'action should not be empty'
              end
              @action = action
            end

            def next_state=(next_state)
              if next_state.nil?
                raise ArgumentError, 'next state is mandatory'
              end
              @next_state = next_state
            end
          end
        end
      end # of DataTypes
    end # of OpenEHR Profile
  end # of AM
end # of OpenEHR
