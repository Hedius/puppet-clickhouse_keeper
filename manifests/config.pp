# @summary Manage Clickouse keeper config
#
# A description of what this class does
#
# @example
#   include clickhouse_keeper::config
class clickhouse_keeper::config (
) {
  file { "${clickhouse_keeper::config_dir}/${clickhouse_keeper::config_file}":
    content => epp("${module_name}/keeper_config.xml.epp", {
        'log_level'       => $clickhouse_keeper::log_level,
        'server_id'       => $clickhouse_keeper::id,
        'log'             => $clickhouse_keeper::log_file,
        'error_file'      => $clickhouse_keeper::error_file,
        'log_size'        => $clickhouse_keeper::log_size,
        'log_count'       => $clickhouse_keeper::log_count,
        'max_connections' => $clickhouse_keeper::max_connections,
    }),
    mode    => '0664',
    owner   => $clickhouse_keeper::owner,
    group   => $clickhouse_keeper::group,
  }
}
