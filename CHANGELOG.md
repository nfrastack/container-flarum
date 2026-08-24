## 2.0.0pre 2026-08-23 <code at nfrastack dot com>

   ### Added
      - Flarum 2.0.0-rc.7
      - Change Base Image to nfrastack/laravel
      - Optional Realtime websocket service for the flarum/realtime extension (`ENABLE_REALTIME`, `REALTIME_PORT`, `REALTIME_LOG_*`)
      - Optional queue worker started automatically when `FLARUM_QUEUE_DRIVER` is not `sync` (`FLARUM_QUEUE_TIMEOUT`)


# 1.7.0 2024-12-20 <dave at tiredofit dot ca>

   ### Added
      - Flarum 1.8.1 (1.8.9)
      - PHP 8.3
      - Alpine 3.21


## 1.6.3 2022-06-23 <dave at tiredofit dot ca>

   ### Added
      - Support tiredofit/nginx:6.0.0 and tiredofit/nginx-php-fpm:7.0.0 changes


## 1.6.2 2021-06-08 <dave at tiredofit dot ca>

   ### Added
      - Flarum 1.0.2


## 1.6.1 2021-06-02 <dave at tiredofit dot ca>

   ### Added
      - Flarum 1.0.1


## 1.6.0 2021-05-27 <dave at tiredofit dot ca>

   ### Added
      - Flarum 1.0.0


## 1.5.2 2021-03-15 <dave at tiredofit dot ca>

   ### Added
      - Flarum 0.1.0-beta.16
      - PHP 8.0


## 1.5.1 2021-02-11 <dave at tiredofit dot ca>

   ### Added
      - Flarum 0.10-beta.15
      - PHP 7.4


## 1.5.0 2020-06-08 <dave at tiredofit dot ca>

   ### Added
      - Changes to support tiredofit/alpine:5.0.0 base


## 1.4.2 2020-04-08 <dave at tiredofit dot ca>

   ### Added
      - Add PHP FileInfo extension for extension install issues


## 1.4.1 2020-04-08 <dave at tiredofit dot ca>

   ### Added
      - Update to Flarum 0.10-beta12
      - Cleanup Image to support changes in tiredofit/nginx-php-fpm base image


## 1.4.0 2020-01-05 <dave at tiredofit dot ca>

   ### Added
      - Update to flarum 0.1.0-beta 11

## 1.3.1 2020-01-02 <dave at tiredofit dot ca>

   ### Changed
      - Additional Changes to support new tiredofit/alpine base image


## 1.3.0 2019-12-30 <dave at tiredofit dot ca>

   ### Added
      - Support new tiredofit/alpine base image


## 1.2.1 2019-12-18 <dave at tiredofit dot ca>

   ### Changed
      - Add environment variables to support dynamic webroot,user,group


## 1.2.0 2019-12-04 <dave at tiredofit dot ca>

   ### Added
      - Refactor Image to support new tiredofit/nginx-php-fpm image


## 1.1.1 2019-09-21 <dave at tiredofit dot ca>

* Add showing available updates to extension tool

## 1.1 2019-09-21 <dave at tiredofit dot ca>

* Added `extension-tool` to install/remove/update extensions while container is running
* Add environment variable to choose whether to update installed extensions on startup of container or not

## 1.0.2 2019-09-19 <dave at tiredofit dot ca>

* Hardcode a few paths for reliability

## 1.0.1 2019-09-19 <dave at tiredofit dot ca>

* Minor Tweak to Extensions Installing

## 1.0 2019-09-19 <dave at tiredofit dot ca>

* Flarum 0.10 beta 10
* Automatic Upgrade Support
* Auto Download / Upgrade Extensions

## 0.1 2019-09-19 <dave at tiredofit dot ca>

* Initial Release
* PHP 7.3
* Nginx 1.16.2
* Alpine 3.10

