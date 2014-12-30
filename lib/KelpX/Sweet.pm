package KelpX::Sweet;

use warnings;
use strict;
use true;
use Text::ASCIITable;
use FindBin;
use base 'Kelp';

our $VERSION = '0.001';

sub import {
    my ($class, %args) = @_;
    strict->import();
    warnings->import();
    true->import();
    my $caller = caller;
    my $routes = [];
    my $configs = {};
    {
        no strict 'refs';
        push @{"${caller}::ISA"}, 'Kelp';
        *{"${caller}::new"} = sub { return shift->SUPER::new(@_); };
        *{"${caller}::maps"} = sub {
            my ($route_names) = @_;
            unless (ref $route_names eq 'ARRAY') {
                die "routes() expects an array references";
            }

            my $route_tb = Text::ASCIITable->new;
            $route_tb->setCols('Routes');
            for my $mod (@$route_names) {
                my $route_path = "${caller}::Route::${mod}";
                eval "use $route_path;";
                if ($@) {
                    warn "Could not load route ${route_path}: $@";
                    next;
                }

                $route_tb->addRow($route_path);
                push @$routes, $route_path->get_routes();
            }

            print $route_tb . "\n";
        };

        *{"${caller}::model"} = sub {
            my ($self, $model) = @_;
            return $self->{_models}->{$model};
        };

        *{"${caller}::path_to"} = sub { return $FindBin::Bin; };

        *{"${caller}::cfg"} = sub {
            my ($key, $hash) = @_;
            $configs->{$key} = $hash;
        };

        *{"${caller}::build"} = sub {
            my ($self) = @_;
            my $config = $self->config_hash;
            # config
            if (scalar keys %$configs > 0) {
                for my $key (keys %$configs) {
                    $config->{"+${key}"} = $configs->{$key};
                }
            }
                    
            # models
            if ($config->{models}) {
                $self->{_models} = {};
                my $model_tb = Text::ASCIITable->new;
                $model_tb->setCols('Model', 'Alias');
                unless (ref $config->{models} eq 'HASH') {
                    die "config: models expects a hash reference\n";
                }

                for my $model (keys %{$config->{models}}) {
                    my $name = $model;
                    my $opts = $config->{models}->{$model}; 
                    my $mod  = $opts->{model};
                    eval "use $mod;";
                    if ($@) {
                        die "Could not load model $mod: $@";
                    }

                    my @args = @{$opts->{args}};
                    if (my $ret = $mod->build(@args)) {
                        if (ref $ret) {
                            $model_tb->addRow($mod, $name);
                            $self->{_models}->{$name} = $ret;
                        
                            # is this dbix::class?
                            require mro;
                            my $dbref = ref $ret;
                            if (grep { $_ eq 'DBIx::Class::Schema' } @{mro::get_linear_isa($dbref)}) {
                                if ($dbref->can('sources')) {
                                    my @sources = $dbref->sources;
                                    for my $source (@sources) {
                                        $self->{_models}->{"${name}::${source}"} = $ret->resultset($source);
                                        $model_tb->addRow("${dbref}::ResultSet::${source}", "${name}::${source}");
                                    }
                                }
                            }
                        }
                        else {
                            die "Did not return a valid object from models build(): $name\n";
                        }
                    }
                    else {
                        die "build() failed: $mod";
                    }
                }

                if (scalar keys %{$self->{_models}} > 0) {
                    print $model_tb . "\n";
                }
            }
            # routes
            my $r = $self->routes;
            for my $route (@$routes) {
                for my $url (keys %$route) {
                    if ($route->{$url}->{bridge}) {
                        $r->add([ uc($route->{$url}->{type}) => $url ], { to => $route->{$url}->{coderef}, bridge => 1 });
                    }
                    elsif ($route->{$url}->{type} eq 'any') {
                        $r->add($url, $route->{$url}->{coderef});
                    }
                    else {
                        $r->add([ uc($route->{$url}->{type}) => $url ], $route->{$url}->{coderef});
                    }
                }
            }
        };

        *{"${caller}::detach"} = sub {
            my ($self) = @_;

            my @caller = caller(1);
            my $fullpath = $caller[3];
            my $name;
            if ($fullpath =~ /.+::(.+)$/) {
                $name = $1;
            }

            if ($name) {
                print "[debug] Rendering template: $name\n";
                $self->template($name, $self->stash);
            }    
        };
    }
}

sub new {
    bless { @_[ 1 .. $#_ ] }, $_[0];
}

=head1 NAME

KelpX::Sweet - Kelp with extra sweeteners

=head1 DESCRIPTION

Kelp is good. Kelp is great. But what if you could give it more syntactic sugar and separate your routes from the logic in a cleaner way? KelpX::Sweet attempts to do just that.

=head1 SIMPLE TUTORIAL

For the most part, your original C<app.psgi> will remain the same as Kelps.

B<MyApp.pm>
  
  package MyApp;
  use KelpX::Sweet;

  maps ['Main'];

Yep, that's the complete code for your base. You pass C<maps> an array reference of the routes you want to include. 
It will look for them in C<MyApp::Route::>. So the above example will load C<MyApp::Route::Main>.
Next, let's create that file

B<MyApp/Route/Main.pm>

  package MyApp::Route::Main;

  use KelpX::Sweet::Route;

  get '/' => 'Controller::Root::hello';
  get '/nocontroller' => sub { 'Hello, world from no controller!' };

Simply use C<KelpX::Sweet::Route>, then create your route definitions here. You're welcome to put your logic inside code refs, 
but that makes the whole idea of this module pointless ;) 
It will load C<MyApp::> then whatever you pass to it. So the '/' above will call C<MyApp::Controller::Root::hello>. Don't worry, 
any of your arguments will also be sent the method inside that controller, so you don't need to do anything else!

Finally, we can create the controller

B<MyApp/Controller/Root.pm>

  package MyApp::Controller::Root;

  use KelpX::Sweet::Controller;

  sub hello {
      my ($self) = @_;
      return "Hello, world!";
  }

You now have a fully functional Kelp app! Remember, because this module is just a wrapper, you can do pretty much anything L<Kelp> 
can, like C<$self->>param> for example.

=head1 SUGARY SYNTAX

By sugar, we mean human readable and easy to use. You no longer need a build method, then to call ->add on an object for your 
routes. It uses a similar syntax to L<Kelp::Less>. You'll also find one called C<bridge>.

=head2 get

This will trigger a standard GET request.

  get '/mypage' => sub { 'It works' };

=head2 post

Will trigger on POST requests only

  post '/someform' => sub { 'Posted like a boss' };

=head2 any

Will trigger on POST B<or> GET requests

  any '/omni' => sub { 'Hit me up on any request' };

=head2 bridge

Bridges are cool, so please check out the Kelp documentation for more information on what they do and how they work.

  bridge '/users/:id' => sub {
      unless ($self->user->logged_in) {
          return;
      }

      return 1;
  };

  get '/users/:id/view' => 'Controller::Users::view';

=head1 MODELS

You can always use an attribute to create a database connection, or separate them using models in a slightly cleaner way.
In your config you supply a hash reference with the models alias (what you will reference it as in code), the full path, and finally any 
arguments it might have (like the dbi line, username and password).

  # config.pl
  models => {
      'LittleDB' => {
          'model' => 'TestApp::Model::LittleDB',
          'args'  => ['dbi:SQLite:testapp.db'],
      },
  },

Then, you create C<TestApp::Model::LittleDB>

  package TestApp::Model::LittleDB;

  use KelpX::Sweet::Model;
  use DBIx::Lite;

  sub build {
      my ($self, @args) = @_;
      return DBIx::Lite->connect(@args);
  }

As you can see, the C<build> function returns the DB object you want. You can obviously use DBIx::Class or whatever you want here.

That's all you need. Now you can pull that model instance out at any time in your controllers with C<model>.

  package TestApp::Controller::User;

  use KelpX::Sweet::Controller;

  sub users {
      my ($self) = @_;
      my @users  = $self->model('LittleDB')->table('users')->all;
      return join ', ', map { $_->name } @users;
  }

=head2 Models and DBIx::Class

If you enjoy the way Catalyst handles DBIx::Class models, you're going to love this (I hope so, at least). KelpX::Sweet will automagically 
create models based on the sources of your schema if it detects it's a DBIx::Class::Schema.
Nothing really has to change, KelpX::Sweet will figure it out on its own.

  package TestApp::Model::LittleDB;

  use KelpX::Sweet::Model;
  use LittleDB::Schema;

  sub build {
      my ($self, @args) = @_;
      return LittleDB::Schema->connect(@args);
  }

Then just use it as you normally would in Catalyst (except we store it in C<$self>, not C<$c>).

  package TestApp::Controller::User;
  
  use KelpX::Sweet::Controller;
  
  sub users {
      my ($self) = @_;
      my @users = $self->model('LittleDB::User')->all;
      return join ', ', map { $_->name } @users;
  }

KelpX::Sweet will loop through all your schemas sources and create models based on your alias, and the sources name. So, C<Alias::SourceName>.

When we start our app, even though we've only added LittleDB, you'll see we have the new ones based on our Schema. Neat!

  .----------------------------------------------------------.
  | Model                                | Alias             |
  +--------------------------------------+-------------------+
  | TestApp::Model::LittleDB             | LittleDB          |
  | LittleDB::Schema::ResultSet::User    | LittleDB::User    |
  | LittleDB::Schema::ResultSet::Product | LittleDB::Product |
  '--------------------------------------+-------------------'

=head1 VIEWS

OK, so to try and not separate too much, I've chosen not to include views. Just use the standard Kelp modules 
(ie: L<Kelp::Module::Template::Toolkit>). However, there is a convenience method mentioned below.

=head2 detach

This method will call C<template> for you with the added benefit of automatically filling out the filename and including whatever 
is in the stash for you.

  package MyApp::Controller::Awesome;
 
  use KelpX::Sweet::Controller;

  sub hello {
      my ($self) = @_;
      $self->stash->{name} = 'World';
      $self->detach;
  }

Then, you just create C<hello.tt>.

  <h2>Hello, [% name %]</h2>

While not really required, it does save a bit of typing and can come in quite useful.

=head1 REALLY COOL THINGS TO NOTE

=head2 Default imports

You should be aware that KelpX::Sweet will import warnings, strict and true for you. Because of this, there is no requirement to 
add a true value to the end of your file. I chose this because it just makes things look a little cleaner.

=head2 KelpX::Sweet starter

On installation of KelpX::Sweet, you'll receive a file called C<kelpx-sweet>. Simply run this, passing it the name of your module 
and it will create a working test app with minimal boilerplate so you can get started straight away. Just run it as:

  $ kelpx-sweet MyApp
  $ kelpx-sweet Something::With::A::Larger::Namespace

=head1 AUTHOR

Brad Haywood <brad@perlpowered.com>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
__END__
