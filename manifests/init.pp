# @summary Manages Clickouse Keeper
#
# @param id
#    Must be unique among servers
# @param manage_config
# @param manage_repo
#    Whether APT/RPM repository should be managed by Puppet
# @param manage_package
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
  Integer $id = 1,
  Boolean $manage_config = true,
  Boolean $manage_repo = true,
  Boolean $manage_package = true,
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
) {
  if $manage_repo {
    include clickhouse_keeper::repo
  }

  if $manage_package {
    $_require = $manage_repo ? {
      true => Class['clickhouse_keeper::repo'],
      false => [],
    }
    ensure_packages($packages, {
        ensure  => $package_ensure,
        install_options => $package_install_options,
        require => $_require,
    })
  }

  if $manage_config {
    include clickhouse_keeper::config
  }
}
