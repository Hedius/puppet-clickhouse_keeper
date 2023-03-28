# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse_keeper::repo' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }


      case os_facts[:os][:family]
      when 'Debian'
        it {
          is_expected.to contain_apt__source('clickhouse').with(
            name: 'clickhouse',
            location: 'https://packages.clickhouse.com/deb',
            release: 'stable main',
            repos: '',
          )
        }
      end

    end
  end
end
