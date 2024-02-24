<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Cookie;
use Stevenmaguire\OAuth2\Client\Provider\Keycloak;
use Illuminate\Support\Facades\Auth;

class OpenIdLogin
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        $kc_provider = resolve('Stevenmaguire\OAuth2\Client\Provider\Keycloak');

        if (Cookie::get('access_token') && Auth::guard('keycloak')->check()) {
            return redirect('/home');

        } elseif ($request->isMethod('GET') && !isset($request->code)) {
            // If we don't have an authorization code then get one
            $authUrl = $kc_provider->getAuthorizationUrl();
            session(['oauth2state' => $kc_provider->getState()]);
            return redirect($authUrl);

        // Check given state against previously stored one to mitigate CSRF attack
        } elseif (empty($request->state) || ($request->state !== session('oauth2state'))) {
            $request->session()->forget('oauth2state');
            exit('Invalid state, make sure HTTP sessions are enabled.');

        } else {
            // Try to get an access token (using the authorization code grant)
            try {
                $token = $kc_provider->getAccessToken('authorization_code', ['code' => $request->code]);

                Cookie::queue('access_token' , $token->getToken(), 100, null, null, false, true);
                Cookie::queue('refresh_token', $token->getRefreshToken(), 100, null, null, false, true);
                Cookie::queue('expires'      , $token->getExpires(), 100, null, null, false, true);
                return redirect('/home');

            } catch (\Exception $e) {
                exit('Failed to get access token: '.$e->getMessage());
            }
        }
        return $next($request);
    }
}
