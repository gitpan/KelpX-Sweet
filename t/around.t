use lib 't/testmods/MyApp/lib';
use MyApp;
use Kelp::Test;
use Test::More;
use HTTP::Request::Common;

my $app = MyApp->new;
my $t = Kelp::Test->new( app => $app );

$t->request( GET '/aroundtest' )
    ->code_is(200)
    ->content_is("Works");

done_testing();
