# github.com/tiredofit/docker-unit

[![GitHub release](https://img.shields.io/github/v/tag/tiredofit/docker-unit?style=flat-square)](https://github.com/tiredofit/docker-unit/releases)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/unit.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/unit/)
[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/unit.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/unit/)
[![Become a sponsor](https://img.shields.io/badge/sponsor-tiredofit-181717.svg?logo=github&style=flat-square)](https://github.com/sponsors/tiredofit)
[![Paypal Donate](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square)](https://www.paypal.me/tiredofit)

## About

This will build a Docker Image for [Unit](https://unit.nginx.org), A high performance application server. This is a base image that can serve static files. You will likely need to use a different downstream image if you wish to serve PHP files such as [tiredofit/unit-php](https://github.com/tiredofit/docker-unit-php)

- Supports various Node, Perl, PHP, Python, Ruby runtime engines
- Auto configuration generation and import
- Metrics collection
- Log Shipping support


## Maintainer

- [Dave Conroy](https://github.com/tiredofit/)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
  - [Build from Source](#build-from-source)
  - [Prebuilt Images](#prebuilt-images)
      - [Alpine Builds](#alpine-builds)
      - [Downstream Images](#downstream-images)
    - [Multi Architecture](#multi-architecture)
- [Configuration](#configuration)
  - [Quick Start](#quick-start)
  - [Creating configuration](#creating-configuration)
  - [Persistent Storage](#persistent-storage)
  - [Environment Variables](#environment-variables)
    - [Base Images used](#base-images-used)
    - [Core](#core)
    - [Logging](#logging)
    - [Performance](#performance)
    - [Constraints](#constraints)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
  - [Controlling Configuration](#controlling-configuration)
- [Support](#support)
  - [Usage](#usage)
  - [Bugfixes](#bugfixes)
  - [Feature Requests](#feature-requests)
  - [Updates](#updates)
- [License](#license)
- [References](#references)


## Installation
### Build from Source
Clone this repository and build the image with `docker build -t (imagename) .`

### Prebuilt Images
Builds of the image are available on [Docker Hub](https://hub.docker.com/r/tiredofit/unit).

```
docker pull tiredofit/unit:(imagetag)
```

Builds of the image are also available on the [Github Container Registry](https://github.com/tiredofit/unit/pkgs/container/unit)

```
docker pull ghcr.io/tiredofit/docker-unit:(imagetag)
```

The following image tags are available along with their tagged release based on what's written in the [Changelog](CHANGELOG.md):


##### Alpine Builds
| Alpine Base | Node Base | Perl Base | PHP base | Python Base | Ruby Base | Tag            |
| ----------- | --------- | --------- | -------- | ----------- | --------- | -------------- |
| latest      | 18        | 5.36      | 8.2, 8.1 | 3.11        | 3.2       | `:latest`      |
| latest      | 18        | 5.36      | 8.2, 8.1 | 3.11        | 3.2       | `:alpine`      |
| edge        | 18        | 5.38      | 8.2, 8.1 | 3.11        | 3.2       | `:alpine-edge` |
| 3.18        | 18        | 5.36      | 8.2, 8.1 | 3.11        | 3.2       | `:alpine-3.18` |
| 3.16        | 16        | 5.34      | 8.0      | 3.10        | 3.1       | `:alpine-3.16` |
| 3.15        | 16        | 5.34      | 7.4      | 3.9         | 3.0       | `:alpine-3.15` |
| 3.12        | 12        | 5.30      | 7.3      | 3.8         | 2.7       | `:alpine-3.12` |

The libraries to support the various bases above have been built, but will need actual runtimes in the image to operate. Use a downstream image to support it.

##### Downstream Images

 - [tiredofit/unit-php](https://github.com/tiredofit/docker-unit-php)

#### Multi Architecture
Images are built primarily for `amd64` architecture, and may also include builds for `arm/v7`, `arm64` and others. These variants are all unsupported. Consider [sponsoring](https://github.com/sponsors/tiredofit) my work so that I can work with various hardware. To see if this image supports multiple architecures, type `docker manifest (image):(tag)`

## Configuration

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this image.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.

### Creating configuration

This image expects that you place files into the `/etc/unit/sites.available` directory along with setting the variable `UNIT_SITE_ENABLED`.

- The image will look all or some of the following files:
  - `$UNIT_SITE_ENABLED-listener.json` - Configuration of the listening port, IP, and what to do upon recieving a connection
  - `$UNIT_SITE_ENABLED-uptream.json` - Configuration of the upstream to pass traffic to. This is an optional file and not used regularly
  - `$UNIT_SITE_ENABLED-route.json` - Configuration of route configuration for above listener. This dictates the files to respond to and how to route to an application
  - `$UNIT_SITE_ENABLED-application.json` - Configuration of the application, which can perform certain actions or call application engines based on the name

See the [Unit Configuration](https://unit.nginx.org/configuration/) to understand how this works.

Sample `site-listener.json` file:

```
{
  "{{UNIT_LISTEN_IP}}:{{UNIT_LISTEN_PORT}}": {
    "pass": "routes"
  }
}
```

Sample `site-route.json` file:

```
   [
      {
         "action":{
            "share": "{{UNIT_WEBROOT}}/$uri"
         }
      }
   ]
```

If you do not create any configuration, a default configuration will be created, and a sample HTML page will be generated if requested to show that the server is working.

### Persistent Storage

The following directories are used for configuration and can be mapped for persistent storage.

| Directory       | Description |
| --------------- | ----------- |
| `/var/log/unit` | Logfiles    |
| `/www/html`     | Web root    |

* * *
### Environment Variables

#### Base Images used

This image relies on an [Alpine Linux](https://hub.docker.com/r/tiredofit/alpine) base image that relies on an [init system](https://github.com/just-containers/s6-overlay) for added capabilities. Outgoing SMTP capabilities are handlded via `msmtp`. Individual container performance monitoring is performed by [zabbix-agent](https://zabbix.org). Additional tools include: `bash`,`curl`,`less`,`logrotate`,`nano`.

Be sure to view the following repositories to understand all the customizable options:

| Image                                                  | Description                            |
| ------------------------------------------------------ | -------------------------------------- |
| [OS Base](https://github.com/tiredofit/docker-alpine/) | Customized Image based on Alpine Linux |

#### Core
| Variable                                | Value                                                | Default                  |
| --------------------------------------- | ---------------------------------------------------- | ------------------------ |
| `UNIT_ENABLE_APPLICATION_CONFIGURATION` | This allows for auto configuration                   | `TRUE`                   |
| `UNIT_ENABLE_CREATE_SAMPLE_HTML`        | Create sample index.html file if not existing        | `TRUE`                   |
| `UNIT_CONTROL_TYPE`                     | Socket type `ip` or `socket`                         | `SOCKET`                 |
| `UNIT_CONTROL_SOCKET_NAME`              | Socket Name                                          | `control.unit.sock`      |
| `UNIT_CONTROL_SOCKET_PATH`              | Socket Path                                          | `/run/unit/`             |
| `UNIT_CONTROL_IP`                       | Control IP - Warning, do not expose to the internet! | `127.0.0.1`              |
| `UNIT_CONTROL_PORT`                     | Control Port                                         | `8080`                   |
| `UNIT_LISTEN_IP`                        | Website Listen IP                                    | `0.0.0.0`                |
| `UNIT_LISTEN_PORT`                      | Website listen port                                  | `80`                     |
| `UNIT_MODULE_PATH`                      | Customizable Module Path                             | `/usr/lib/unit/modules/` |
| `UNIT_STATE_PATH`                       | Configuration State                                  | `/var/lib/unit/`         |
| `UNIT_TMP_PATH`                         | Temporary Files Path                                 | `/tmp`                   |
| `UNIT_WEBROOT`                          | Where website is served from                         | `/www/html/`             |

#### Logging
| Variable                 | Value                                   | Default            |
| ------------------------ | --------------------------------------- | ------------------ |
| `UNIT_LOG_TYPE`          | Unit log type `file` `console`          | `FILE`             |
| `UNIT_LOG_PATH`          | Where log files are stored              | `/var/log/unit/`   |
| `UNIT_LOG_FILE`          | Main application log file               | `unit.log`         |
| `UNIT_LOG_ROUTES`        | Log route information                   | `FALSE`            |
| `UNIT_LOG_ACCESS_TYPE`   | Access log type `file` `console` `none` | `FILE`             |
| `UNIT_LOG_ACCESS_FORMAT` | Access log format `standard` or `json`  | `STANDARD`         |
| `UNIT_LOG_ACCESS_PATH`   | Access log path                         | `${UNIT_LOG_PATH}` |
| `UNIT_LOG_ACCESS_FILE`   | Access log filename                     | `access.log`       |

#### Performance
| Variable                           | Value                                                                     | Default  |
| ---------------------------------- | ------------------------------------------------------------------------- | -------- |
| `UNIT_APPLICATION_LIMIT_RECYCLE`   | Restart application process after (x) many requests                       | ``       |
| `UNIT_APPLICATION_LIMIT_TIMEOUT`   | Timeout in seconds if process hangs before delivering 503 error to client | ``       |
| `UNIT_APPLICATION_PROCESS_TYPE`    | Static or Dyanmic                                                         | `STATIC` |
| `UNIT_APPLICATION_PROCESS_MAX`     | (dynamic) Max application processes to spawn                              | `1`      |
| `UNIT_APPLICATION_PROCESS_SPARE`   | (dynamic) Max spare processes to spawn                                    | `1`      |
| `UNIT_APPLICATION_PROCESS_TIMEOUT` | (dynamic) Timeout in seconds to phase out process                         | `20`     |

#### Constraints
| Variable                             | Value                                                                                      | Default                                   |
| ------------------------------------ | ------------------------------------------------------------------------------------------ | ----------------------------------------- |
| `UNIT_DISCARD_UNSAFE_FIELDS`         | Disable serving unsafe fields                                                              | `TRUE`                                    |
| `UNIT_ENABLE_SERVER_VERSION`         | Reveal Unit version in headers                                                             | `TRUE`                                    |
| `UNIT_ENABLE_XFORWARDED_PROTOCOL`    | Allow to pass X-Forwarded Protocol header downstream - Useful when using SSL reverse proxy | `TRUE`                                    |
| `UNIT_ENABLE_XFORWARDED_PROTOCOL_IP` | Comma seperated list of ip, networks to forward header                                     | `10.0.0.0/8,172.16.0.0/12,192.168.0.0/16` |
| `UNIT_MAX_BODY_SIZE`                 | Max body size in bytes                                                                     | `2147483648`                              |
| `UNIT_TIMEOUT_BODY_READ`             | Body read timeout in seconds                                                               | `180`                                     |
| `UNIT_TIMEOUT_BODY_SEND`             | Body send timeout in seconds                                                               | `180`                                     |
| `UNIT_TIMEOUT_HEADER_READ`           | Header read timeout in seconds                                                             | `180`                                     |
| `UNIT_TIMEOUT_IDLE`                  | Idle time in seconds                                                                       | `30`                                      |


### Networking

| Port | Protocol | Description    |
| ---- | -------- | -------------- |
| `80` | `http`   | Unit Webserver |


## Maintenance
### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

```bash
docker exec -it (whatever your container name is) bash
```


### Controlling Configuration

Once inside the container - there is a utility `unit-control` that will allow you to perform various configuration functions such as:

  - `show` Configuration
  - `import` a file to configureation - This will clear all configuration unless you use additional arguments (undocumented)
  - `edit` in place running configuration with editor such as `nano` (set via `$EDITOR`)
  - `test` if the control socket is able to be accessed
  - `clear` all the running configuration
  - `stats` show statistics of the running instance and applications

## Support

These images were built to serve a specific need in a production environment and gradually have had more functionality added based on requests from the community.
### Usage
- The [Discussions board](../../discussions) is a great place for working with the community on tips and tricks of using this image.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) for personalized support.
### Bugfixes
- Please, submit a [Bug Report](issues/new) if something isn't working as expected. I'll do my best to issue a fix in short order.

### Feature Requests
- Feel free to submit a feature request, however there is no guarantee that it will be added, or at what timeline.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) regarding development of features.

### Updates
- Best effort to track upstream changes, More priority if I am actively using the image in a production environment.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) for up to date releases.

## License
MIT. See [LICENSE](LICENSE) for more details.

## References

* <https://unit.nginx.org>
