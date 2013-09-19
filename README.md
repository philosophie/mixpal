# Mixpal

As the JavaScript library is Mixpanel's preferred method of usage,
Mixpal aims to make it easier to work with from your Rails backend.
Most notably it persists tracking data across redirects, perfect for handling
events like user sign ups or form submissions.

## Installation

### With Bundler

1. Add to Gemfile: `gem "mixpal"`
1. `$ bundle`

### Standalone

```bash
$ gem install mixpal
```

## Setup

### In your controller

```ruby
class ApplicationController < ActionController::Base
  include Mixpal::Integration
  mixpanel_identity :current_user, :email
end
```

`mixpanel_identity` tells Mixpal how to identify your users. This
is used to alias and identify with Mixpanel. The first arg should be a method
on this controller that returns an object to which we can send the second arg.
In this example, we'll identify our user by `current_user.email`.

### In your layout

```ruby
<%= mixpanel.render() %>
```

## Usage

Mixpal exposes its helpers to your controllers, views, and view helpers.

### Tracking Events

```ruby
mixpanel.track "Event Name", property_1: "A string", property_2: true
```

### Registering New Users

When a new user signs up, you want to create their profile on Mixpanel as well
as alias all event data to their identifier. As per Mixpanel's docs, you should
only do this once per user.

```ruby
mixpanel.register_user user.attributes.slice("name", "email")
```

`register_user` will attempt to identify and convert the following properties to
Mixpanel "special properties": `name`, `email`, and `created_at`.

### Updating Existing Users

When a user changes their profile...

```ruby
mixpanel.update_user email: "mynewemail@example.com"
```

As with `register_user`, this method will also identify "special properties".

### Persistance Across Redirects

Mixpal stores any tracked events or user data in `Rails.cache` when
it detects a redirect so it can output the appropriate Mixpanel JS integration
code to the client on the following render. This enables us to do cool things
like:

```ruby
class UsersController < ActionController::Base
  def create
    # ... do cool stuff ...
    mixpanel.register_user name: @user.name, email: @user.email
    redirect_to root_path
  end

  def update
    # ... more cool stuff! ...

    mixpanel.update_user name: @user.name
    mixpanel.track "Profile Updated"

    redirect_to root_path
  end
end
```

#### Customizing the storage adapter

You can specify a custom persistence storage adapter like so:

```ruby
Mixpal::Tracker.storage = MyCustomAdapter.new
```

Storage adapters must implement the following API: `write(key, value)`,
`read(key)`, and `delete(key)`.

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b feature/my-new-feature`)
1. Make your changes
1. Add accompanying tests
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin feature/my-new-feature`)
1. Create new Pull Request
