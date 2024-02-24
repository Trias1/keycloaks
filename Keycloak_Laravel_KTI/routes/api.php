<?php

use Illuminate\Http\Request;
use function GuzzleHttp\json_encode;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Gate;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Route::middleware('auth:api')->get('/user', function (Request $request) {
//     return $request->user();
// });

Route::middleware('openid_checktoken')->group(function() {
    Route::get('/user', function () {
        $u =  Auth::guard('keycloak')->user()->toArray();
        return \json_encode($u);
   });

    Route::get('/user-mbarbosa', function () {
        $u =  Auth::guard('keycloak')->user()->toArray();
        if(Gate::forUser($u)->allows('only-mbarbosa')) {
            return \json_encode($u);
        } else {
            var_dump($u['preferred_username']);
            return 'Proibido! Você não é mbarbosa.';
        }
   });

    Route::get('/only-gerente', function () {
        $u =  Auth::guard('keycloak')->user()->toArray();
        var_dump($u['teste2_realm_roles']);
        if(Gate::forUser($u)->allows('only-gerente')) {
            return "Somente quem tem o perfil 'gerente' pode ver isso.";
        } else {
            return 'Proibido! Você não é gerente!';
        }
   });
});

