require "incsv/column_type"

# The order that these files are required defines the priority order of
# column guessing; they should therefore be required in order from most-
# to least-specific (with string always last).
require "incsv/types/date"
require "incsv/types/currency"
require "incsv/types/integer"
require "incsv/types/decimal"
require "incsv/types/string"
