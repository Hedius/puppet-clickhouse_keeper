# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'pry'

describe 'clickhouse_keeper' do
  context 'basic setup' do
    it 'installs clickhouse_keeper' do
      pp = <<~EOS
        class { 'clickhouse_keeper':
          export_raft => false,
          id => 1,
          raft_config => {
            'localhost' => {
              'id' => 1,
              'address' => '127.0.0.1',
              'port' => 9234,
              'cluster' => 'main',
            },
          },
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: false)
    end

    describe file('/etc/clickhouse-keeper') do
      it { is_expected.to be_directory }
      it { is_expected.to be_readable.by('owner') }
      it { is_expected.to be_readable.by('group') }
      it { is_expected.to be_readable.by('others') }
    end

    # we need a static raft config for this
    # describe package('clickhouse-keeper') do
    #   it { is_expected.to be_installed }
    # end

    # describe service('clickhouse-keeper') do
    #  #it { is_expected.to be_enabled }
    #  # might be in state activating
    #  # it { is_expected.to be_running }
    # end
  end
end
