#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'KelpX::Sweet' ) || print "Bail out!\n";
}

diag( "Testing KelpX::Sweet $KelpX::Sweet::VERSION, Perl $], $^X" );
