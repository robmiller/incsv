require "sequel"

require "pathname"

module InCSV
  class Database
    def initialize(csv)
      @csv = csv
      @created = false

      @db = Sequel.sqlite(db_path)
      # require "logger"
      # @db.loggers << Logger.new($stdout)
    end

    attr_reader :db

    def created?
      @created
    end

    def exists?
      File.exist?(db_path)
    end

    def db_path
      path = Pathname(csv)
      (path.dirname + (path.basename(".csv").to_s + ".db")).to_s
    end

    def table_name
      @table_name ||= begin
        File.basename(csv, ".csv").downcase.gsub(/[^a-z_]/, "").to_sym
      end
    end

    def create
      @db.create_table!(table_name) do
        primary_key :_incsv_id
      end

      schema.columns.each do |c|
        @db.alter_table(table_name) do
          add_column c.name, c.type.for_database
        end
      end

      @created = true
    end

    def import
      create unless created?

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
      CSV.foreach(csv, headers: true).each_slice(size, &block)
    end
  end
end
