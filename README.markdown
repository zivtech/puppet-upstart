# puppet-upstart

## Overview

This module manages Upstart job configurations and the resulting
services. It includes support for enabling Upstart's per-user jobs.

## Dependencies

- [stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

## Usage

Include the base class first:

```puppet
include 'upstart'
```

Or pass in the `user_jobs` parameter to manage per-user jobs:

```puppet
class { 'upstart':
    user_jobs => true,
}
```

Create a basic upstart service:

```puppet
include 'upstart'

upstart::job { 'test_service':
    description    => 'This is an example upstart service',
    version        => '3626f2',
    respawn        => true,
    respawn_limit  => '5 10',
    user           => 'app-user',
    group          => 'app-user',
    chdir          => '/path/to/app',
    exec           => 'start.sh',
}
```

Create a nodejs-based upstart service with a custom script block using puppetlab's nodejs module:

```puppet
include 'upstart'
include 'nodejs'

upstart::job { 'nodejs':
    description => 'NodeJS Application Server',
    respawn     => true,
    script      => '
APP_PORT=8881 \
APP_MONGO=mongo1.domain.local \
exec start-stop-daemon --start --quiet --chuid nodejs \
    --chdir /home/nodejs/app/ \
    --pidfile /home/nodejs/app/app.pid \
    --exec node /home/nodejs/app/main.js
',
    require     => Class[ 'nodejs' ],
}
```

