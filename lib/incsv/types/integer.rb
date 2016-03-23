module InCSV
  module Types
    # Represents a whole integer
    class Integer < ColumnType
      # Returns true if the supplied value is an integer, or false
      # otherwise
      def match?
        value.strip.match(/\A[0-9]+\z/)
      end
    end
  end
end
