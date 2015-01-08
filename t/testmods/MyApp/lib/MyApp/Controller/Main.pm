package MyApp::Controller::Main;

use KelpX::Sweet::Controller;

sub hello { 'Hello, World!' }
sub greet {
    my ($self) = @_;
    $self->stash->{name} = 'World';
    $self->detach;
}
