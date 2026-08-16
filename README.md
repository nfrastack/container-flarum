# nfrastack/container-flarum

## About

This repository will build a container image for running [Flarum](https://flarum.org/) - an open source discussion forum built with PHP

## Maintainer

* [Nfrastack](https://www.nfrastack.com)

## Table of Contents

* [About](#about)
* [Maintainer](#maintainer)
* [Table of Contents](#table-of-contents)
* [Installation](#installation)
  * [Prebuilt Images](#prebuilt-images)
  * [Quick Start](#quick-start)
  * [Persistent Storage](#persistent-storage)
* [Upgrading from 1.x](#upgrading-from-1x)
* [Configuration](#configuration)
  * [Environment Variables](#environment-variables)
    * [Base Images used](#base-images-used)
    * [Core Configuration](#core-configuration)
    * [Database](#database)
    * [Application](#application)
    * [Scheduler](#scheduler)
  * [Networking](#networking)
* [Maintenance](#maintenance)
  * [Shell Access](#shell-access)
  * [Installing Extensions](#installing-extensions)
* [Support & Maintenance](#support--maintenance)
* [License](#license)
* [References](#references)

## Installation

### Prebuilt Images

Builds are available on the [Github Container Registry](https://github.com/nfrastack/container-flarum/pkgs/container/container-flarum) and [Docker Hub](https://hub.docker.com/r/nfrastack/flarum):

```text
ghcr.io/nfrastack/container-flarum:(image_tag)
docker.io/nfrastack/flarum:(image_tag)
```

Image tag syntax is:

`<image>:<optional tag>`

Example:

`docker.io/nfrastack/flarum:latest` or `ghcr.io/nfrastack/container-flarum:2.0.0`

* `latest` will be the most recent commit on the latest PHP version
* An optional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - these are the safest

Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

## Upgrading from 1.x

This section covers upgrading from the tiredofit/flarum:1.x image series to the nfrastack/flarum:2.x series. The 2.x image is based on a new base image (`nfrastack/laravel`) and introduces breaking changes to volume paths and environment variables.

### Back up everything

* Dump your database

   If you are running MariaDB/MySQL:

   ```bash
   docker exec flarum-db mysqldump -u flarum -pflarumpass flarum > flarum-backup-$(date +%F).sql
   ```

* Copy your data volume to a safe location before any container changes.

### Stop the running container

```bash
docker compose down
```

### Update the image reference

The image has moved. Replace the old image name with the new one in your compose file or whatever you use to orchestrate your stacks.

| Old (1.x)                           | New (2.x)                                   |
| ----------------------------------- | ------------------------------------------- |
| `docker.io/tiredofit/flarum:latest` | `docker.io/nfrastack/flarum:latest`         |
| `ghcr.io/tiredofit/docker-flarum`   | `ghcr.io/nfrastack/container-flarum:latest` |

### Update volume mounts

| Old (1.x) mount | New (2.x) mount |
| --------------- | --------------- |
| `/www/logs`     | `/logs`         |

* The `/assets/custom`, `/assets/custom-scripts`, and `/assets/install` volume mounts no longer exist. Remove them from your compose file.
* Your existing `/data` volume can remain as-is - the container will detect the existing state on first boot and preserve your `assets`, `storage`, and `extensions` directories.

### Update environment variables

| Old (1.x)                | New (2.x)                | Notes                                              |
| ------------------------ | ------------------------ | -------------------------------------------------- |
| `SITE_URL`               | `APP_URL`                | `SITE_URL` still works but is deprecated           |
| `SITE_TITLE`             | `SITE_TITLE`             | Unchanged                                          |
| `ADMIN_EMAIL`            | `ADMIN_EMAIL`            | Unchanged                                          |
| `ADMIN_USER`             | `ADMIN_USER`             | Unchanged                                          |
| `ADMIN_PASS`             | `ADMIN_PASS`             | Unchanged                                          |
| `ADMIN_PATH`             | `ADMIN_PATH`             | Unchanged                                          |
| `API_PATH`               | `API_PATH`               | Unchanged                                          |
| `DB_PREFIX`              | `DB_PREFIX`              | Unchanged                                          |
| `DB_*`                   | `DB_*`                   | Unchanged; now also accepts `mariadb` / `postgres` |
| `EXTENSIONS_AUTO_UPDATE` | `EXTENSIONS_AUTO_UPDATE` | Unchanged                                          |

#### Pull the new image and start

```bash
docker compose pull
docker compose up -d
```

* * *

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See [examples/compose.yml](examples/compose.yml) for a working stack you can tailor to your environment.
* Map [persistent storage](#persistent-storage) for access to configuration and data files for backup.
* Set [environment variables](#environment-variables) to control container behavior.

**The first boot can take 1-10 minutes depending on your CPU as Flarum is installed, the schema is created, and the admin user is bootstrapped.**

### Persistent Storage

The following directories should be mapped for persistent storage. The `/data` mount is recommended - it covers config, assets, storage, and extensions in one place.

| Directory | Description                                                                    |
| --------- | ------------------------------------------------------------------------------ |
| `/logs`   | Nginx, PHP-FPM, and Flarum scheduler log files                                 |
| `/data`   | Persistent state - `config.php`, uploads (`assets`), `storage`, extension list |

When mounting `/www/html` instead of `/data`, the container's config and storage redirections point at ephemeral paths by default. To keep everything under the webroot mount, add these environment variables:

| Variable                     | Description                                               |
| ---------------------------- | --------------------------------------------------------- |
| `ENABLE_CONFIG_REDIRECTION`  | Set to `FALSE` to keep `config.php` in `/www/html/`       |
| `ENABLE_STORAGE_REDIRECTION` | Set to `FALSE` to keep `storage/` in `/www/html/storage/` |

Without these, config and uploaded files are lost on container restart.

## Configuration

### Environment Variables

This image relies on a customized base image in order to work.
Be sure to view the following repositories to understand all the customizable options:

#### Base Images used

| Image                                                                 | Description         |
| --------------------------------------------------------------------- | ------------------- |
| [OS Base](https://github.com/nfrastack/container-base/)               | Base image          |
| [Nginx](https://github.com/nfrastack/container-nginx/)                | Nginx webserver     |
| [Nginx PHP-FPM](https://github.com/nfrastack/container-nginx-php-fpm) | PHP-FPM interpreter |
| [Laravel](https://github.com/nfrastack/container-laravel)             | Laravel runtime     |

Below is the complete list of available options that can be used to customize your installation.

* Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

#### Core Configuration

| Parameter            | Description                                                                                                    | Default                | `_FILE` |
| -------------------- | -------------------------------------------------------------------------------------------------------------- | ---------------------- | ------- |
| `SETUP_TYPE`         | `AUTO` writes config, runs migrations, creates the bootstrap admin. `MANUAL` does nothing                      | `AUTO`                 |         |
| `ENABLE_AUTO_UPDATE` | Auto-upgrade Flarum source on container restart when image version differs from `${DATA_PATH}/.flarum-version` | `TRUE`                 |         |
| `ADMIN_EMAIL`        | Email of the bootstrap admin user (created on a fresh DB only)                                                 | `admin@example.com`    | x       |
| `ADMIN_USER`         | Username of the bootstrap admin                                                                                | `admin`                | x       |
| `ADMIN_PASS`         | Password of the bootstrap admin                                                                                | `flarum`               | x       |
| `ADMIN_PATH`         | What folder to access the admin panel                                                                          | `admin`                |         |
| `API_PATH`           | What folder to access the API                                                                                  | `api`                  |         |
| `SITE_TITLE`         | The title of the Website                                                                                       | `Flarum`               |         |
| `DATA_PATH`          | Base persistent-data path (config, assets, storage, extension list live under here)                            | `/data`                |         |
| `CONFIG_PATH`        | Config file (`config.php` redirection) lives here                                                              | `${DATA_PATH}/config/` |         |
| `CONFIG_FILE`        | Actual name of config file                                                                                     | `config`               |         |
| `VERSION_FILE`       | Version marker file name                                                                                       | `.flarum-version`      |         |
| `ASSETS_PATH`        | Persistent storage for Flarum `public/assets` (avatars, logos, uploads)                                        | `${DATA_PATH}/assets`  |         |
| `DB_TYPE`            | Database driver: `mysql`, `mariadb`, `pgsql` / `postgres`, or `sqlite`                                         | `mysql`                |         |
| `DB_HOST`            | Hostname or container name of the database server                                                              |                        | x       |
| `DB_PORT`            | Database port                                                                                                  | `3306`                 | x       |
| `DB_NAME`            | Database name                                                                                                  |                        | x       |
| `DB_USER`            | Database username                                                                                              |                        | x       |
| `DB_PASS`            | Database password                                                                                              |                        | x       |
| `DB_PREFIX`          | Database table prefix                                                                                          | `flarum_`              | x       |
| `DB_SSL_MODE`        | PostgreSQL only - libpq sslmode (`disable`, `prefer`, `require`)                                               |                        |         |

#### Application

| Parameter             | Description                                                                                          | Default | `_FILE` |
| --------------------- | ---------------------------------------------------------------------------------------------------- | ------- | ------- |
| `APP_URL`             | Full external URL of the site (e.g. `https://flarum.example.com`). Required.                         |         |         |
| `SITE_URL`            | Deprecated alias for `APP_URL`                                                                       |         |         |
| `FLARUM_QUEUE_DRIVER` | Flarum queue driver - `sync` or `database`. See the [Flarum docs](https://docs.flarum.org/2.x/queue) | `sync`  |         |

#### Scheduler

Flarum requires `php flarum schedule:run` to fire once per minute for scheduled tasks (mail, and the `database` queue driver). There are two methods, `cron` or `service`.

- Under `cron` it relies on busybox cron timers to execute once per minute
- Under `service` it relies on the `flarum-scheduler` container service

| Parameter            | Description                                                | Default         |
| -------------------- | ---------------------------------------------------------- | --------------- |
| `SCHEDULER_TYPE`     | `service` (S6 loop) or `cron` (crontab). `alt` is an alias | `service`       |
| `SCHEDULER_LOG_TYPE` | Scheduler log type `file` `console` `none`                 | `file`          |
| `SCHEDULER_LOG_PATH` | Scheduler log path                                         | `${LOG_PATH}`   |
| `SCHEDULER_LOG_FILE` | Scheduler log file name                                    | `scheduler.log` |

### Networking

The following ports are exposed.

| Port | Description |
| ---- | ----------- |
| `80` | HTTP        |

* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container. A `flarum` shell function is preinstalled and runs as the nginx user against `/www/flarum/flarum`.

```bash
docker exec -it flarum-app bash
flarum info
```

### Installing Extensions

* Make a file in your `/data/extensions` folder called `list` and place on each line the Composer package name. Upon startup, the container will install any missing packages and upgrade any outdated ones (unless `EXTENSIONS_AUTO_UPDATE=FALSE`).

Example:

```text
[flarum@host ~/flarum/data] $ cat extensions/list
flarum/extension-manager
fof/drafts
```

* Alternatively, if you wish to install an extension while the container is running without restarting, you can use the tool located in `/usr/sbin/extension-tool`

Syntax is as follows:

```text
Usage:
  extension-tool {install|remove|update|enable} {packagename}
  extension-tool {install|remove|update|enable} {packagename} --debug
  extension-tool -h|--help
```

For example, if you wished to install `fof/drafts` then here is a command to do it from your host:

```bash
docker exec -it flarum-app extension-tool install fof/drafts
```

The rest of the options are self explanatory.

## Support & Maintenance

* For community help, tips, and discussions, visit the [Discussions board](/discussions).
* For personalized support or a support agreement, see [Nfrastack Support](https://nfrastack.com/).
* To report bugs, submit a [Bug Report](issues/new). Usage questions will be closed as not-a-bug.
* Feature requests are welcome but not guaranteed.
* Updates are best-effort, with priority given to active production use and support agreements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References

* <https://flarum.org/>
* <https://docs.flarum.org/>
* <https://docs.flarum.org/2.x/install>
* <https://github.com/flarum/flarum>
