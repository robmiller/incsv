module InCSV
  module Types
    # Represents a fixed-precision decimal number.
    class Decimal < ColumnType
      # What type of column to create in the database.
      def self.for_database
        "DECIMAL(15,10)"
      end

      # Returns true if the supplied value is a decimal number or
      # an integer, since integers are also valid decimals.
      #
      # This allows for columns that contain e.g.:
      #
      # 123.45
      # 123
      # 128.2
      def match?
        value.strip.match(/\A[0-9]+\.?([0-9]+)?\z/)
      end

      # Converts values to BigDecimal format before storage.
      def self.clean_value(value)
        BigDecimal(value.strip)
      end
    end
  end
end
