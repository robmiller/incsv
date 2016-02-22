module InCSV
  class ColumnType
    def self.name
      self.to_s.sub(/.*::/, "").downcase.to_sym
    end

    def self.for_database
      self.to_s.sub(/.*::/, "").downcase.to_sym
    end

    def initialize(value)
      @value = value
    end

    def match?
      false
    end

    def clean_value
      self.class.clean_value(@value)
    end

    def self.clean_value(value)
      value
    end

    private
    attr_reader :value
  end
end
