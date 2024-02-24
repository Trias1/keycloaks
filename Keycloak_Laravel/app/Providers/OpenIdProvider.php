<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Stevenmaguire\OAuth2\Client\Provider\Keycloak;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cookie;
use League\OAuth2\Client\Token\AccessToken;
use League\OAuth2\Client\Provider\Exception\IdentityProviderException;
use Lcobucci\JWT\Token;
use Firebase\JWT\JWT;

class OpenIdProvider extends ServiceProvider
{
    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }

    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton(Keycloak::class, function ($app) {
            return new Keycloak([
                'authServerUrl'         => config('keycloak.authServerUrl'),
                'realm'                 => config('keycloak.realm'),
                'clientId'              => config('keycloak.clientId'),
                'clientSecret'          => config('keycloak.clientSecret'),
                'redirectUri'           => config('keycloak.redirectUri'),
                'scope'                 => config('keycloak.scope'),
            ]);
        });

        Auth::viaRequest('kc', function ($request) {
            $kc_provider = resolve('Stevenmaguire\OAuth2\Client\Provider\Keycloak');
            $obj_token = new AccessToken(['access_token'  => Cookie::get('access_token'),
                                          'refresh_token' => Cookie::get('refresh_token'),
                                          'expires'       => Cookie::get('expires')]);
            $token = null;
            try {
                $token = $kc_provider->getAccessToken('refresh_token', ['refresh_token' => $obj_token->getRefreshToken()]);
                // $token2 = $kc_provider->getAccessToken('authorization_code', ['code' => $request->code]);
                $user  = $kc_provider->getResourceOwner($obj_token);
                return $user;

            } catch(IdentityProviderException $e) {
                if($obj_token->hasExpired() && $token) {
                    Cookie::queue('access_token'  , $token->getToken(), 100, null, null, false, true);
                    Cookie::queue('refresh_token' , $token->getRefreshToken(), 100, null, null, false, true);
                    Cookie::queue('expires'       , $token->getExpires(), 100, null, null, false, true);
                    $user  = $kc_provider->getResourceOwner($token);
                    return $user;
                }
                Cookie::forget('access_token');
                Cookie::forget('refresh_token');
                Cookie::forget('expires');
                return null;

            } catch(\Exception $e) {
                Cookie::forget('access_token');
                Cookie::forget('refresh_token');
                Cookie::forget('expires');
                return null;
            }
        });

    }
}
