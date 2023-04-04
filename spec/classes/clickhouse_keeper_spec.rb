# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse_keeper' do
  _, os_facts = on_supported_os.first
  let(:facts) { os_facts }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_package('clickhouse-keeper').that_requires('Class[clickhouse_keeper::repo]') }
  it { is_expected.to contain_class('clickhouse_keeper::repo') }
  it { is_expected.to contain_class('clickhouse_keeper::config') }

  context 'set server_id' do
    let(:params) { { id: 2 } }

    it {
      is_expected.to contain_file('/etc/clickhouse-keeper/keeper_config.xml').with_content(%r{<server_id>2</server_id>})
    }
  end

  context 'set log level' do
    let(:params) { { log_level: 'trace' } }

    it {
      is_expected.to contain_file('/etc/clickhouse-keeper/keeper_config.xml').with_content(%r{<level>trace</level>})
    }
  end

  context 'set max_connections' do
    let(:params) { { max_connections: 1024 } }

    it {
      is_expected.to contain_file('/etc/clickhouse-keeper/keeper_config.xml').with_content(%r{<max_connections>1024</max_connections>})
    }
  end

end
