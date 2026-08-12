module OpenEHR
  module AQL
    module Model
      # orderByClause : ORDER BY orderByExpr (SYM_COMMA orderByExpr)* ;
      class OrderByClause
        attr_reader :items

        def initialize(items:)
          @items = items.freeze
          freeze
        end
      end

      # orderByExpr : identifiedPath order=(DESCENDING|DESC|ASCENDING|ASC)? ;
      # `direction` is always :asc or :desc - the grammar's four spellings
      # (ASC/ASCENDING/DESC/DESCENDING) collapse to one of these two.
      class OrderByItem
        attr_reader :path, :direction

        def initialize(path:, direction: :asc)
          @path = path
          @direction = direction
          freeze
        end
      end

      # limitClause : LIMIT limit=INTEGER (OFFSET offset=INTEGER)? ;
      class LimitClause
        attr_reader :limit, :offset

        def initialize(limit:, offset: 0)
          @limit = limit
          @offset = offset
          freeze
        end
      end

      # top : TOP INTEGER direction=(FORWARD|BACKWARD)? ; (deprecated)
      class Top
        attr_reader :count, :direction

        def initialize(count:, direction: nil)
          @count = count
          @direction = direction
          freeze
        end
      end
    end
  end
end
