# incsv

incsv is a tool for quickly interrogating CSV files using SQL and the
Ruby programming language.

It works by loading the CSV into an [SQLite][] database and then
dropping you into an interactive Ruby shell. You can then use the
[Sequel][] database library to perform further exploratory analysis.

[SQLite]: https://www.sqlite.org/
[Sequel]: http://sequel.jeremyevans.net/

## Installation

incsv can be installed via RubyGems:

    $ gem install incsv

## Usage

### The quick version

The following command will drop you into a [REPL][] prompt:

	$ incsv console path/to/file.csv

A Sequel connection to the database is stored in a variable called
`@db`. The name of the table is based on the filename of the CSV; so, if
your CSV file is called `products.csv`, then data will be imported into
a database table called `products`.

A quick example:

	> @db[:products].select(:name).reverse_order(:price).take(5)
	=> [{:name=>"Makeshift battery"},
	  {:name=>"clothing iron"},
	  {:name=>"toy alien"},
	  {:name=>"enhanced targeting card"},
	  {:name=>"Giddyup Buttercup"}]

[REPL]: https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop

### The less-quick version

To use incsv, you essentially just need to point it at a CSV file. It’ll
then take care of parsing the CSV, figuring out the nature of the data
within it, creating a database and a table, and importing the data.

To perform all of these steps and be given an interactive console once
they’re done, you can use the `console` command.

Let’s imagine we have a CSV file that contains some product information:

	$ head -3 products.csv
	name,date_added,price
	"Acid",2013-03-24,£38
	"Abraxo cleaner",2016-09-25,£21

Here we can see that we have three columns: the product name, which is
just a string; the date the product was added, which is an
ISO-8601–formatted date; and the price, which is a currency value in
dollars.

In my sample data there are 515 products (plus a header row):

	$ wc -l products.csv
	516

In order to query this data, we can pass the CSV file to incsv:

	$ incsv console products.csv
	Found database at products.db
	Connection is in @db

	Primary table name is products
	Columns: _incsv_id, name, date_added, price

	First row:
	_incsv_id, name, date_added, price
	1, Acid, 2013-03-24, 0.38E2

	Not sure what to do next? Try this:
	@db[:products].count
	>

It tells us some information about the file, and about the assumptions
it has made about the file. We can see that it’s imported the contents
of the file into a table called `products`, and that it’s used the
column names from the CSV to name the columns in the database table.

It also shows us the first row, where you might have noticed that the
price is in a slightly odd representation. That’s because incsv will
look at what type of data seems to be stored in your CSV before
importing it. In this case, it knows that the `date_added` column
contains a date, and that the `price` column contains a currency value.
In the former case, that means converting it into an actual SQL date. In
the latter case, this means converting it to `BigDecimal` format (and
storing it in the database as `DECIMAL(10, 2)`, so that we don’t either
lose any precision by storing the value as a float, or lose the ability
to do numerical calculations by storing it as a string.

It then suggests a query for us to run, which might generally be the
first thing that you’d want to know about the dataset: how many values
are there? We can run it and see:

	> @db[:products].count
	=> 515

Excellent! It’s imported every one of the products that were in the CSV.

From this point on we can do any kind of analysis of the data that we
like; we have all the power of SQLite and Sequel at our fingertips. For
example, to get the number of products added each year:

	> @db[:products].group_and_count{strftime("%Y", date_added).as(year)}.all
	=> [{:year=>"2013", :count=>132}, {:year=>"2014", :count=>123}, {:year=>"2015", :count=>131}, {:year=>"2016", :count=>129}]

Or to get the total value of products added today:

	> @db[:products].select{sum(price).as(total_cost)}.where(date_added: Date.today).first
	=> {:total_cost=>40}

We can also do processing in Ruby, if there’s anything that’s difficult
in pure SQL. Imagine wanting to convert the product names to
URL-friendly “slugs”. This is pretty easy in Ruby. Let’s try it out on
the top 10 most expensive products:

	> @db[:products].select(:name).reverse_order(:price).limit(10).each do |product|
	*   puts product[:name].gsub(/\s/, "-").squeeze("-").downcase.gsub(/[^a-z0-9\-]/, "")
	* end
	makeshift-battery
	clothing-iron
	toy-alien
	enhanced-targeting-card
	giddyup-buttercup
	mole-rat-teeth
	empty-teal-rounded-vase
	pre-war-money
	bowling-ball
	toothbrush

Hopefully this illustrates what you can do with incsv!

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will create
a git tag for the version, push git commits and tags, and push the
`.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/robmiller/incsv. This project is intended to be
a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant](http://contributor-covenant.org)
code of conduct.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

