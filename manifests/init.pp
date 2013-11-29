# = Class: upstart
#
class upstart (
  $package         = $::upstart::params::package,
  $package_version = 'installed',
  $user_jobs       = false,
  $init_dir        = $::upstart::params::init_dir,
  $dbus_config     = $::upstart::params::dbus_config
) inherits upstart::params {

  validate_bool($user_jobs)

  $upstart_dbus_config_source = $user_jobs ? {
    true    => 'puppet:///modules/upstart/dbus/Upstart.conf.user_jobs',
    false   => 'puppet:///modules/upstart/dbus/Upstart.conf.no_user_jobs',
    default => fail('Invalid value for $user_jobs'),
  }

  $upstart_user_jobs_ensure = $user_jobs ? {
    true    => 'present',
    false   => 'absent',
    default => fail('Invalid value for $user_jobs'),
  }

  package { $package:
    ensure  => $package_version,
  }

  file { $dbus_config:
    source  => $upstart_dbus_config_source,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$package],
  }

  file { "${init_dir}/user_jobs.conf":
    ensure  => $upstart_user_jobs_ensure,
    source  => 'puppet:///modules/upstart/user_jobs.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$package],
  }
}
