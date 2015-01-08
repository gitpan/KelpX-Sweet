package MyApp::Model::MyDB;

use KelpX::Sweet::Model;
use MyApp::Schema;

sub build {
    my ($self, @args) = @_;
    return MyApp::Schema->connect(@args);
}
