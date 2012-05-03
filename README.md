# FuzzyMatcher

Gem for fuzzy searching with FQA algorithm.

## Installation

Add this line to your application's Gemfile:

    gem 'fuzzy_matcher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fuzzy_matcher

## Avalable databases

Currently supported `Postgresql('pg')` and `Mysql('mysql')`

## Requirements

Tested in ruby 1.9.2.

Gems needed - pg, mysql2.

In DB you should have metric calculation function (f.e. `levenshtein` in pg and `damlev` in mysql).

In Mysql you should compile damlev.so

In Postgre you have function fuzzystrmatch

## Usage

First add require if you use it in separate script:
    $ require 'fuzzy_matcher'

Next you should create connection:
    $ conn = FuzzyMatcher::Adapter.new(db_type, db_name, username, password)
F.e.
    $ conn = FuzzyMatcher::Adapter.new('pg','dip_lib','postgres','password')

Next step is taking node values:
    $ values = FuzzyMatcher::Indexer.index!(connection, distance_methic_name, height)
F.e.
    $ values = FuzzyMatcher::Indexer.index!(conn, 'levenshtein', 2)

Last is searching:
    $ FuzzyMatcher::Searcher.find(values, connection, distance_methic_name, height, accuracy, aim)
F.e. if you looking for words like 'barrels' and accuracy of searching is 3, you should write like that:
    $ FuzzyMatcher::Searcher.find(values, conn, 'levenshtein', 2, 3, 'barrels')

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
