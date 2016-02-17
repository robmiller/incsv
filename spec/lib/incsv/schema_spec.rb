require_relative "../../spec_helper"

module InCSV
  describe Schema do
    describe "initialize" do
      it "accepts a CSV file" do
        schema = Schema.new(PRODUCTS)
        expect(schema).to be_a(Schema)
      end
    end

    describe "columns" do
      it "returns the columns in the CSV" do
        schema = Schema.new(PRODUCTS)
        expect(schema.columns).not_to be_empty
        expect(schema.columns[0].type.name).to eq(:string)
        expect(schema.columns[1].type.name).to eq(:date)
        expect(schema.columns[2].type.name).to eq(:currency)
      end
    end
  end
end
