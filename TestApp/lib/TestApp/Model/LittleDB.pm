package TestApp::Model::LittleDB;

use KelpX::Sweet::Model;
use DBIx::Lite;

sub build {
    my ($self, @args) = @_;
    
    my $schema = DBIx::Lite->connect(@args);
    return {
        'User'       => $schema->table('users'),
        'Product'    => $schema->table('products'),
    };
}
