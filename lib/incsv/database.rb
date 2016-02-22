require "sequel"

require "pathname"

module InCSV
  # Represents a database file, handling the creation of the database
  # and of the table within the database, as well as the importing of
  # data from a CSV file into the database.
  class Database
    def initialize(csv)
      @csv = csv

      @db = Sequel.sqlite(db_path)
      # require "logger"
      # @db.loggers << Logger.new($stdout)
    end

    attr_reader :db

    # Returns true if the primary database table within the database has
    # been created.
    def table_created?
      @db.table_exists?(table_name)
    end

    # Returns true if there is data in the primary table. There are
    # perhaps more accurate ways to calculate this, but only by
    # comparing samples from the CSV to the table; this is faster and
    # will in practice be accurate.
    def imported?
       table_created? && @db[table_name].count > 0
    end

    # Returns true if the database file exists; makes no effort to check
    # whether it is in fact a valid SQLite database.
    def exists?
      File.exist?(db_path)
    end

    # Returns the path to the database file, generated based on the
    # filename of the CSV passed to the class. For example, a CSV called
    # `products.csv` will be stored in a database called `products.db`
    # in the same directory.
    def db_path
      path = Pathname(csv)
      (path.dirname + (path.basename(".csv").to_s + ".db")).to_s
    end

    # Returns the table name, by default generated based on the filename
    # of the CSV. For example, a CSV called `products.csv` will produce
    # a table called `products`.
    def table_name
      @table_name ||= begin
        File.basename(csv, ".csv").downcase.gsub(/[^a-z_]/, "").to_sym
      end
    end

    # Creates a table in the database, with one column in the database
    # for each column in the CSV, the type of which is the best guess
    # for the data found in that column in the CSV data.
    def create_table
      @db.create_table!(table_name) do
        primary_key :_incsv_id
      end

      schema.columns.each do |c|
        @db.alter_table(table_name) do
          add_column c.name, c.type.for_database
        end
      end
    end

    # Imports data from the CSV file into the database, applying any
    # preprocessing specified by the column type (e.g. stripping
    # currency prefixes).
    #
    # Data is imported in transactions, in chunks of 200 rows at a time.
    def import
      return if imported?

      create_table unless table_created?

      columns      = schema.columns
      column_names = columns.map(&:name)

      chunks(200) do |chunk|
        rows = chunk.map do |row|
          row.to_hash.values.each_with_index.map do |column, n|
            columns[n].type.clean_value(column)
          end
        end

        @db[table_name].import(column_names, rows)
      end
    end

    private

    attr_reader :csv

    def schema
      @schema ||= Schema.new(csv)
    end

    def chunks(size = 200, &block)
      data =
        File.read(csv)
          .encode("UTF-8", invalid: :replace, undef: :replace, replace: "")

      csv = CSV.new(data, headers: true)
      csv.each_slice(size, &block)
      csv.close
    end
  end
end
