<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Laravel</title>
        <!-- Fonts -->
        <link href="https://fonts.googleapis.com/css?family=Nunito:200,600" rel="stylesheet" type="text/css">

        <script src="http://keycloak.qa.pbh/auth/js/keycloak.js"></script>
    </head>
    <body>
        <div class="flex-center position-ref full-height">
           <h1 class="flex-center position-ref full-height">welcome! {{ $username }}</h1>
            <ul>
                <li><a href={{ url('home') }}>home</a></li>
                <li><a href={{ url('login') }}>login</a></li>
                <li><a href={{ url('api/user') }}>user</a></li>
                <!-- <li><a href={{ url('api/user-mbarbosa') }}>user (only-mbarbosa)</a></li>
                <li><a href={{ url('api/only-gerente') }}>only-gerente</a></li> -->
            </ul>
        </div>
    </body>
</html>
