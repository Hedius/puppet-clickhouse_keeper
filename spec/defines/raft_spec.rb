# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse_keeper::raft' do
  let(:title) { 'localhost' }
  let(:params) do
    {
      id: 1,
      address: 'localhost',
      port: 9123,
      cluster: 'main',
      target: '/etc/clickhouse-keeper/config.xml'
    }
  end

  context 'with default parameters' do
    _, os_facts = on_supported_os.first
    let(:facts) { os_facts }

    it { is_expected.to compile.with_all_deps }
  end
end
