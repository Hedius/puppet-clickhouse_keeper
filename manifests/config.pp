# @summary Manage Clickouse keeper config
#
# @api private
class clickhouse_keeper::config (
  Stdlib::AbsolutePath $config_dir,
  String $config_file,
  Stdlib::AbsolutePath $raft_path,
  String $cluster,
) {
  if !defined(Concat[$raft_path]) {
    concat { $raft_path:
      ensure => present,
      tag    => 'clickhouse_keeper::raft',
      warn   => true,
    }
  }

  concat::fragment { 'raft_header':
    target  => $raft_path,
    content => epp("${module_name}/raft_header.xml.epp"),
    order   => 1,
  }

  Concat::Fragment <<| tag == "clickhouse_keeper::raft-${cluster}" |>>

  concat::fragment { 'raft_footer':
    target  => $raft_path,
    content => epp("${module_name}/raft_footer.xml.epp"),
    order   => 99,
  }

  file { "${config_dir}/${config_file}":
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
