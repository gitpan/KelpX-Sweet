package KelpX::Sweet::Model;

use warnings;
use strict;
use true;

sub import {
    my ($class) = @_;
    warnings->import();
    strict->import();
    true->import();
}

1;
__END__
