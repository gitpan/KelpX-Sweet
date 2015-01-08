package TestApp::Route::User;

use KelpX::Sweet::Route;

bridge '/users/:page' => sub {
    my ($self) = @_;
    $self->stash->{title} = 'Users';
    return 1;
};

get '/users/list' => sub {
    my ($self) = @_;
    
    my @users = $self->model('LittleDB::User')->all;
    return "<h2>" . $self->stash('title') . "</h2>" . join '<br>', map { $_->name } @users;
};

