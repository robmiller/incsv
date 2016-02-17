require "bigdecimal"

module InCSV
  class Column
    class ColumnType
      def self.type
        self.to_s.sub(/.*::/, "").downcase.to_sym
      end

      def self.db_type
        self.to_s.sub(/.*::/, "").downcase.to_sym
      end

      def initialize(value)
        @value = value
      end

      def match?
        false
      end

      def clean_value
        @value
      end

      private
      attr_reader :value
    end

    module Types
      class Date < ColumnType
        def match?
          value.strip.match(/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/)
        end
      end

      class Currency < ColumnType
        MATCH_EXPRESSION = /\A(\$|£)([0-9,\.]+)\z/

        def self.db_type
          "DECIMAL(10,2)"
        end

        def match?
          value.strip.match(MATCH_EXPRESSION)
        end

        def clean_value
          value.strip.match(MATCH_EXPRESSION) do |match|
            BigDecimal(match[2].delete(","))
          end
        end
      end

      class String < ColumnType
        def match?
          true
        end
      end
    end

    def initialize(name, values)
      @name = name
      @values = values
    end

    attr_reader :name

    def type
      Types.constants.select do |column_type|
        column_type = Types.const_get(column_type)
        if values.all? { |value| value.nil? || column_type.new(value).match? }
          return column_type.type
        end
      end
    end

    private

    attr_accessor :values
  end
end
