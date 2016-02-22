require "csv"

module InCSV
  class Schema
    def initialize(csv)
      @csv = csv
    end

    def columns
      @columns ||= parsed_columns
    end

    private

    attr_reader :csv

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
