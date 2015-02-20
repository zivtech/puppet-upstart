require 'spec_helper'

describe 'upstart', :type => :class do
  let(:title) { 'upstart' }

  it { should contain_package('upstart') \
    .with_ensure('installed')
  }

  it { should contain_file('/etc/dbus-1/system.d/Upstart.conf') \
    .with_source('puppet:///modules/upstart/dbus/Upstart.conf.no_user_jobs')
  }

  it { should contain_file('/etc/init/user_jobs.conf') \
    .with_ensure('absent')
  }

  describe 'with given package' do
    let(:params) {{ :package => 'foo' }}

    it { should contain_package('foo') }
    it { should_not contain_package('upstart') }
  end

  describe 'with given package version' do
    let(:params) {{ :package_version => 'latest' }}

    it { should contain_package('upstart') \
      .with_ensure('latest')
    }
  end

  describe 'with given dbus config' do
    let(:params) {{ :dbus_config => '/etc/dbus-1/foobar.conf' }}

    it { should contain_file('/etc/dbus-1/foobar.conf') \
      .with_source('puppet:///modules/upstart/dbus/Upstart.conf.no_user_jobs')
    }

    it { should_not contain_file('/etc/dbus-1/system.d/Upstart.conf') }
  end

  describe 'with user_jobs = true' do
    let(:params) {{ :user_jobs => true }}

    it { should contain_file('/etc/dbus-1/system.d/Upstart.conf') \
      .with_source('puppet:///modules/upstart/dbus/Upstart.conf.user_jobs')
    }

    it { should contain_file('/etc/init/user_jobs.conf') \
      .with_ensure('present')
    }
  end
end
