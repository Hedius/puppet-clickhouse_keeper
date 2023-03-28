# @summary Manages Clickouse Keeper
#
# @param manage_repo
#    Whether APT/RPM repository should be managed by Puppet
# @param packages
#    OS packages to be installed
#
# @example
#   include clickhouse_keeper
class clickhouse_keeper(
  Boolean $manage_repo = true,
  Boolean $manage_package = true,
  Array[String[1]] $packages = ['clickhouse-keeper'],
  String $package_ensure = 'present',
  Array[String] $package_install_options = [],
  ) {

  if $manage_repo {
    include clickhouse_keeper::repo
  }

  if $manage_package {
    ensure_packages($packages, {
      ensure  => $package_ensure,
      install_options => $package_install_options,
    })
  }

}
