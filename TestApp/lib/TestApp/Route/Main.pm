package TestApp::Route::Main;

use KelpX::Sweet::Route;

get '/' => 'Controller::Main::hello';
get '/test' => 'Controller::Main::test';
get '/inc'  => 'Controller::Main::inc';
get '/users' => 'Controller::Main::users';
get '/products' => 'Controller::Main::products';
get '/test/four' => sub {
    my ($self) = @_;
    $self->res->set_code(400)->template('error/400.tt', { message => "Well, shit" });
};
