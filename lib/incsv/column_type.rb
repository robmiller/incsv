module InCSV
  # An abstract class, inherited by all types of column. Specifies the
  # interface that all these classes must adhere to.
  class ColumnType
    # A symbol representation of what type of data this ColumnType
    # represents. By default this is taken from the class name (so this
    # class would be :columntype).
    def self.name
      self.to_s.sub(/.*::/, "").downcase.to_sym
    end

    # The type of the column from the perspective of the database. By
    # default this is the same as the class name, so a column of type
    # String would go into the database as a :string.
    #
    # Possible column types can be found here:
    #
    # http://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html#label-Column+types
    #
    # This can also be a string, for database-specific features or in
    # order to specify lengths easily. Examples might be:
    #
    # VARCHAR(255)
    # DECIMAL(10, 2)
    # BOOLEAN
    def self.for_database
      self.to_s.sub(/.*::/, "").downcase.to_sym
    end

    def initialize(value)
      @value = value
    end

    # Returns true if the given value (supplied in the constructor)
    # is of the type represented by this column; returns false
    # otherwise.
    def match?
      false
    end

    # Returns a cleaned/preprocessed version of the given value.
    def clean_value
      self.class.clean_value(@value)
    end

    # Returns a cleaned/preprocessed version of an arbitrary value.
    def self.clean_value(value)
      value
    end

    private
    attr_reader :value
  end
end
