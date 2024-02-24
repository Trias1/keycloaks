# keycloak laravel
## testing apps:
- setting config/keycloak.php
- cek pada halaman routes/web.php untuk mengetahui halaman redirect
- jika ingin non aktifkan verify (false) untuk ssl bisa di buka kehalaman vendor/guzzlehttp/guzzle/src/client.php 
- jika ingin sslnya aktif, maka pilih lah pada halaman cert/domain.pem, dan pindahkan halaman path cert/domain.pem kebagian php.ini lalu pilih ;curl.cainfo=""

## untuk menjalankan apps:
- git clone nama github
- composer update
- composer install
- mv .env.example .env
- php artisan cache:clear
- composer dump-autoload
- php artisan key:generate
- php artisan serve
