use lib 't/testmods/MyApp/lib';
use MyApp;
use Kelp::Test;
use Test::More;
use HTTP::Request::Common;

my $app = MyApp->new;
my $t = Kelp::Test->new( app => $app );

my $str = $^O eq 'MSWin32' ? "How are you, World?\r\n" : "How are you, World?\n";

$t->request( GET '/greet' )
    ->code_is(200)
    ->content_is($str);

done_testing();
