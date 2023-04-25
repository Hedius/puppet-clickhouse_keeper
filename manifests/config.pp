# @summary Manage Clickouse keeper config
#
# @api private
class clickhouse_keeper::config (
  Stdlib::AbsolutePath $config_path,
  String $cluster,
) {
  if !defined(Concat[$config_path]) {
    concat { $config_path:
      ensure => present,
      tag    => 'clickhouse_keeper::config',
      warn   => true,
      mode   => '0664',
      owner  => $clickhouse_keeper::owner,
      group  => $clickhouse_keeper::group,
    }
  }

  concat::fragment { 'keeper_config':
    target  => $config_path,
    content => epp("${module_name}/keeper_config.xml.epp", {
        'log_level'       => $clickhouse_keeper::log_level,
        'server_id'       => $clickhouse_keeper::id,
        'log'             => $clickhouse_keeper::log_file,
        'error_file'      => $clickhouse_keeper::error_file,
        'log_size'        => $clickhouse_keeper::log_size,
        'log_count'       => $clickhouse_keeper::log_count,
        'max_connections' => $clickhouse_keeper::max_connections,
    }),
    order   => 1,
  }

  Concat::Fragment <<| tag == "clickhouse_keeper::config-${cluster}" |>>

  concat::fragment { 'keeper_footer':
    target  => $config_path,
    content => epp("${module_name}/keeper_footer.xml.epp"),
    order   => 99,
  }
}
