package Kelp::Module::SessionFlash;

use base 'Kelp::Module';

sub build {
    my ($self, %args) = @_;
    $self->register(
       flash => sub {
           my ($self, $key, $val) = @_;
           if ($val) {
               $self->req->session->{"_flash_${key}"} = $val;
           }
           else {
               if (my $v = $self->req->session->{"_flash_${key}"}) {
                   delete $self->req->session->{"_flash_${key}"};
                   return $v;
               }
           }
       },
    );
}

1;
__END__
