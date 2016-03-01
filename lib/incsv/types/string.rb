module InCSV
  module Types
    # Represents a String, stored in the database as a VARCHAR(255).
    # This is the fallback datatype, used for anything that doesn't
    # match any of the other more specific types. Its matching logic is
    # therefore simple: it matches anything. For this reason it must be
    # matched last; this is achieved via require order.
    class String < ColumnType
      def self.for_database
        "TEXT"
      end

      def match?
        true
      end
    end
  end
end
