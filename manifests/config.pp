class upstart::config {
  $dbus_config_source = $upstart::user_jobs ? {
    true    => 'puppet:///modules/upstart/dbus/Upstart.conf.user_jobs',
    false   => 'puppet:///modules/upstart/dbus/Upstart.conf.no_user_jobs',
    default => fail('Invalid value for $upstart::user_jobs'),
  }

  file { $upstart::dbus_config:
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => $dbus_config_source,
  }
}
