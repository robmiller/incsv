$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'incsv'

PRODUCTS = Pathname(__dir__) + "data" + "products.csv"

db_file = PRODUCTS.to_s.sub(/\.csv$/, ".db")
if File.exist?(db_file)
  File.unlink(db_file)
end

