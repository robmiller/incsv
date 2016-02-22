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
        expect(database.created?).to eq(false)
        database.create
        expect(database.db[:products].columns).to include(:name)
        expect(database.db[:products].columns).to include(:date_added)
        expect(database.db[:products].columns).to include(:price)
        expect(database.created?).to eq(true)
      end
    end

    describe "import" do
      it "imports the data" do
        database = Database.new(PRODUCTS)
        database.import
        expect(database.created?).to eq(true)
        expect(database.db[:products].count).to eq(4)

        first_product = database.db[:products].where(name: "Hammer").first
        expect(first_product[:date_added]).to eq(Date.new(2016, 1, 1))
      end
    end
  end
end
