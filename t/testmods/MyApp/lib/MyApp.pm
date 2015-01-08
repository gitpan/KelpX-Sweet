package MyApp;

use KelpX::Sweet;
has 'attr' => ( is => 'ro', required => 1, default => sub { 'Attribute works' } );

maps ['Main'];

around 'build' => sub {
    my $method = shift;
    my $self   = shift;
    $self->routes->add('/aroundtest' => sub { 'Works' });
    
    $self->$method(@_);
};
