$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'incsv'

PRODUCTS = Pathname(__dir__) + "data" + "products.csv"

