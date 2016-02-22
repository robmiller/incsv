require "sequel"

module InCSV
  class Database
    def initialize(csv)
      @csv = csv
      @db = Sequel.sqlite(db_path)
      @created = false
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

    private

    attr_reader :csv

    def table_name
      File.basename(csv, ".csv").downcase.gsub(/[^a-z_]/, "")
    end

    def schema
      Schema.new(csv)
    end
  end
end
