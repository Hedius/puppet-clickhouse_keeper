# @summary Manages Clickouse Keeper
#
# @param id
#    Must be unique among servers
# @param manage_config
# @param manage_repo
#    Whether APT/RPM repository should be managed by Puppet
# @param manage_package
# @param manage_service
# @param packages
#    OS packages to be installed
# @param package_ensure
# @paran package_install_options
# @param owner
#    System user account to own config files
# @param group
#    System group to own config files
# @param config_dir
#    Path to config directory
# @param config_file
# @param log_level
# @param log_file
# @param error_file
# @param log_size
# @param log_count
# @param max_connections
# @param service_enable
# @param service_ensure
# @param tcp_port
#    Port for client connections
#
# @example
#   include clickhouse_keeper
class clickhouse_keeper (
  Integer $id = fqdn_rand(255, $facts['networking']['ip']),
  Boolean $manage_config = true,
  Boolean $manage_repo = true,
  Boolean $manage_user = true,
  Boolean $manage_package = true,
  Boolean $manage_service = true,
  Boolean $export_raft = true,
  Boolean $generate_certs = false,
  Clickhouse_Keeper::Raft_config $raft_config = {},
  Array[String[1]] $packages = ['clickhouse-keeper'],
  String $package_ensure = 'present',
  Array[String] $package_install_options = [],
  String $owner = 'clickhouse',
  String $group = 'clickhouse',
  Stdlib::AbsolutePath $config_dir = '/etc/clickhouse-keeper',
  String $config_file = 'keeper_config.xml',
  Clickhouse_Keeper::LogLevel $log_level = 'information',
  Stdlib::AbsolutePath $log_file = '/var/log/clickhouse-keeper/clickhouse-keeper.log',
  Stdlib::AbsolutePath $error_file = '/var/log/clickhouse-keeper/clickhouse-keeper.err.log',
  String $log_size = '1000M',
  Integer $log_count = 10,
  Integer $max_connections = 4096,
  String $address = $facts['networking']['ip'],
  String $cluster = 'main',
  String $service_name = 'clickhouse-keeper',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Integer $raft_port = 9234,
  Integer $tcp_port = 9181,
  Stdlib::AbsolutePath $certificate = '/etc/clickhouse-keeper/server.crt',
  Stdlib::AbsolutePath $private_key = '/etc/clickhouse-keeper/server.key',
  Stdlib::AbsolutePath $dhparams = '/etc/clickhouse-keeper/dhparam.pem',
) {

  include clickhouse_keeper::repo

  if $manage_user {
    ensure_resource('group', $group)

    ensure_resource('user', $owner,
      {
        'shell' => '/bin/false',
        'home'  => '/dev/null',
        'gid' => $group,
      }
    )
  }

  if $manage_config {
    $config_path = "${config_dir}/${config_file}"

    file { $config_dir:
      ensure => directory,
      mode   => '0644',
      owner  => $owner,
      group  => $group,
      require => Class['Clickhouse_keeper::Repo']
    }

    if $manage_package {
      File <<| title == $config_dir |>> {
        require => Package[$packages],
      }
    }

    if $manage_user {
      File <<| title == $config_dir |>> {
        require => User[$owner],
      }
    }

    class { 'clickhouse_keeper::config':
      config_path => $config_path,
      cluster     => $cluster,
      require     => File[$config_dir]
    }

    if $export_raft {
      clickhouse_keeper::raft { "clickhouse_keeper-${address}":
        id          => $id,
        address     => $address,
        port        => $raft_port,
        target      => $config_path,
        cluster     => $cluster,
        export_raft => true,
      }
    }

    if !empty($raft_config) {
      $raft_config.each |$server, $props| {
        clickhouse_keeper::raft { "clickhouse_keeper-${server}":
          id          => $props['id'],
          address     => $props['address'],
          port        => $props['port'],
          target      => $config_path,
          cluster     => $props['cluster'],
          export_raft => false,
        }
      }
    }
  }

  if $manage_package {
    ensure_packages($packages, {
        ensure          => $package_ensure,
        install_options => $package_install_options,
        require         => Class['Clickhouse_keeper::Repo'],
    })
  }

  if $generate_certs {
    # This is going to take a long time
    exec { 'generate_dhparams':
      command => "openssl dhparam -out ${dhparams} 4096",
      path    => [ '/bin', '/usr/bin' ],
      onlyif  => 'which openssl',
      creates => $dhparams,
      timeout => 0, # disable timeout
    }
  }

  if $manage_service {
    service { $service_name:
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => Class['Clickhouse_keeper::Config'],
    }

    if $manage_package {
      Service <<| title == $service_name |>> {
        require => Package[$packages],
      }
    }

    if $manage_config {
      Service <<| title == $service_name |>> {
        require => File["${config_dir}/${config_file}"],
      }
    }
  }
}
