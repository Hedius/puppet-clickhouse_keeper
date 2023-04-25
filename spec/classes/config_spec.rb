# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse_keeper::config' do
  _, os_facts = on_supported_os.first
  let(:facts) { os_facts }

  let :pre_condition do
    'include clickhouse_keeper'
  end

  it { is_expected.to compile.with_all_deps }

  it {
    is_expected.to contain_concat('/etc/clickhouse-keeper/keeper_config.xml').with(
      mode: '0664',
      owner: 'clickhouse',
      group: 'clickhouse',
    )
  }
end
