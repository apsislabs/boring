# Boring
## Because your presentation layer shouldn't be interesting

[![Gem Version](https://badge.fury.io/rb/boring_presenters.svg)](https://badge.fury.io/rb/boring_presenters) [![Build Status](https://travis-ci.org/apsislabs/boring.svg?branch=master)](https://travis-ci.org/apsislabs/boring) [![Inline docs](http://inch-ci.org/github/apsislabs/boring.svg?branch=master)](http://inch-ci.org/github/apsislabs/boring)

**Note:** while we're actively using `boring` in production, it is still actively under development, and you should expect breaking changes.

## Usage

Below is an example of usage for a classic Rails controller/view pattern.

```ruby
# presenters/user_presenter.rb

class UserPresenter < Boring::Presenter
  # Declare the arguments needed to bind to presenter and their type
  arguments user: User

  # Declare pass-through methods
  delegate :birth_date, to: :user

  # Methods to be handled by the presenter
  def name
    "#{user.first_name} #{user.last_name}".strip
  end
end

# controllers/users_controller.rb

class UsersController < ApplicationController
  def index
    @users = User.all
    @user_presenter = UsersPresenter.new
  end
end
```

```erb
# views/users/index.html.erb

<ul>
  <% @users.each do |user| %>
    <% @user_presenter.bind(user: user) %>
    <li>
      <p>Full Name: <%= @user_presenter.name %></p>
      <p>Birthday: <%= @user_presenter.birth_date %></p>
    </li>
  <% end %>
</ul>
```

Some things worth noting that set `boring` apart from other presentation layers:

1. **Explicit Delegation**: only methods intended for presentation layer should be allowed in the presenter. `boring` will never pass `super_dangerous_method!` through to your bound object unless you _want_ it to.
2. **Type-Safe Bindings**: the `arguments` method in the `Boring::Presenter` class lets you set up type checking for the arguments passed to the `bind` method. If you try to bind a `Foo` to your `BarPresenter`, we'll raise an exception.
3. **Separate Objects**: The presenter doesn't take over for your bound object; whether that bound object is available to your view is up to you, but you should never be unsure if you're dealing with a `Foo` or a `FooPresenter`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wkirby/boring.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
