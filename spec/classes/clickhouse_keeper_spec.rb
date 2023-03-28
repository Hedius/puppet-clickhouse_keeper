# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse_keeper' do
  _, os_facts = on_supported_os.first
  let(:facts) { os_facts }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_package('clickhouse-keeper') }
  it { is_expected.to contain_class('clickhouse_keeper::repo')}
end
