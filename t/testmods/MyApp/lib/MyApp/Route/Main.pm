package MyApp::Route::Main;

use KelpX::Sweet::Route;

get '/' => 'Controller::Main::hello';
get '/greet' => 'Controller::Main::greet';
bridge '/users/:page' => 'Controller::User::auto';
get '/users/:id/view' => 'Controller::User::view';
get '/users/list'     => 'Controller::User::list';
get '/testattribute'  => sub { shift->attr };
