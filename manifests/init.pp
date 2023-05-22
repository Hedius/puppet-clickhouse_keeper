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
#
# @example
#   include clickhouse_keeper
class clickhouse_keeper (
  Integer $id = fqdn_rand(255, $facts['networking']['ip']),
  Boolean $manage_config = true,
  Boolean $manage_repo = true,
  Boolean $manage_package = true,
  Boolean $manage_service = true,
  Boolean $export_raft = true,
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
  Integer $raft_port = 9234,
) {
  if $manage_repo {
    include clickhouse_keeper::repo
  }

  if $manage_package {
    $_require = $manage_repo ? {
      true  => [Class['clickhouse_keeper::repo']],
      false => [],
    }
    ensure_packages($packages, {
        ensure          => $package_ensure,
        install_options => $package_install_options,
        require         => $_require,
    })
  }

  if $manage_config {
    $config_path = "${config_dir}/${config_file}"

    file { $config_dir:
      ensure => directory,
      mode   => '0664',
      owner  => $owner,
      group  => $group,
    }

    class { 'clickhouse_keeper::config':
      config_path => $config_path,
      cluster     => $cluster,
      require     => File[$config_dir]
    }

    if $export_raft {
      clickhouse_keeper::raft { "clickhouse_keeper-${address}":
        id      => $id,
        address => $address,
        port    => $raft_port,
        target  => $config_path,
        cluster => $cluster,
      }
    }
  }

  if $manage_service {
    service { $service_name:
      ensure => $service_ensure
    }
  }
}
