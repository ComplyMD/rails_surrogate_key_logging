# rails-surrogate-key-logging

This gem enhances and uses Rails' built-in `ParameterFilter` to add "Surrogate Key" logging.

## Installation

- Add `gem :rails_surrogate_key_logging` to your Gemfile.
- Run `bin/bundle install`
- Add `include SurrogateKeyLogging::ActionController::Params` to your `ApplicationController`
- Add `include SurrogateKeyLogging::ActiveRecord::Attributes` to your `ApplicationRecord`



## Configuration

In a new application initializer (`config/initializers/surrogate_key_logging.rb`) or in your `config/environments/*.rb`, use the following block:

```ruby
SurrogateKeyLogging.configure do |config|
  config.key = value
end
```

### Config

Key | Type | Default | Description
---|---|---|---
`enabled` | Boolean | `Rails.env.production?` | Whether surrogate logging is injected into Rails.
`debug` | Boolean | `false` | Whether to log a statement showing that a surrogate replacement happened and what the mapping from surrogate to value, and logs from the key store (Such as queries made by ActiveRecord to it's Surrogate model).
`key_prefix` | String | `''` | This string will be prepended to generated surrogates. Can make it easier to identify a surrogate in logs.
`key_for` | Proc \| Lambda \| `responds_to?(:call)` | `-> (value) { "#{config.key_prefix}#{SecureRandom.uuid}" }` | The method used to generate a surrogate for a given value. While the `value` is supplied to the method, it is generally considered insecure for the surrogate to be derivable from it's value.
`cache` | Boolean | `true` | Should the key mananger maintain an in-memory cache of value -> surrogate map that have been used. When in a server context, this cache will last for the lifetime of a single request. The cache can also be manually busted at any time by calling `SurrogateKeyLogging.reset!`.
`cache_key_for` | Proc \| Lambda \| `responds_to?(:call)` | `-> (value) { value }` | The method used to create the keys used in the cache. Typically this should be left to the default unless you expect to make many surrogates for very large values.
`key_ttl` | Integer | `90.days` | Used by `bin/rails skl:clear:stale` to delete old surrogates.
`key_store` | Symbol | None | The key store to use. See [Key Stores](#key-stores).



## Key Stores

Key Store | Config Value
---|---
[ActiveRecord](#active-record) | `:active_record`

### Active Record

This will use a `SurrogateKeyLogging::Surrogate` model to manage surrogates. This will require adding `surrogate_key_logging_#{Rails.env}` to your application's `config/database.yml` See [Example](#example-database-yml). After configuring your `config/database.yml` you will need to run `bin/rails skl:key_store:active_record:db:create` and `bin/rails skl:key_store:active_record:db:migrate`.

#### Example database.yml
```yml
default: &default
  adapter: mysql2
  username: <%= Rails.application.credentials.database[:username] %>
  password: <%= Rails.application.credentials.database[:password] %>
  host: 127.0.0.1
  port: 3306
  database: myapp_<%= Rails.env %>
  prepared_statements: true

surrogate_key_logging_default: &surrogate_key_logging_default
  <<: *default
  database: surrogate_keys_<%= Rails.env %>



development:
  <<: *default

test:
  <<: *default

production:
  <<: *default



surrogate_key_logging_development:
  <<: *surrogate_key_logging_default

surrogate_key_logging_test:
  <<: *surrogate_key_logging_default

surrogate_key_logging_production:
  <<: *surrogate_key_logging_default
```



## Usage

### Controllers

In any controller including `SurrogateKeyLogging::ActionController::Params` you may use the `surrogate_params(*params, action: '*')` method. This method may be used multiple times. Pass the `action` argument to limit those `params` to only that `action` or omit it to apply those `params` to ALL actions in that controller.

#### Params format
Param | Examples | Output
---|---|---
`:foo` | `{ foo: 'bar1', another: {foo: 'baz1'}, foobar: 'barbaz' }` | `{foo: SURROGATE, another: { foo: SURROGATE }, foobar: 'barbaz' }`
`'another.foo'` | `{ foo: 'bar1', another: { foo: 'baz1' }, foobar: { another: { foo: 'barbaz' } } }` | `{ foo: 'bar1', another: { foo: SURROGATE }, foobar: { another: { foo: SURROGATE } } }`
`'another[foo]'` | `{ foo: 'bar1', another: { foo: 'baz1' }, foobar: { another: { foo: 'barbaz' } } }` | `{ foo: 'bar1', another: { foo: SURROGATE }, foobar: { another: { foo: 'barbaz' } } }`

#### Example Controller
```ruby
class WidgetsController < ApplicationController
  surrogate_params :name
  surrogate_params :owner, action: :search

  def name
    ...
  end

  def search
    ...
  end
end
```

In this example the `name` parameter will be surrogated in all requests to this controller, and the `owner` parameter will surrogated only in requests to the `search` action.



### Models

In any controller including `SurrogateKeyLogging::ActiveRecord::Attributes` you may use `surrogate_parent_names(*names)` and `surrogate_attributes(*attrs)`. All permutations of parent names to attributes will be used to create filters. By default `surrogate_parent_names` is initialized with the singular and plural names of the model.

#### Example Model
```ruby
class Widget < ApplicationRecord
  surrogate_parent_names :things
  surrogate_attributes :name, :owner
end
```

In this example, the following filters will be used to look for attributes to be surrogated: `widget.name`, `widget[name]`, `[widget][name]`, `widgets.name`, `widgets[name]`, `[widgets][name]`, `things.name`, `things[name]`, `[things][name]`
