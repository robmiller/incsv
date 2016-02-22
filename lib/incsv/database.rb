require "sequel"

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

    def db_path
      path = Pathname(csv)
      (path.dirname + (path.basename(".csv").to_s + ".db")).to_s
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

    def created?
      @created
    end

    def import
      create unless created?

      columns = schema.columns.map(&:name)

      chunks(200) do |chunk|
        rows = chunk.map do |row|
          row = row.to_hash.values
        end

        @db[table_name].import(columns, rows)
      end
    end

    private

    attr_reader :csv

    def table_name
      @table_name ||= begin
        File.basename(csv, ".csv").downcase.gsub(/[^a-z_]/, "").to_sym
      end
    end

    def schema
      @schema ||= Schema.new(csv)
    end

    def chunks(size = 200, &block)
      CSV.foreach(csv, headers: true).each_slice(size, &block)
    end
  end
end
