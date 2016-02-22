module InCSV
  module Types
    # Represents a currency value, without its symbol/identifier, stored
    # as a DECIMAL(10, 2) to avoid rounding errors.
    #
    # Not storing the identifier is an issue that should be resolved at
    # some point, ideally; it's obviously an issue in files that have
    # multiple currencies in the same column.
    class Currency < ColumnType
      # A regular expression which matches all supported currency types.
      MATCH_EXPRESSION = /\A(\$|£)([0-9,\.]+)\z/

      # What type of column to create in the database.
      def self.for_database
        "DECIMAL(10,2)"
      end

      # Returns true if the given value is a supported currency type, or
      # false otherwise.
      def match?
        value.strip.match(MATCH_EXPRESSION)
      end

      # Strip the currency symbol, and remove any comma separators. This
      # creates an issue with locales other than English, in which
      # commas are used for decimal points, but this will work for
      # English.
      def self.clean_value(value)
        return unless value

        value.strip.match(MATCH_EXPRESSION) do |match|
          BigDecimal(match[2].delete(","))
        end
      end
    end
  end
end
