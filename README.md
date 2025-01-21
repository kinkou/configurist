# Configurist

```
      {}
    O/
  _/|
,__/ \
____ /
```

## Introduction

The problem that Configurist solves is best described with an example.

Let's imagine that in your Rails project you have organizations and users. Users belong to organizations, and organizations have many users. Each user has a home page, where they can customize text color, background color and title. There are global defaults for these parameters, but organizations can override them. In addition, each user can override the organization defaults.
You plan to make settings editable, so for each setting you will need to retrieve its title and description (to show in the settings editing form), type (boolean, string, number, etc) and constraints (exactly 6 hexadecimal characters, one of 'red', 'green', 'blue', etc).

Describe your settings with JSON Schema (some details omitted for brevity):

```YAML
$id: "default"
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
        pattern: "^[0-9A-F]{6}$"
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

## Terminology, Gem Design, and Limitations

At this stage of development, it is not entirely clear what level of flexibility is required. The constraints enforced by the gem are based on the following assumptions:
- At the root of the settings hierarchy, there must be a record that defines the defaults for the given scope.
- The nature of defaults implies that there can be only one defaults record within a given scope. Everything that inherits from the defaults is considered an override. Defaults must have a value for all settings defined in the scope's schema, including optional ones.
- Settings hierarchies must operate within a single scope.
- Default records and group override records must not be used as settings for configurable records. In essence, they are not "concrete" settings.
- Finally, a settings record cannot be shared between multiple configurable records. Each configurable record must have its own exclusive concrete settings (overrides) record.

### Schema restrictions
Configurist puts some restrictions on the way the settings schemas are defined. At the topmost level, settings data structure must be an object (a hash):

```ruby
"settings" # invalid
[{ prop: 'setting' }] # invalid

{ prop: 'setting', group: { prop: 'setting' } } # valid
```

### Schema defaults
When a root node in a settings scope is created Configurist understands that this is the defaults, so it will require all properties to be present, and is scope schema defines any defaults, it will fill them in automatically, unless they are overridden in the data that you supply at the time of creation.

## Requirements

- Rails >= 8. Currently, Configurist is tested only with Rails 8, but it is likely compatible with older versions as it relies on basic Rails functionality.
- PostgreSQL >= 15. The gem uses the `NULLS NOT DISTINCT` index parameter for `Configurist::Models::Settings` model to ensure consistency (see the Limitations section for more details).

## Settings
```ruby
# Loaded schemas are stored here
Configurist.schemas #=> { 'your_schema_2' => {…}, 'your_schema_2' => {…} }

# Sets maximum settings nesting (0-bazed)
Configurist.max_nesting #=> 9
```

## Used libraries
For organizing records into trees Configurist uses the amazing [ancestry](https://github.com/stefankroes/ancestry) gem, which will have your back covered as your collection of settings records grows.

For working with schemas it uses the great [json_schemer](https://github.com/davishmcclurg/json_schemer) gem, which is probably the most advanced one in the Ruby ecosystem when it comes to supporting the latest JSON Schema standards.

## Configuration
It is [recommended](https://github.com/stefankroes/ancestry/tree/master?tab=readme-ov-file#configure-ancestry-defaults) that you set `default_ancestry_format` setting of the `ancestry` library to `:materialized_path2`.
