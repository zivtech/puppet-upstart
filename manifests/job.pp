# Define: upstart::job
#
define upstart::job (
  $ensure              = 'present',
  $service_ensure      = 'running',
  $service_enable      = true,
  $author              = 'puppet-upstart',
  $description         = undef,
  $version             = undef,
  $usage               = undef,
  $start_on            = 'runlevel [2345]',
  $stop_on             = 'runlevel [016]',
  $emits               = [],
  $instance            = undef,
  $expect              = undef,
  $respawn             = false,
  $respawn_limit       = undef,
  $normal_exit         = undef,
  $kill_signal         = undef,
  $kill_timeout        = undef,
  $user                = undef,
  $group               = undef,
  $chdir               = undef,
  $console             = 'log',
  $umask               = undef,
  $oom_score           = undef,
  $nice                = undef,
  $limit               = {},
  $env                 = {},
  $pre_start           = undef,
  $post_start          = undef,
  $pre_stop            = undef,
  $post_stop           = undef,
  $script              = undef,
  $exec                = undef,
  $restart             = undef,
  $refresh             = true,
  $task                = false,
  $run_type_service    = true,
) {

  require upstart

  validate_re($ensure, '^(present|absent)$',
  'ensure must be "present" or "absent".')

  validate_re($service_ensure, '^(running|true|stopped|false)$',
  'service_ensure must be "running" or "stopped".')

  validate_re($console, '^(log|none|output)$',
  'console must be "log", "none", or "output".')

  if ($expect != undef) {
    validate_re($expect, '^(|fork|daemon|stop)$',
    'expect must be "fork", "daemon", "stop".')
  }

  validate_bool($service_enable)
  validate_bool($respawn)

  validate_array($emits)

  validate_hash($limit)
  validate_hash($env)

  if !(empty($script) or empty($exec)) {
    fail('You cannot specify both script and exec. Choose one.')
  }

  require upstart

  $config_path = "${upstart::init_dir}/${name}.conf"

  if ($ensure == 'present') {
    $file_ensure = 'file'
  } else {
    $file_ensure = 'absent'
  }
  file { $config_path:
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('upstart/job.erb'),
  } ->
  file { "initd_symlink_${name}":
    ensure => link,
    path   => "/etc/init.d/${name}",
    target => '/lib/init/upstart-job',
  }

  if ! $task {
    if $run_type_service {
      # We can only manage the service if the job config is there.
      # We could invert the dependency relationship between the
      # config file and the service depending on whether $ensure
      # was 'present' or 'absent', but that would only work on the
      # first run. Hopefully, we can come up with something better,
      # but this works well enough for now.
      if $ensure == 'present' {
        service { $name:
          ensure   => $service_ensure,
          enable   => $service_enable,
          provider => 'upstart',
          require  => File[$config_path],
        }

        if $refresh {
          Service[$name] {
            subscribe => File[$config_path],
          }
        }

        if !empty($restart) {
          Service[$name] {
            restart => $restart,
          }
        }
      } else {
        warning("Removing upstart job config: ${name}. You are responsible for \
  stopping the service.")
      }
    }
  }
}
