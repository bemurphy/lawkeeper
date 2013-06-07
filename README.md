# Lawkeeper

Lawkeeper - Simple authorization policies for Rack apps

Lawkeeper was heavily inspired by the [Pundit](https://github.com/elabs/pundit)
authorization gem.  Lawkeeper follows a very similar pattern, but is more
agnostic and geared towards use in smaller Rack applications.

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

### Declaring policy classes

By default, Lawkeeper follows a convention of mapping policy classes like
`PostPolicy` for a `Post` class, `CommentPolicy` for `Comment`, etc.

The simplest way to declare a post policy is inherit `Lawkeeper::Policy`
and declare predicates for policy checks:

```ruby
class PostPolicy < Lawkeeper::Policy
  def read?
    true
  end

  def update?
    record.owned_by?(user)
  end
end
```

Lawkeeper makes no assumptions about the name of your policy queries.  You can
call them `show?` or `read?`, `delete?` or `destroy?`, whichever you prefer.  The
only requirement is that they end with '?'.

Policy classes are instantiated with the current user and a record for checking.

If you wish to use an unconventially named Policy class for a model, add the
`.policy_class` class method to your model.  For example:

```ruby
class Post
  def self.policy_class
    OwnershipPolicy
  end
end
```

Lawkeeper helper methods will prefer the `policy_class` specified if it exists.

### Specifying Scope classes for policy use

For finding records for collection records (like an index) it is possible to
do scoped find if your relational or document mapper permits it.  This is
accomplished by creating a `Scope` class inside your policy class.  Take
this example for Ohm:

```ruby
class PostPolicy < AppPolicy
  class Scope < Lawkeeper::Policy::Scope
    def resolve
      scope.find(published: "true")
    end
  end
end
```

You can proceed to use this in an action to find posts where published is the
string "true":

```ruby
@posts = policy_scope(Post)
```

The policy scope lookup is handled by a scope finder stored at `Lawkeeper.scope_finder`.
Currently Ohm and ActiveRecord adapters are provided.  The finder only has one requirement,
it must respond to `call`.  You can use a class method or Proc to facilitate this.  It
should return a capitalized string representing the class, such as "Post" or "Comment".

If you wish to use `policy_scope` you should configure a finder appropriate for your storage:

```ruby
Lawkeeper.scope_finder = Lawkeeper::ScopeFinders::Ohm
# or
Lawkeeper.scope_finder = Proc.new { |s| ... }
```

### Authorizing in actions

To authorize in a controller action is simple:

```ruby
get "/post/:id" do
  @post = Post.find(id)
  authorize @post, :read
  erb :post_show
end
```

If authorize is permitted (which it usually should be) the action will continue
as normal.  If it fails, Lawkeeper::NotAuthorized will be raised.

### Checking in views

Lawkeeper provides a `can?` helper to use in your views:

```ruby
<% if can? :edit, @post %>
  <a href="/posts/<%= @post.id %>/edit">Edit Post</a>
<% end %>
```

The `can?` method is a check, it will not raise authorization exceptions.

### Specifying policy classes

If you wish to specify a policy class at runtime for a call to `can?` or `authorize`,
you can pass a policy class as an option third argument.

```ruby
authorize @post, :read, OwnershipPolicy
```

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

If you'd prefer to not use middleware at all, it's advised you set Lawkeeper to
simply skip the setting of headers:

```ruby
Lawkeeper.skip_set_headers = true
```

This will not prevent how Lawkeeper does its primary job of authorizing policy
actions.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
