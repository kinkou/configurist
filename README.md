# Configurist

```
      {}
    O/
  _/|
,__/ \
____ /
```

The problem that Configurist solves is best described with an example.

Let's imagine that in your Rails project you have organizations and users. Users belong to organizations, and organizations have many users. Each user has a home page, where they can customize text color, background color and title. There are global defaults for these parameters, but organizations can override them. In addition, each user can override the organization defaults.
You plan to make settings editable, so for each setting you will need to retrieve its title and description (to show in the settings editing form), type (boolean, string, number, etc) and constraints (exactly 6 hexadecimal characters, one of 'red', 'green', 'blue', etc).

Describe your settings with JSON Schema (some details omitted for brevity):

```YAML
_id: "default"
type: "object"
properties:
  home_page:
    type: "object"
    title: "Home page"
    description: "User's home page settings"
    properties:
      text_color:
        type: "string"
        title: "Text color"
        description: "Home page text color"
        pattern: "^[0-9A-F]{8}$"
      background_color:
        type: "string"
        title: "Background color"
        description: "Home page background color"
        enum: ["white", "black"]
      title:
        type: "string"
        title: "Page title"
        description: "Home page title"
        minLength: 1
```

Save the schema to `config/configurist_schemas/default.yml` inside your Rails app directory where the gem will find and auto-load it.

Now, make your models configurable:

```ruby
class Organization < ApplicationRecord
  has_configurist_settings
end

class User < ApplicationRecord
  has_configurist_settings
end
```

Then create global defaults:

```ruby
global_defaults_data = {
  home_page: {
    text_color: "FFFFFF",
    background_color: "black",
    title: "User's home page"
  }
}

global_defaults = Configurist::Models::Settings.create!(
  data: global_defaults_data,
  scope: "default"
)
```

Now, create organization's overrides:

```ruby
organization = Organization.find_by(name: "Organization with custom settings")

organization_overrides_data = {
  home_page: {
    text_color: "00FF00"
  }
}

organization_overrides = Configurist::Models::Settings.create!(
  data: organization_overrides_data,
  scope: "default",
  parent: global_defaults,
  configurable: organization
)
```

And finally, create user's overrides:

```ruby
user = User.find_by(name: "The user with custom settings")

user_overrides_data = {
  home_page: {
    background_color: "white",
  }
}

user_overrides = Configurist::Models::Settings.create!(
  data: user_overrides_data,
  scope: "default",
  parent: organization_overrides,
  configurable: user
)
```

Now you can do this:

```ruby
organization_settings = organization.settings(scope: "default")

organization_settings.home_page.text_color.value #=> "00FF00" (overridden on the organization level)
organization_settings.home_page.background_color.value #=> "black" (from global defaults)
organization_settings.home_page.title.value #=> "User's home page" (from global defaults)

user_settings = organization.settings(scope: "default")

user_settings.home_page.text_color.value #=> "00FF00" (overridden on the organization level)
user_settings.home_page.background_color.value #=> "white" (overridden on the user level)
user_settings.home_page.title.value #=> "User's home page" (from global defaults)
```

Settings metadata is available too:

```ruby
user_settings.home_page.text_color._schema.name #=> "Text color"
user_settings.home_page.text_color._schema.description #=> "Home page text color"
```

TBC

