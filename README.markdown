# puppet-upstart
[![Build Status](https://travis-ci.org/Slashbunny/puppet-upstart.png?branch=master)](https://travis-ci.org/Slashbunny/puppet-upstart)
## Overview

This module manages Upstart job configurations and the resulting
services. It includes support for enabling Upstart's per-user jobs.

## Basic Usage

```puppet
class { 'upstart':
    user_jobs => true,
}
```

Or simply:

```puppet
include upstart
```

## Creating a job and enabling the service

```puppet
    upstart::job { 'test_service':
        description    => "This is an example upstart service",
        version        => "3626f2",
        respawn        => true,
        respawn_limit  => '5 10',
        user           => 'app-user',
        group          => 'app-user',
        chdir          => '/path/to/app',
        exec           => "start.sh",
    }
```

## Dependencies

- [stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

