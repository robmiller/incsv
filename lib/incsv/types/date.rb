module InCSV
  module Types
    # Represents an ISO 8601-format date without any timestamp element,
    # e.g. 2016-01-01.
    class Date < ColumnType
      def match?
        value.strip.match(/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/)
      end
    end
  end
end
