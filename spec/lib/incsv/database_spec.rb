require_relative "../../spec_helper"

module InCSV
  describe Database do
    describe "initialize" do
      it "accepts a CSV file" do
        database = Database.new(PRODUCTS)
        expect(database).to be_a(Database)
      end
    end

    describe "db_path" do
      it "is named after the CSV" do
        database = Database.new(PRODUCTS)
        expect(database.db_path).to match(/#{PRODUCTS.basename(".csv")}\.db/)
      end
    end

    describe "create" do
      it "creates the table" do
        database = Database.new(PRODUCTS)
        database.create
        expect(database.db[:products].columns).to include(:name)
        expect(database.db[:products].columns).to include(:date_added)
        expect(database.db[:products].columns).to include(:price)
      end
    end
  end
end
