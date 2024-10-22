# LiquidVectorGraphic
This library is used for rendering SVG graphics with Liquid/"Solid" logic tags.

## Roadmap

1. Allow interpolation of arbitrary liquid drops via some form of dynamic drop creation (eg: expose arbitrary structures to the template)
2. Allow the building of forms with basic syntax (eg: form_tag for: 'first_name', label: 'First Name', default: nil, required: true)
3. Allow scoping via dot-notation for forms (eg form_tag for: '[some_structure].attribute')
4. Create module for URL access (eg [module]/path/to/something) as an API exposure to the template

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'liquid-vector-graphic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install liquid-vector-graphic

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/liquid-vector-graphic. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
