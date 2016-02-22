require "csv"

module InCSV
  # Given a CSV file, samples data from it in order to establish what
  # data types its columns are.
  class Schema
    def initialize(csv)
      @csv = csv
    end

    # Returns the column types found in the CSV. Memoises the result, so
    # can be called repeatedly.
    def columns
      @columns ||= parsed_columns
    end

    private

    attr_reader :csv

    # Returns an array with one element for each column in the CSV. The
    # value is a Column object, which has responsibility for determining
    # the type of the data stored in the column; a sample of 50 rows
    # from the column is provided to the Column class for this purpose.
    def parsed_columns
      samples(50).map do |name, values|
        Column.new(name, values)
      end
    end

    # Returns the first `num_rows` rows of data, transposed into a hash.
    #
    # For example, the following CSV data:
    #
    # foo,bar
    # 1,2
    # 3,4
    #
    # Would become:
    #
    # { "foo" => [1, 3], "bar" => [2, 4] }
    #
    # This gives us enough data to be able to guess the type of
    # a column.
    def samples(num_rows)
      data =
        File.read(csv)
          .encode("UTF-8", invalid: :replace, undef: :replace, replace: "")

      csv = CSV.new(data, headers: true)
      sample_data = csv.each.take(num_rows)
      csv.close

      sample_data.map(&:to_a).flatten(1).each_with_object({}) do |row, data|
        column = row[0]
        value  = row[1]

        data[column] ||= []
        data[column] << value
      end
    end
  end
end
