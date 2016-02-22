module InCSV
  module Types
    class Date < ColumnType
      def match?
        value.strip.match(/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/)
      end
    end
  end
end
