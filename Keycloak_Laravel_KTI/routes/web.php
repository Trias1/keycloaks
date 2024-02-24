<?php

use Illuminate\Support\Facades\Auth;
use Stevenmaguire\OAuth2\Client\Provider\Keycloak;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});


Route::middleware('openid_login')->get('/login', function () {
    return 'welcome!';
})->name("login");


Route::get('/home', function () {
    $username = Auth::guard('keycloak')->user();
    if($username) $username = $username->getName();
    return view('home', compact('username'));
})->name("home");

Route::middleware('openid_checktoken')->group(function() {

    Route::get('/logout', function (Keycloak $kc) {
        return redirect($kc->getLogoutUrl(['redirect_uri' => config('keycloak.redirectLogoutUri')]));
   })->name("logout");
});
