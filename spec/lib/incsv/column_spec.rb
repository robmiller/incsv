require_relative "../../spec_helper"

module InCSV
  describe Column do
    describe Column::Types do
      describe Column::Types::Date do
        it "matches dates" do
          expect(Column::Types::Date.new("2015-01-01").match?).to be_truthy
        end
      end

      describe Column::Types::Currency do
        it "matches dollars" do
          expect(Column::Types::Currency.new("$4.90").match?).to be_truthy
          expect(Column::Types::Currency.new("$4").match?).to be_truthy
          expect(Column::Types::Currency.new("$4,806").match?).to be_truthy
        end

        it "matches pounds" do
          expect(Column::Types::Currency.new("£4.90").match?).to be_truthy
          expect(Column::Types::Currency.new("£4").match?).to be_truthy
          expect(Column::Types::Currency.new("£4,806").match?).to be_truthy
        end

        it "treats currency as a fixed precision number in the database" do
          expect(Column::Types::Currency.db_type).to eq("DECIMAL(10,2)")
        end

        it "strips currencies and just stores the number" do
          expect(Column::Types::Currency.new("$4.90").clean_value).to eq(BigDecimal("4.9"))
          expect(Column::Types::Currency.new("$4,690,300.90").clean_value).to eq(BigDecimal("4690300.9"))
        end
      end

      describe Column::Types::String do
        it "matches anything" do
          expect(Column::Types::String.new("foo").match?).to be_truthy
          expect(Column::Types::String.new(nil).match?).to be_truthy
        end
      end
    end

    describe "initialize" do
      it "accepts a list of values" do
        column = Column.new(["foo", "bar"])
        expect(column).to be_a(Column)
      end
    end

    describe "type" do
      it "interprets ISO-format dates as dates" do
        column = Column.new(["2015-01-01", "1994-04-01"])
        expect(column.type).to eq(:date)
      end

      it "interprets dollar and pound values as currency" do
        column = Column.new(["£3.90", "$4,909.20"])
        expect(column.type).to eq(:currency)
      end

      it "interprets mixed columns as strings" do
        column = Column.new(["£3.90", "2015-01-01"])
        expect(column.type).to eq(:string)
      end

      it "interprets columns with null values correctly" do
        column = Column.new(["2016-04-08", nil, "2015-01-01"])
        expect(column.type).to eq(:date)

        column = Column.new([nil, "$4.09", nil, "£4,984,401.01"])
        expect(column.type).to eq(:currency)

        column = Column.new(["foo", nil, "baz", nil])
        expect(column.type).to eq(:string)
      end

      it "interprets unknown formats as strings" do
        column = Column.new(["foo", "bar"])
        expect(column.type).to eq(:string)
      end
    end
  end
end
