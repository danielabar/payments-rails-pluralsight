<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Integrating Payments with Rails](#integrating-payments-with-rails)
  - [Getting Started](#getting-started)
    - [App Overview](#app-overview)
    - [Initializing Sample App](#initializing-sample-app)
  - [Creating Users](#creating-users)
    - [Devise](#devise)
    - [Creating the Navigation Bar](#creating-the-navigation-bar)
  - [Creating Publications](#creating-publications)
  - [Publication Model](#publication-model)
    - [Admin and Subscriber Modelling](#admin-and-subscriber-modelling)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Integrating Payments with Rails

> My notes from Pluralsight [course](https://app.pluralsight.com/library/courses/ruby-on-rails-integrating-payments/table-of-contents)

Versions:

```bash
rbenv local
# 2.7.2

rails --version
# Rails 6.1.6
```

(instructor using rails 4.1.2)

## Getting Started

### App Overview

Will build subscription app where users can sign in (using devise), and purchase a subscription to get access to a weekly podcast on tech. Will be integrating Stripe for payments.

### Initializing Sample App

```bash
rails new subscription-app
cd subscription-app
bin/rails db:create
# Created database 'db/development.sqlite3'
# Created database 'db/test.sqlite3'
bin/rails s
```

Verify Rails landing page at `http://localhost:3000/`

## Creating Users

### Devise

Will use this gem: https://github.com/heartcombo/devise

Devise automatically adds routes for user management including:
* new_user_session GET /users/sign_in
* destroy_user_session DELETE /users/sign_out
* new_user_registration GET /users/sign_up

Provides helper methods including:
* `authenticate_user!` - run before any controller action to ensure a valid user is signed in
* `user_signed_in?` - check if a current user is logged in
* `current_user` - reference to user model object that is currently logged in
* `user_session` - reference to session object that Devise creates to contain the signed in user

**User Model**

Users will have `email` and `password` fields, used to authenticate to the app, with support from devise. Devise will create the user table with default columns that make sense for most web apps.

We'll also need to design a simple UI to let users sign up, sign in, sign out, and display their current info.

**Installing Devise**

Follow instructions on project homepage: https://github.com/heartcombo/devise#getting-started
* add to Gemfile, bundle install
* rails generate devise:install

Creates some files:
```
create  config/initializers/devise.rb
create  config/locales/devise.en.yml
```

And some further instructions:
```
Depending on your application's configuration some manual setup may be required:

1. Ensure you have defined default url options in your environments files. Here
   is an example of default_url_options appropriate for a development environment
   in config/environments/development.rb:

     config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

   In production, :host should be set to the actual host of your application.

   * Required for all applications. *

2. Ensure you have defined root_url to *something* in your config/routes.rb.
   For example:

     root to: "home#index"

   * Not required for API-only Applications *

3. Ensure you have flash messages in app/views/layouts/application.html.erb.
   For example:

     <p class="notice"><%= notice %></p>
     <p class="alert"><%= alert %></p>

   * Not required for API-only Applications *

4. You can copy Devise views (for customization) to your app by running:

     rails g devise:views

   * Not required *
```

Add the config as per step 1 of instructions.

Devise automatically redirects user to root url after successful registration or login, therefore, need to define `root` in `config/routes.rb`. So we need to define a page in our app for this.

Start by adding it to router:

```ruby
# subscription-app/config/routes.rb
Rails.application.routes.draw do
  root to: "home#index"
end
```

Add a home controller with an empty index method:

```ruby
# subscription-app/app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
  end
end
```

Add corresponding view:

```erb
<!-- subscription-app/app/views/home/index.html.erb -->
<h1>Hello Subscription App!</h1>
```

To test our work so far, start rails server with `bin/rails s`, then navigate to `http://localhost:3000`, should see Hello in h1 tag. This confirms that home/index is the root page for the app.

Now go back and complete instruction 3 from Devise to add flash messages to application layout. Add the messages inside the body tag, before the yield. Devise will use this to display notices and error messages on any page where they occur. Eg: after user successfully signs in, `notice` message will say "You have successfully signed in". If signin fails, an error message shows up in `alert` section.

```erb
<!-- subscription-app/app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>SubscriptionApp</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <p class="notice"><%= notice %></p>
    <p class="alert"><%= alert %></p>
    <%= yield %>
  </body>
</html>
```

Ignore devise instruction 4 as we're not deploying to Heroku or using older Rails version.

We'll also skip instruction 5 as its just a learning app and no need to customize the views provided by Devise.

Shutdown Rails server if running, and perform next instruction from Devise github page. Our model will be `User`. This creates a db migration, model, and routes:

```
bin/rails generate devise User
```

Output:

```
invoke  active_record
create    db/migrate/20220801115656_devise_create_users.rb
create    app/models/user.rb
invoke    test_unit
create      test/models/user_test.rb
create      test/fixtures/users.yml
insert    app/models/user.rb
 route  devise_for :users
```

Run migration with `bin/rails db:migrate`, output:

```
== 20220801115656 DeviseCreateUsers: migrating ================================
-- create_table(:users)
   -> 0.0025s
-- add_index(:users, :email, {:unique=>true})
   -> 0.0010s
-- add_index(:users, :reset_password_token, {:unique=>true})
   -> 0.0008s
== 20220801115656 DeviseCreateUsers: migrated (0.0044s) =======================
```

To see what Devise has done, start server `bin/rails s`.

`http://localhost:3000` should still show Hello message.

`http://localhost:3000/users/sign_in` displays a login form (view was generated by Devise, we didn't have to write any code for this):

![sign in](doc-images/sign-in.png "sign in")

Click on "Sign up" link navigates to registration form, again, we didn't write any code for this `http://localhost:3000/users/sign_up`:

![sign up](doc-images/sign-up.png "sign up")

Try it out by creating a new user: `test1@test.com`/`123456`. Redirects to home page with flash `notice` at top of page displaying success message:

![user create success](doc-images/user-create-success.png "user create success")

But if restart Rails server then refresh page, flash message goes away, so how do we know if user is signed in? Session cookie is there, but later will add navigation bar to allow user to sign in/out.

### Creating the Navigation Bar

Instructor using [Bootstrap 3](https://getbootstrap.com/docs/3.3/).

Will implement as partial so the nav bar can be re-used in multiple views.

Update application layout to link Bootstrap 3 from a CDN, and render the nav partial:

```erb
<!-- subscription-app/app/views/layouts/application.html.erb -->
 <!DOCTYPE html>
 <html>
   <head>
     <title>SubscriptionApp</title>
     <meta name="viewport" content="width=device-width,initial-scale=1">
     <%= csrf_meta_tags %>
     <%= csp_meta_tag %>

     <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
     <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
     <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
   </head>

   <body>
     <%= render "nav" %>
     <p class="notice"><%= notice %></p>
     <p class="alert"><%= alert %></p>
     <%= yield %>
   </body>
 </html>
```

Trying to navigate to `http://localhost:3000/` will get an error because we haven't yet created the nav partial. Error message shows where Rails is looking:

```
Missing partial home/_nav, application/_nav with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:raw, :erb, :html, :builder, :ruby, :jbuilder]}. Searched in:
* "/Users/dbaron/projects/pluralsight/payments-rails-pluralsight/subscription-app/app/views"
* "/Users/dbaron/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/gems/devise-4.7.3/app/views"
* "/Users/dbaron/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/gems/actiontext-6.1.6.1/app/views"
* "/Users/dbaron/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/gems/actionmailbox-6.1.6.1/app/views"
```

Note that partial file names always start with `_`.

The nav will be needed on every page in this app so let's define it in `app/views/application/_nav.html.erb` (need to create new `application` folder in `views` dir). Then paste in the [Bootstrap 3 nav example](https://getbootstrap.com/docs/3.3/components/#nav), remove unused parts and update for our subscription app.

Also using `user_signed_in?` Devise helper to determine if should render a Sign out link in nav, or Sign in and Sign up links (not implemented yet). Also using `link_to` and `destroy_user_session` helper to generate sign out link.

Note that `destroy_user_session` looks like this in output of `bin/rails routes`:

```
 Prefix Verb   URI Pattern                                                                                       Controller#Action
destroy_user_session DELETE /users/sign_out(.:format)                                                                         devise/sessions#destroy
```

```erb
<!-- subscription-app/app/views/application/_nav.html.erb -->
<nav class="navbar navbar-default">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <a class="navbar-brand" href="/">SubscriptionApp</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav navbar-right">
        <% if user_signed_in? %>
          <li>
            <%= link_to "Sign out", destroy_user_session_path, method: :delete %>
          </li>
        <% else %>
          <li><a href="#">Sign in</a></li>
          <li><a href="#">Sign up</a></li>
        <% end %>
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
```

Now navigating to `http://localhost:3000/` looks like this:

![bootstrap nav](doc-images/bootstrap-nav.png "bootstrap nav")

DOM generated from signout link:

```htm
<a rel="nofollow" data-method="delete" href="/users/sign_out">Sign out</a>
```

Clicking Sign out link signs user out and then view re-renders with Sign in and Sign up links. Rails server output shows:

```
Started DELETE "/users/sign_out" for ::1 at 2022-08-27 08:37:33 -0400
Processing by Devise::SessionsController#destroy as HTML
  Parameters: {"authenticity_token"=>"[FILTERED]"}
  User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? ORDER BY "users"."id" ASC LIMIT ?  [["id", 1], ["LIMIT", 1]]
Redirected to http://localhost:3000/
Completed 302 Found in 36ms (ActiveRecord: 0.1ms | Allocations: 4253)


Started GET "/" for ::1 at 2022-08-27 08:37:33 -0400
Processing by HomeController#index as HTML
  Rendering layout layouts/application.html.erb
  Rendering home/index.html.erb within layouts/application
  Rendered home/index.html.erb within layouts/application (Duration: 0.2ms | Allocations: 38)
[Webpacker] Everything's up-to-date. Nothing to do
  Rendered application/_nav.html.erb (Duration: 2.0ms | Allocations: 120)
  Rendered layout layouts/application.html.erb (Duration: 10.9ms | Allocations: 3778)
Completed 200 OK in 13ms (Views: 11.7ms | ActiveRecord: 0.0ms | Allocations: 4162)
```

![nav signed out](doc-images/nav-signed-out.png "nav signed out")

Update nav partial to use devise paths for sign in and sign up:

```erb
<nav class="navbar navbar-default">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <a class="navbar-brand" href="/">SubscriptionApp</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav navbar-right">
        <% if user_signed_in? %>
          <li>
            <%= link_to "Sign out", destroy_user_session_path, method: :delete %>
          </li>
        <% else %>
          <li>
            <%= link_to "Sign in", new_user_session_path %>
          </li>
          <li>
            <%= link_to "Sign up", new_user_registration_path %>
          </li>
        <% end %>
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
```

Links render in dom as:

```htm
<a href="/users/sign_in">Sign in</a>
<a href="/users/sign_up">Sign up</a>
```

Clicking Sign in navigates to `http://localhost:3000/users/sign_in`:

![sign in bootstrap](doc-images/sign-in-bootstrap.png "sign in bootstrap")

Clicking Sign up navigates to `http://localhost:3000/users/sign_up`:

![sign up bootstrap](doc-images/sign-up-bootstrap.png "sign up bootstrap")

Try to sign in with account made earlier in course `test1@test.com"/123456`. It should navigate to home view `http://localhost:3000` with sign in successful message:

![sign in success](doc-images/sign-in-success.png "sign in success")

Enhance nav partial to display the currently signed in user's email address. Use devise helper `current_user` which returns the user model of the user that is currently in the session. Wrap it in an anchor tag for bootstrap nav styling. In a real app, this would link to a user profile/settings page:

```erb
<nav class="navbar navbar-default">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <a class="navbar-brand" href="/">SubscriptionApp</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav navbar-right">
        <% if user_signed_in? %>
          <li>
            <a href="#">Signed in as <%= current_user.email %></a>
          </li>
          <li>
            <%= link_to "Sign out", destroy_user_session_path, method: :delete %>
          </li>
        <% else %>
          <li>
            <%= link_to "Sign in", new_user_session_path %>
          </li>
          <li>
            <%= link_to "Sign up", new_user_registration_path %>
          </li>
        <% end %>
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
```

Refresh home view while signed in, now nav displays email address:

![nav signed in as](doc-images/nav-signed-in-as.png "nav signed in as")

## Creating Publications

**Publication**
- Digital file that paying subscribers can access.
- Will be lightweight for this course as the details are not relevant for payments, which is the focus. Just have title, file_url and description.

**Administrators**
- Users with ability to CRUD publications.
- Have `is_admin` set to true (boolean field).
- We will seed an admin initially, then can create more via console.
- Ruby gems for handling admin roles include: `cancan`, `pundit`, `rolify`. But for this app, will use more basic implementation.

**Administrator and Subscriber Views**
- Admins can create, edit, update publications
- Subscribers can only view publications
- Non-subscribers can see publications, but not access the details

**Adminstrator Publication Routes**
![admin pub routes](doc-images/admin-publication-routes.png "admin pub routes")

**Subscriber Publication Routes**
![subscriber pub routes](doc-images/subscriber-publication-routes.png "subscriber pub routes")

**Non-Subscriber Publication Routes**
![non subscriber pub routes](doc-images/non-subscriber-publication-routes.png "non subscriber pub routes")

## Publication Model

Use Rails model generator, passing in desired attributes, then migrate the database:

```
bin/rails g model publication title:string description:text file_url:string
bin/rails db:migrate
```

Add publication routes using `resources` method, with `only` argument to limit what routes are generated to the read ones:

```ruby
# subscription-app/config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  root to: "home#index"
  resources :publications, only: [:index, :show]
end
```

Create the view files and controller

```bash
mkdir app/views/publications
touch app/views/publications/index.html.erb
touch app/views/publications/show.html.erb
touch app/controllers/publications_controller.rb
```

Implement controller logic:

```ruby
# subscription-app/app/controllers/publications_controller.rb
class PublicationsController < ApplicationController
  def index
    @publicatiosn = Publication.all
  end

  def show
    @publication = Publication.find(params[:id])
  end
end
```

Implement index view - uses `panel` bootstrap component to render list of all publications, displaying each publication's title, description, file_url, and a link to the detail view (aka show). Note that `publication_path` requires the `publication` as an argument in order to generate a url like `/publications/:id`

```erb
<!-- subscription-app/app/views/publications/index.html.erb -->
<h2>Publications</h2>

<% @publications.each do |publication| %>
  <div class="panel panel-default">
    <div class="panel-heading">
      <h3 class="panel-title"><%= publication.title %></h3>
    </div>
    <div class="panel-body">
      <p><%= publication.title %></p>
      <p><%= publication.file_url %></p>
    </div>
    <div class="panel-footer">
      <%= link_to "View more details", publication_path(publication), class: "btn btn-default" %>
    </div>
  </div>
<% end %>
```

Create a publication in Rails console so we'll have something to see in the UI:

```ruby
p = Publication.new(title: "My first publication", description: "This is my first publication", file_url:
"http://myfilelocation.com")
p.save
```

Start server and navigate to `http://localhost:3000/publications`:

![publications index](doc-images/publications-index.png "publications index")

Fill in template for publication show view (i.e. showing the details of the selected publication):

```erb
<!-- subscription-app/app/views/publications/show.html.erb -->
<h2>Publication Details</h2>

<div class="panel panel-default">
  <div class="panel-heading">
    <h3 class="panel-title"><%= @publication.title %></h3>
  </div>
  <div class="panel-body">
    <p><%= @publication.title %></p>
    <p><%= @publication.file_url %></p>
  </div>
</div>
```

Now you can click on the Show Detail button from index view, which navigates to `http://localhost:3000/publications/1`:

![show view](doc-images/show-view.png "show view")

### Admin and Subscriber Modelling

Want to support feature that some users could be administrators:

```
rails g migration add_is_admin_to_users is_admin:boolean
```

Generates:

```ruby
# subscription-app/db/migrate/20220903112034_add_is_admin_to_users.rb
class AddIsAdminToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :is_admin, :boolean
  end
end
```

For a boolean column, want to ensure it can never be null. Only expect to find true or false in this column. Use `null` and `default` options to ensure this column can never be null and defaults to false:

```ruby
# subscription-app/db/migrate/20220903112034_add_is_admin_to_users.rb
class AddIsAdminToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :is_admin, :boolean, null: false, default: false
  end
end
```

Run migration: `bin/rails db:migrate`. Then launch console: `bin/rails c`, and check `is_admin` property on user we created earlier. Notice that it's been set to false:

```ruby
User.last
=> #<User id: 1, email: "test1@test.com", created_at: "2022-08-01 12:05:19.855459000 +0000", updated_at: "2022-08-01 12:05:19.855459000 +0000", is_admin: false>
```

Let's create an admin user via seeds:

```ruby
# subscription-app/db/seeds.rb
User.create(
  email: 'subscription_admin@test.com',
  password: 'password',
  is_admin: true
)
```

Run it with `bin/rails db:seed`. Now there's one regular and one admin user in the database:

```ruby
User.all.each{ |user| puts("#{user.email}, is_admin: #{user.is_admin}") }
# test1@test.com, is_admin: false
# subscription_admin@test.com, is_admin: true
```

Add admin routes. Use `namespace` feature to create similar routing paths as publications, but under `/admin...`:

```ruby
# subscription-app/config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  root to: "home#index"
  resources :publications, only: [:index, :show]
  namespace :admin do
    resources :publications
  end
end
```

Here are the admin routes this generates: `bin/rails routes | grep admin`

```
admin_publications      GET   /admin/publications(.:format)                                                                     admin/publications#index
                       POST   /admin/publications(.:format)                                                                     admin/publications#create
 new_admin_publication GET    /admin/publications/new(.:format)                                                                 admin/publications#new
edit_admin_publication GET    /admin/publications/:id/edit(.:format)                                                            admin/publications#edit
     admin_publication GET    /admin/publications/:id(.:format)                                                                 admin/publications#show
                       PATCH  /admin/publications/:id(.:format)                                                                 admin/publications#update
                       PUT    /admin/publications/:id(.:format)                                                                 admin/publications#update
                       DELETE /admin/publications/:id(.:format)                                                                 admin/publications#destroy
```

Create an admin controller with a `before_action` to ensure that the currently logged in user is an admin before letting them proceed. If they are not, or if there is no logged in user, then they'll be redirected to the home page with a flash alert.

`before_action`: Append a callback before actions. Instructor used `before_filter` but I got error about undefined method.

```ruby
# subscription-app/app/controllers/admin_controller.rb
class AdminController < ApplicationController
  before_action :check_for_admin

  def check_for_admin
    if current_user.nil? || !current_user.is_admin?
      redirect_to root_path, alert: "You must be an admin to access this path."
    end
  end
end
```

Add the admin publications controller. Note that it inherits from `AdminController` to get the `check_for_admin` filter. Also note private method `find_publication` to avoid code duplication in various methods that all need to find a publication by id.

`publication_params` is a private method using Rails Strong Params. It looks for a hash `publication` in the request params, and then ensures that it only contains the given list of attributes.

Note I had to namespace `Admin::PublicationsController` for class name, otherwise got super class mismatch error due to `PublicationsController` already existing under app/controllers and inheriting from ApplicationController.

```ruby
# subscription-app/app/controllers/admin/publications_controller.rb
class Admin::PublicationsController < AdminController
  before_action :find_publication, only: [:show, :edit, :update, :destroy]

  def index
    @publications = Publication.all
  end

  def show; end

  def new
    @publication = Publication.new
  end

  def create
    @publication = Publication.new(publication_params)

    if @publication.save
      redirect_to admin_publication_path(@publication)
    else
      render :new, alert: "Something went wrong."
    end
  end

  def edit; end

  def update
    if @publication.update(publication_params)
      redirect_to admin_publication_path(@publication)
    else
      render :edit, alert: "Something went wrong."
    end
  end

  def destroy
    @publication.destroy
    redirect_to admin_publications_path, alert: "Successfully deleted publication."
  end

  private

  def find_publication
    @publication = Publication.find(params[:id])
  end

  def publication_params
    params.require(:publication).permit(:title, :description, :file_url)
  end
end
```

Rails Guide on [render and redirect_to](https://guides.rubyonrails.org/layouts_and_rendering.html).

Run Rails server, then try to navigate to `http://localhost:3000/admin/publications`, will get redirected to root `http://localhost:3000` with message that you must be admin to access this page:

![you must be admin](doc-images/you-must-be-admin.png "you must be admin")

Login with `subscription_admin@test.com` which has `is_admin` set to true, then navigate to `http://localhost:3000/admin/publications`. This time get error: `Admin::PublicationsController#index is missing a template for request formats: text/html`.

Let's add the view. It will look similar to what regular users see, but an additional link/button to edit each publication. Also make sure the view button links to the admin version of this.

Note: To find the correct `XXX_path` helper method names, run `bin/rails routes | grep "admin"`.

```erb
<!-- subscription-app/app/views/admin/publications/index.html.erb -->
<h2>Admin Publications</h2>

<% @publications.each do |publication| %>
  <div class="panel panel-default">
    <div class="panel-heading">
      <h3 class="panel-title"><%= publication.title %></h3>
    </div>
    <div class="panel-body">
      <p><%= publication.title %></p>
      <p><%= publication.file_url %></p>
    </div>
    <div class="panel-footer">
      <%= link_to "View more details", admin_publication_path(publication), class: "btn btn-info" %>
      <%= link_to "Edit", edit_admin_publication_path(publication), class: "btn btn-default" %>
    </div>
  </div>
<% end %>
```

Here is what the `http://localhost:3000/admin/publications` view looks like now:

![admin publications view](doc-images/admin-publications-view.png "admin publications view")

Let's build the edit template so that it will work when admin user clicks the edit button from this view. The edit view uses `form_for` Rails view helper to build the form, together with Bootstrap classes `form-group`, `form-control`, etc for styling.

```erb
<!-- subscription-app/app/views/admin/publications/edit.html.erb -->
<h3>Edit <%= @publication.title %></h3>

<%= form_for @publication, url: admin_publication_path(@publication) do |f| %>
  <div class="form-group">
    <label>Title</label>
    <%= f.text_field :title, class: 'form-control' %>
  </div>
  <div class="form-group">
    <label>Description</label>
    <%= f.text_area :description, class: 'form-control' %>
  </div>
  <div class="form-group">
    <label>File URL</label>
    <%= f.text_field :file_url, class: 'form-control' %>
  </div>
  <div class="form-group">
    <%= f.submit "Update Publication", class: 'btn btn-primary' %>
  </div>
<% end %>
```

Note that the generated form will POST to `admin_publication_path(@publication)`. This will get translated by Rails to a PATCH to `/admin/publications/:id`, which will run the `update` method in `subscription-app/app/controllers/admin/publications_controller.rb`.

Left at 6:04