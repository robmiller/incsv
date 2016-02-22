module InCSV
  module Types
    class Currency < ColumnType
      MATCH_EXPRESSION = /\A(\$|£)([0-9,\.]+)\z/

      def self.for_database
        "DECIMAL(10,2)"
      end

      def match?
        value.strip.match(MATCH_EXPRESSION)
      end

      def self.clean_value(value)
        return unless value

        value.strip.match(MATCH_EXPRESSION) do |match|
          BigDecimal(match[2].delete(","))
        end
      end
    end
  end
end
