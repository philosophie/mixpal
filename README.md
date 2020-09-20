# Mixpal [![Build Status](https://travis-ci.org/philosophie/mixpal.svg?branch=master)](https://travis-ci.org/philosophie/mixpal)

As the JavaScript library is Mixpanel's preferred method of usage,
Mixpal aims to make it easier to work with from your Rails backend.
Most notably it persists tracking data across redirects, perfect for handling
events like user sign ups or form submissions.

## Installation

First make sure you follow the instructions for installing Mixpanel's JS
library:

https://mixpanel.com/help/reference/javascript

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

### Custom Events

Mixpal allows you to define custom mixpal methods to use in your controllers/views

1. create a custom module and define your mixpal events
```ruby
module YourCustomEventsModule
  def sign_up(user)
    register_user user.attributes.slice('name', 'email')
    track 'User signed up'
  end
end
```

2. create a mixpal.rb initializer and configure mixpal to use your module
```ruby
Mixpal.configure do |config|
  config.helper_module = YourCustomEventsModule
end
```

3. use in controllers/views
```ruby
class UserController < ActionController::Base
  def create
    # ... do cool stuff ...
    mixpal.sign_up(user)
    redirect_to root_path
  end
end
```

### Persistance Across Redirects

Mixpal stores any tracked events or user data in the session when
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

#### A note about `CookieStore` size limit

When using Rails' default `ActionDispatch::Session::CookieStore`, a 4K cookie
size limit is enforced. This cookie is shared by anything using the session.
If you anticipate tracking many events or large data sets to Mixpal,
[consider a different session store](http://guides.rubyonrails.org/action_controller_overview.html#session).

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b feature/my-new-feature`)
1. Make your changes
1. Add accompanying tests
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin feature/my-new-feature`)
1. Create new Pull Request

## Releasing

Bump `lib/mixpal/version.rb` then build + release with docker-compose. If you
prefer local development, inspect the Dockerfile to get your local env built.

```
docker-compose build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g)
docker-compose run rake release
```
