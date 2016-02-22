require "bigdecimal"

module InCSV
  class Column
    def initialize(name, values)
      @name = name
      @values = values
    end

    attr_reader :name

    def type
      Types.constants.select do |column_type|
        column_type = Types.const_get(column_type)
        if values.all? { |value| value.nil? || column_type.new(value).match? }
          return column_type
        end
      end
    end

    private

    attr_accessor :values
  end
end
