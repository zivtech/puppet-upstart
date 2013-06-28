# = Class: upstart
#
class upstart (
  $package         = 'UNDEF',
  $package_version = 'installed',
  $user_jobs       = false,
  $init_dir        = 'UNDEF',
  $dbus_config     = 'UNDEF'
) {

  include upstart::params

  validate_bool($user_jobs)

  $upstart_package = $package ? {
    'UNDEF' => $::upstart::params::package,
    default => $package
  }

  $upstart_init_dir = $init_dir ? {
    'UNDEF' => $::upstart::params::init_dir,
    default => $init_dir
  }

  $upstart_dbus_config = $dbus_config ? {
    'UNDEF' => $::upstart::params::dbus_config,
    default => $dbus_config
  }

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

  package { $upstart_package:
    ensure  => $package_version,
  }

  file { $upstart_dbus_config:
    source  => $upstart_dbus_config_source,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$upstart_package],
  }

  file { "${upstart_init_dir}/user_jobs.conf":
    ensure  => $upstart_user_jobs_ensure,
    source  => 'puppet:///modules/upstart/user_jobs.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$upstart_package],
  }
}
