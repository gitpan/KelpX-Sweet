use lib 't/testmods/MyApp/lib';
use MyApp;
use Kelp::Test;
use Test::More;
use HTTP::Request::Common;

my $app = MyApp->new;
my $t = Kelp::Test->new( app => $app );

$t->request( GET '/users/5/view' )
    ->code_is(200)
    ->content_is("View user 5");

done_testing();
