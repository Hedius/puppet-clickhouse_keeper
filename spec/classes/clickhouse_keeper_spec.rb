# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse_keeper' do
  _, os_facts = on_supported_os.first
  let(:facts) { os_facts }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_package('clickhouse-keeper').that_requires('Class[clickhouse_keeper::repo]') }
  it { is_expected.to contain_class('clickhouse_keeper::repo') }
  it { is_expected.to contain_class('clickhouse_keeper::config') }

  context 'with default values' do
    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<server_id>\d+</server_id>})
    }

    it {
      is_expected.to contain_file('/etc/clickhouse-keeper').with(
        ensure: 'directory',
        owner: 'clickhouse',
        group: 'clickhouse',
      )
    }

    it {
      is_expected.to contain_user('clickhouse').with(
        home: '/dev/null',
        shell: '/bin/false',
        gid: 'clickhouse',
      )
    }

    it {
      is_expected.to contain_group('clickhouse').with(
        name: 'clickhouse',
      )
    }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<tcp_port>9181</tcp_port>})
    }

    it {
      is_expected.to contain_concat('/etc/clickhouse-keeper/keeper_config.xml')
    }
  end

  context 'set server_id' do
    let(:params) { { id: 2 } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<server_id>2</server_id>})
    }
  end

  context 'set log level' do
    let(:params) { { log_level: 'trace' } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<level>trace</level>})
    }
  end

  context 'set raft log level' do
    let(:params) { { raft_log_level: 'debug' } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<raft_logs_level>debug</raft_logs_level>})
    }
  end

  context 'set max_connections' do
    let(:params) { { max_connections: 1024 } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<max_connections>1024</max_connections>})
    }
  end

  context 'set tcp_port_secure' do
    let(:params) { { tcp_port_secure: 2182 } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<tcp_port_secure>2182</tcp_port_secure>})
    }
  end

  context 'set log_storage_path' do
    let(:params) { { log_storage_path: '/var/lib/keeper/coordination' } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<log_storage_path>/var/lib/keeper/coordination</log_storage_path>})
    }
  end

  context 'set snapshot_storage_path' do
    let(:params) { { snapshot_storage_path: '/var/lib/keeper/snapshot' } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<snapshot_storage_path>/var/lib/keeper/snapshot</snapshot_storage_path>})
    }
  end

  context 'set operation_timeout' do
    let(:params) { { operation_timeout: 5000 } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<operation_timeout_ms>5000</operation_timeout_ms>})
    }
  end

  context 'set min_session_timeout' do
    let(:params) { { min_session_timeout: 4000 } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<min_session_timeout_ms>4000</min_session_timeout_ms>})
    }
  end

  context 'set session_timeout' do
    let(:params) { { session_timeout: 6000 } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<session_timeout_ms>6000</session_timeout_ms>})
    }
  end

  context 'set prometheus port' do
    let(:params) { { prometheus_port: 9100 } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<prometheus>(\s+)?<port>9100</port>})
    }
  end

  context 'set listen_host' do
    let(:params) { { listen_host: '0.0.0.0' } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<clickhouse>(\s+)?<listen_host>0.0.0.0</listen_host>})
    }
  end

  context 'disable ipv6' do
    let(:params) { { enable_ipv6: false } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<enable_ipv6>false</enable_ipv6>})
    }
  end

  context 'manage service' do
    let(:params) do
      {
        manage_service: true,
        service_enable: true,
      }
    end

    it {
      is_expected.to contain_service('clickhouse-keeper').with(
        {
          ensure: 'running',
          enable: true,
        },
      ).that_subscribes_to('Concat[/etc/clickhouse-keeper/keeper_config.xml]')
    }
  end

  context 'do not manage service' do
    let(:params) do
      { manage_service: false }
    end

    it {
      is_expected.not_to contain_service('clickhouse-keeper')
    }
  end

  context 'set tcp port' do
    let(:params) { { tcp_port: 9100 } }

    it {
      is_expected.to contain_concat__fragment('keeper_config').with_content(%r{<tcp_port>9100</tcp_port>})
    }
  end

  context 'set ssl certificate' do
    let(:params) { { certificate: '/etc/ssl/server.crt' } }

    it {
      is_expected.to contain_concat__fragment('keeper_footer').with_content(%r{<certificateFile>/etc/ssl/server.crt</certificateFile>})
    }
  end

  context 'with static cluster config' do
    let(:params) do
      {
        export_raft: false,
        raft_config: {
          'zk1': {
            'id': 1,
            'address': '10.0.0.1',
            'port': 9234,
            'cluster': 'primary',
          },
          'zk2': {
            'id': 2,
            'address': '10.0.0.2',
            'port': 9234,
            'cluster': 'primary',
          },
          'zk3': {
            'id': 3,
            'address': '10.0.0.3',
            'port': 9234,
            'cluster': 'primary',
          },
        },
      }
    end

    it {
      is_expected.to contain_clickhouse_keeper__raft('clickhouse_keeper-zk1').with(
        {
          'id' => 1,
          'port' => 9234,
          'cluster' => 'primary',
        },
      )
    }
    it { is_expected.to contain_clickhouse_keeper__raft('clickhouse_keeper-zk2') }
    it { is_expected.to contain_clickhouse_keeper__raft('clickhouse_keeper-zk3') }

    it { is_expected.to contain_concat__fragment('clickhouse_keeper-zk1').with_content(%r{<id>1</id>}) }
    it { is_expected.to contain_concat__fragment('clickhouse_keeper-zk2').with_content(%r{<id>2</id>}) }
    it { is_expected.to contain_concat__fragment('clickhouse_keeper-zk3').with_content(%r{<id>3</id>}) }
  end
end
