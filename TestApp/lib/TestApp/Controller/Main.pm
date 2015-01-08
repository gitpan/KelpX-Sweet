package TestApp::Controller::Main;

use KelpX::Sweet::Controller;
use Data::Dumper;
sub hello { 'Hello, world!' }
sub test {
    my ($self) = @_;
    $self->x;
}
sub inc {
   return Dumper(\@INC);
}

sub users {
    my  ($self) = @_;
    my @users   = $self->model('LittleDB::User')->all;
    return join "<br>", map { $_->name . " (" . $_->email . ")" } @users;
}

sub products {
    my ($self) = @_;
    my @products = $self->model('LittleDB::Product')->all;
    return join "<br>", map { $_->name . " (" . sprintf("%.2f", $_->value) . ")" } @products;
}
