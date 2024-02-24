import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isBusy = false;
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  String? _codeVerifier;
  String? _authorizationCode;
  String? _refreshToken;
  String? _accessToken;
  String? _idToken;

  final TextEditingController _authorizationCodeTextController =
  TextEditingController();
  final TextEditingController _accessTokenTextController =
  TextEditingController();
  final TextEditingController _accessTokenExpirationTextController =
  TextEditingController();

  final TextEditingController _idTokenTextController = TextEditingController();
  final TextEditingController _refreshTokenTextController =
  TextEditingController();
  String? _userInfo;

  // For a list of client IDs, go to https://demo.identityserver.io
  // final String _clientId = 'flutter-demo-app';
  // final String _redirectUrl = 'com.example.sampleflutterauthapp:/*';
  // //final String _redirectUrl = 'com.example.sampleflutterauthapp://logincallback';
  // final String _issuer = 'https://10.0.2.2:8443/realms/flutter';
  // final String _discoveryUrl =
  //     'https://10.0.2.2:8443/realms/flutter/.well-known/openid-configuration';
  // final String _postLogoutRedirectUrl = 'com.example.sampleflutterauthapp://';
  // final List<String> _scopes = <String>[
  //   'openid',
  //   'profile',
  //   'offline_access'
  // ];


  final String _clientId = 'flutter';
   final String _redirectUrl = 'https://websso.krakatautirta.co.id/';
//  final String _redirectUrl = 'http://localhost:6328/';
  final String _issuer = 'https://auth.krakatautirta.co.id:8443/realms/kti';
  final String _discoveryUrl = 'https://auth.krakatautirta.co.id:8443/realms/kti/protocol/openid-connect/auth';
  final String _postLogoutRedirectUrl = 'http://localhost:63287/*';
  final List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
  ];


  final AuthorizationServiceConfiguration _serviceConfiguration =
  const AuthorizationServiceConfiguration(
    authorizationEndpoint: 'https://auth.krakatautirta.co.id:8443/realms/KTI/protocol/openid-connect/auth',
    tokenEndpoint: 'https://auth.krakatautirta.co.id:8443/realms/KTI/protocol/openid-connect/token',
    endSessionEndpoint: 'https://auth.krakatautirta.co.id:8443/realms/KTI/protocol/openid-connect/logout',
  );

  Future<void> _endSession() async {
    try {
      _setBusyState();
      await _appAuth.endSession(EndSessionRequest(
          idTokenHint: _idToken,
          postLogoutRedirectUrl: _postLogoutRedirectUrl,
          serviceConfiguration: _serviceConfiguration));
      _clearSessionInfo();
    } catch (_) {}
    _clearBusyState();
  }

  void _clearSessionInfo() {
    setState(() {
      _codeVerifier = null;
      _authorizationCode = null;
      _authorizationCodeTextController.clear();
      _accessToken = null;
      _accessTokenTextController.clear();
      _idToken = null;
      _idTokenTextController.clear();
      _refreshToken = null;
      _refreshTokenTextController.clear();
      _accessTokenExpirationTextController.clear();
      _userInfo = null;
    });
  }

  // Future<void> _signInWithNoCodeExchange() async {
  //   try {
  //     _setBusyState();
  //     // use the discovery endpoint to find the configuration
  //     final AuthorizationResponse? result = await _appAuth.authorize(
  //       AuthorizationRequest(_clientId, _redirectUrl,
  //           discoveryUrl: _discoveryUrl, scopes: _scopes, loginHint: 'bob'),
  //     );
  //
  //     print("Sign in with No code exchange result : $result");
  //     // or just use the issuer
  //     // var result = await _appAuth.authorize(
  //     //   AuthorizationRequest(
  //     //     _clientId,
  //     //     _redirectUrl,
  //     //     issuer: _issuer,
  //     //     scopes: _scopes,
  //     //   ),
  //     // );
  //     if (result != null) {
  //       _processAuthResponse(result);
  //     }
  //   } catch (_) {
  //     _clearBusyState();
  //   }
  // }

  Future<void> _signInWithAutoCodeExchange(
      {bool preferEphemeralSession = false}) async {
    try {
      _setBusyState();

      print("Sign in with Auto code exchange");

      // show that we can also explicitly specify the endpoints rather than getting from the details from the discovery document
      final AuthorizationTokenResponse? result =
      await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          serviceConfiguration: _serviceConfiguration,
          scopes: _scopes,
          preferEphemeralSession: preferEphemeralSession,
          allowInsecureConnections: true,
        ),
      );

      // this code block demonstrates passing in values for the prompt parameter. in this case it prompts the user login even if they have already signed in. the list of supported values depends on the identity provider
      // final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
      //   AuthorizationTokenRequest(_clientId, _redirectUrl,
      //       serviceConfiguration: _serviceConfiguration,
      //       scopes: _scopes,
      //       promptValues: ['login']),
      // );

      print("Result : $result");
      if (result != null) {
        _processAuthTokenResponse(result);
        //await _testApi(result);
      }
    } catch (e) {
      print("Error occured: $e");
      _clearBusyState();
    }
  }

  void _clearBusyState() {
    setState(() {
      _isBusy = false;
    });
  }

  void _setBusyState() {
    setState(() {
      _isBusy = true;
    });
  }

  void _processAuthTokenResponse(AuthorizationTokenResponse response) {
    setState(() {
      print(response);
      _accessToken = _accessTokenTextController.text = response.accessToken!;
      _idToken = _idTokenTextController.text = response.idToken!;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken!;
      _accessTokenExpirationTextController.text =
          response.accessTokenExpirationDateTime!.toIso8601String();
    });
  }

  void _processAuthResponse(AuthorizationResponse response) {
    setState(() {
      // save the code verifier as it must be used when exchanging the token
      _codeVerifier = response.codeVerifier;
      _authorizationCode =
          _authorizationCodeTextController.text = response.authorizationCode!;
      _isBusy = false;
    });
  }

  // Future<void> _testApi(TokenResponse? response) async {
  //   final http.Response httpResponse = await http.get(
  //       Uri.parse('https://demo.identityserver.io/api/test'),
  //       headers: <String, String>{'Authorization': 'Bearer $_accessToken'});
  //   setState(() {
  //     _userInfo = httpResponse.statusCode == 200 ? httpResponse.body : '';
  //     _isBusy = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('KTI example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Visibility(
                visible: _isBusy,
                child: const LinearProgressIndicator(),
              ),
              ElevatedButton(
                child: const Text('Login'),
                onPressed: () => _signInWithAutoCodeExchange(),
              ),
              if (Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: const Text(
                      'Sign in with auto code exchange using ephemeral session (iOS only)',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => _signInWithAutoCodeExchange(
                        preferEphemeralSession: true),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}