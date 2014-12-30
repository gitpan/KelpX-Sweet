package MyApp::Route::Main;

use KelpX::Sweet::Route;

get '/' => 'Controller::Main::hello';
