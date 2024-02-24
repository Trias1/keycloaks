# Keycloak_Flutter_KTI

A sample Flutter project for Single Sing-On feature.

## mulai

Untuk memulai proyek ini, hal-hal berikut perlu dikonfigurasi:
- git clone name github
- pub get
- jalankan vm (android/ios) 
- Keycloak Server [Keycloak](https://www.keycloak.org/)
- Self Signed Certificate untuk Keycloak Server [SSL Certificate](https://ultimatesecurity.pro/post/san-certificate/) (Jika diperlukan, http baik-baik saja)

Untuk tujuan otorisasi, [flutter_appauth](https://pub.dev/packages/flutter_appauth?msclkid=32544d2fcf7511ecabe3ad762261eb5a) telah dilaksanakan.

Di repo ini saya hanya mengonfigurasi Aplikasi Android. Anda perlu memberikan Sertifikat SSL Keycloak di folder Sumber Daya Android sesuai network_security_config.xml

