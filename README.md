# Lawkeeper

Lawkeeper - Simple authorization policies for Rack apps

Lawkeeper was heavily inspired by the Pundit authorization gem.  Lawkeeper
follows a very similar pattern, but is more agnostic and geared towards use
in smaller Rack applications.

## Installation

Add this line to your application's Gemfile:

    gem 'lawkeeper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lawkeeper

## Usage

Lawkeeper makes a couple basic assumptions

* You have a `current_user` helper
* You create policy files like `PostPolicy` for a `Post` model
* You have a headers method with a settable hash for response headers

After setting up your model policies, include `Lawkeeper::Helpers`
into your app.  Let's assume Sinatra as our example:

```ruby
helpers do
  include Lawkeeper::Helpers
end
```

This provides a few useful helpers:

* `can?` - for checking if the current_user is permitted an action on the
  record
* `authorize` - checks if the user can perform the action, otherwise raise
  `Lawkeeper::NotAuthorized`
* `skip_authorization` - used to flag an action as not needing authorization

TODO: write action and view usage examples

## Ensuring authorization with middlewares

Lawkeeper provides `EnsureWare` for checking that authorization was performed
for all actions.  When the `authorize` or `skip_authorization` methods are
employed in actions, response headers are set.  The middleware then checks
and deletes the headers.  If the header was not present, a 403 forbidden status
will be returned.

This is useful to ensure you do not forget to authorize the resource in any
given action.

If you do not wish to enforce such a check, you should employ the `ScrubWare`
middleware instead.  This is simply responsible for stripping Lawkeeper headers
before sending the response on its way.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
