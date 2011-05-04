# Because his module utilise common methods in both rm
# and am, I will integrated to /lib/models/assumed_types.rb.
# By Shinji KOBAYASHI, 2008-07-20
module OpenEhr
  module RM
    module Support
      module AssumedTypes
        class Interval
          attr_accessor :lower, :upper
#          attr_accessor :lower_included, :lower_unbounded
#          attr_accessor :upper_included, :upper_unbounded
          def initialize(lower, upper,
                         lower_included = nil, upper_included = nil)
            if ((lower !=nil) && (upper !=nil)) && lower>upper
              raise ArgumentError, "upper < lower"
            end
            @lower = lower
            @upper = upper
          end
        end

        class List
          attr_reader :content

          def initialize(arg)
            @content = arg
          end

          def first
            @content.first
          end

          def last
            @content.last
          end
        end

        class TIME_DEFINITIONS
        end


        class ISO8601_DATE < TIME_DEFINITIONS
        end

        class ISO8601_TIME < TIME_DEFINITIONS
        end

        class ISO8601_DURATION < TIME_DEFINITIONS
        end

        class ISO8601_DATE_TIME < TIME_DEFINITIONS
        end

        class ISO8601_TIMEZONE < TIME_DEFINITIONS
        end

        class String
          attr_reader :content
          def initialize(arg)
            @content = arg
          end

          def as_integer
            is_integer if is_integer
          end

          def is_empty
          end

          def is_integer
            begin
              Integer(@content)
            rescue
              false
            end
          end
        end
      end
    end
  end
end
