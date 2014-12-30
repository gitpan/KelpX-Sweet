# NAME

KelpX::Sweet - Kelp with extra sweeteners

# DESCRIPTION

Kelp is good. Kelp is great. But what if you could give it more syntactic sugar and separate your routes from the logic in a cleaner way? KelpX::Sweet attempts to do just that.

# SIMPLE TUTORIAL

For the most part, your original `app.psgi` will remain the same as Kelps.

**MyApp.pm**

```perl
package MyApp;
use KelpX::Sweet;

maps ['Main'];
```

Yep, that's the complete code for your base. You pass `maps` an array reference of the routes you want to include. 
It will look for them in `MyApp::Route::`. So the above example will load `MyApp::Route::Main`.
Next, let's create that file

**MyApp/Route/Main.pm**

```perl
package MyApp::Route::Main;

use KelpX::Sweet::Route;

get '/' => 'Controller::Root::hello';
get '/nocontroller' => sub { 'Hello, world from no controller!' };
```

Simply use `KelpX::Sweet::Route`, then create your route definitions here. You're welcome to put your logic inside code refs, 
but that makes the whole idea of this module pointless ;) 
It will load `MyApp::` then whatever you pass to it. So the '/' above will call `MyApp::Controller::Root::hello`. Don't worry, 
any of your arguments will also be sent the method inside that controller, so you don't need to do anything else!

Finally, we can create the controller

**MyApp/Controller/Root.pm**

```perl
package MyApp::Controller::Root;

use KelpX::Sweet::Controller;

sub hello {
    my ($self) = @_;
    return "Hello, world!";
}
```

You now have a fully functional Kelp app! Remember, because this module is just a wrapper, you can do pretty much anything [Kelp](https://metacpan.org/pod/Kelp) 
can, like `$self-`>param> for example.

# SUGARY SYNTAX

By sugar, we mean human readable and easy to use. You no longer need a build method, then to call ->add on an object for your 
routes. It uses a similar syntax to [Kelp::Less](https://metacpan.org/pod/Kelp::Less). You'll also find one called `bridge`.

## get

This will trigger a standard GET request.

```perl
get '/mypage' => sub { 'It works' };
```

## post

Will trigger on POST requests only

```perl
post '/someform' => sub { 'Posted like a boss' };
```

## any

Will trigger on POST **or** GET requests

```perl
any '/omni' => sub { 'Hit me up on any request' };
```

## bridge

Bridges are cool, so please check out the Kelp documentation for more information on what they do and how they work.

```perl
bridge '/users/:id' => sub {
    unless ($self->user->logged_in) {
        return;
    }

    return 1;
};

get '/users/:id/view' => 'Controller::Users::view';
```

# MODELS

You can always use an attribute to create a database connection, or separate them using models in a slightly cleaner way.
In your config you supply a hash reference with the models alias (what you will reference it as in code), the full path, and finally any 
arguments it might have (like the dbi line, username and password).

```perl
# config.pl
models => {
    'LittleDB' => {
        'model' => 'TestApp::Model::LittleDB',
        'args'  => ['dbi:SQLite:testapp.db'],
    },
},
```

Then, you create `TestApp::Model::LittleDB`

```perl
package TestApp::Model::LittleDB;

use KelpX::Sweet::Model;
use DBIx::Lite;

sub build {
    my ($self, @args) = @_;
    return DBIx::Lite->connect(@args);
}
```

As you can see, the `build` function returns the DB object you want. You can obviously use DBIx::Class or whatever you want here.

That's all you need. Now you can pull that model instance out at any time in your controllers with `model`.

```perl
package TestApp::Controller::User;

use KelpX::Sweet::Controller;

sub users {
    my ($self) = @_;
    my @users  = $self->model('LittleDB')->table('users')->all;
    return join ', ', map { $_->name } @users;
}
```

## Models and DBIx::Class

If you enjoy the way Catalyst handles DBIx::Class models, you're going to love this (I hope so, at least). KelpX::Sweet will automagically 
create models based on the sources of your schema if it detects it's a DBIx::Class::Schema.
Nothing really has to change, KelpX::Sweet will figure it out on its own.

```perl
package TestApp::Model::LittleDB;

use KelpX::Sweet::Model;
use LittleDB::Schema;

sub build {
    my ($self, @args) = @_;
    return LittleDB::Schema->connect(@args);
}
```

Then just use it as you normally would in Catalyst (except we store it in `$self`, not `$c`).

```perl
package TestApp::Controller::User;

use KelpX::Sweet::Controller;

sub users {
    my ($self) = @_;
    my @users = $self->model('LittleDB::User')->all;
    return join ', ', map { $_->name } @users;
}
```

KelpX::Sweet will loop through all your schemas sources and create models based on your alias, and the sources name. So, `Alias::SourceName`.

When we start our app, even though we've only added LittleDB, you'll see we have the new ones based on our Schema. Neat!

```
.----------------------------------------------------------.
| Model                                | Alias             |
+--------------------------------------+-------------------+
| TestApp::Model::LittleDB             | LittleDB          |
| LittleDB::Schema::ResultSet::User    | LittleDB::User    |
| LittleDB::Schema::ResultSet::Product | LittleDB::Product |
'--------------------------------------+-------------------'
```

# VIEWS

OK, so to try and not separate too much, I've chosen not to include views. Just use the standard Kelp modules 
(ie: [Kelp::Module::Template::Toolkit](https://metacpan.org/pod/Kelp::Module::Template::Toolkit)). However, there is a convenience method mentioned below.

## detach

This method will call `template` for you with the added benefit of automatically filling out the filename and including whatever 
is in the stash for you.

```perl
 package MyApp::Controller::Awesome;

 use KelpX::Sweet::Controller;

 sub hello {
     my ($self) = @_;
     $self->stash->{name} = 'World';
     $self->detach;
 }
```

Then, you just create `hello.tt`.

```
<h2>Hello, [% name %]</h2>
```

While not really required, it does save a bit of typing and can come in quite useful.

# REALLY COOL THINGS TO NOTE

## Default imports

You should be aware that KelpX::Sweet will import warnings, strict and true for you. Because of this, there is no requirement to 
add a true value to the end of your file. I chose this because it just makes things look a little cleaner.

## KelpX::Sweet starter

On installation of KelpX::Sweet, you'll receive a file called `kelpx-sweet`. Simply run this, passing it the name of your module 
and it will create a working test app with minimal boilerplate so you can get started straight away. Just run it as:

```
$ kelpx-sweet MyApp
$ kelpx-sweet Something::With::A::Larger::Namespace
```

# AUTHOR

Brad Haywood <brad@perlpowered.com>

# LICENSE

You may distribute this code under the same terms as Perl itself.
