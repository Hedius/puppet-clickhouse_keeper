# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse_keeper' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_package('clickhouse-keeper')}
    end
  end
end
