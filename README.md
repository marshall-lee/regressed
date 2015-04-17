# Regressed
[![Build Status](https://travis-ci.org/marshall-lee/regressed.svg)](https://travis-ci.org/marshall-lee/regressed)

Regression Test Prediction implementation as [described](http://tenderlovemaking.com/2015/02/13/predicting-test-failues.html) by [Aaron Patterson](https://github.com/tenderlove). [RSpec](https://github.com/rspec) and [Minitest](https://github.com/seattlerb/minitest) are supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'regressed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install regressed

## Usage

RSpec:

```ruby
# spec/spec_helper.rb
require 'regressed/rspec'
```

Minitest:

```ruby
require 'regressed/minitest'
```

## Contributing

1. Fork it ( https://github.com/marshall-lee/regressed/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
