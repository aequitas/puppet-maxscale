require 'spec_helper'

describe 'maxscale::instance' do
  context 'definition of the default instance' do
    let (:title) { 'default' }
    let (:params) {
      {
        :ensure    => 'running',
        :config    => {
          'maxscale'  => {
            'threads' => 2
          },
          'Binlog_Service'   => {
            'type'           => 'service',
            'router'         => 'binlogrouter',
            'router_options' => 'mariadb10-compatibility=1,server-id=10,binlogdir=/var/cache/maxscale/binlog',
            'user'           => 'maxscale',
            'passwd'         => 'PLEASE_CHANGE_ME!1!',
            'version_string' => '10.1.12-MariaDB-1~trusty',
          },
        },
        'master_ini'               => {
          'directory'              => '/var/cache/maxscale/binlog',
          'content'                => {
            'binlog_configuration' => {
              'master_host'        => '127.0.0.1',
              'master_port'        => 3306,
              'master_user'        => 'maxscale',
              'master_password'    => 'PLEASE_CHANGE_ME!2!',
              'filestem'           => 'mysql-bin',
            },
          },
        },
      }
    }
    it do
      should contain_file('/etc/init.d/maxscale')\
        .with_ensure('present')\
        .with_mode('0755')\
        .with_require('File[/etc/maxscale.cnf]')\
        .with_notify('Service[maxscale]')\
        .with_content(/^processname=maxscale$/)\
        .with_content(/^servicename=maxscale$/)\
        .with_content(/--config=\/etc\/maxscale.cnf/)\
        .with_content(/--datadir=\/var\/cache\/maxscale/)\
        .with_content(/--logdir=\/var\/log\/maxscale/)\
        .with_content(/--cachedir=\/var\/cache\/maxscale/)\
        .with_content(/--piddir=\/var\/run\/maxscale/)\
        .with_content(/--language=\/var\/lib\/maxscale/)\
        .with_content(/--user=maxscale/)
    end
    it do
      should contain_file('/etc/maxscale.cnf')\
        .with_ensure('present')\
        .with_require('[Class[Maxscale::Install]{:name=>"Maxscale::Install"}, File[/etc]{:path=>"/etc"}]')\
        .with_content(/^\[maxscale\]$/)\
        .with_content(/^threads=2$/)\
        .with_content(/^\[Binlog_Service\]$/)\
        .with_content(/^type=service$/)
    end
    it do
      should contain_file('/var/cache/maxscale/binlog/master.ini')\
        .with_ensure('present')\
        .with_require('[Class[Maxscale::Install]{:name=>"Maxscale::Install"}, File[/var/cache/maxscale/binlog]{:path=>"/var/cache/maxscale/binlog"}]')\
        .with_content(/^\[binlog_configuration\]$/)\
        .with_content(/^master_host=127.0.0.1$/)
    end
    it do
      should contain_service('maxscale')\
        .with_ensure('running')\
        .with_hasrestart(true)\
        .with_hasstatus(true)\
        .that_subscribes_to('File[/etc/maxscale.cnf]')
    end
    it { should_not contain_file('/etc/maxscale').with_ensure('directory') }
    it { should contain_file('/etc').with_ensure('directory') }
    it { should contain_file('/var/cache/maxscale').with_ensure('directory').with_owner('maxscale') }
    it { should contain_file('/var/cache/maxscale/binlog').with_ensure('directory').with_owner('maxscale') }
    it { should contain_file('/var/log/maxscale').with_ensure('directory').with_owner('maxscale') }
    it { should contain_file('/var/run/maxscale').with_ensure('directory').with_owner('maxscale') }
    it { should contain_file('/var/lib/maxscale').with_ensure('directory').with_owner('maxscale') }
  end

  context 'definition of a non-default instance' do
    let (:title) { 'foo' }
    let (:params) {
      {
        :ensure         => 'stopped',
        :logdir         => '/var/log/maxscale_foo',
        :cachedir       => '/var/cache/maxscale_foo',
        :datadir        => '/var/data/maxscale_foo',
        :piddir         => '/var/run/maxscale_foo',
        :errmsgsys_path => '/var/lib/maxscale_foo',
        :svcuser        => 'nobody',
        :svcgroup       => 'nogroup',
        :configfile     => '/etc/maxscale/maxscale_foo.cnf',
        :config         => {
          'maxscale'    => {
            'threads'   => 1
          },
          'Binlog Listener' => {
            'type'          => 'service',
          }
        },
				'master_ini'               => {
					'directory'              => '/var/cache/maxscale_foo/binlog',
					'content'                => {
						'binlog_configuration' => {
							'master_host'        => '10.0.0.125',
							'master_port'        => 3306,
							'master_user'        => 'maxscale',
							'master_password'    => 'PLEASE_CHANGE_ME!3!',
							'filestem'           => 'mysql-bin',
						},
					},
				},
      }
    }

    it { should contain_file('/etc/maxscale').with_ensure('directory') }
    it { should contain_file('/var/cache/maxscale_foo').with_ensure('directory') }
    it { should contain_file('/var/cache/maxscale_foo/binlog').with_ensure('directory') }
    it { should contain_file('/var/log/maxscale_foo').with_ensure('directory') }
    it { should contain_file('/var/run/maxscale_foo').with_ensure('directory') }
    it { should contain_file('/var/data/maxscale_foo').with_ensure('directory') }
    it { should contain_file('/var/lib/maxscale_foo').with_ensure('directory') }

    it do
      should contain_file('/etc/init.d/maxscale_foo')\
        .with_ensure('present')\
        .with_mode('0755')\
        .with_require('File[/etc/maxscale/maxscale_foo.cnf]')\
        .with_notify('Service[maxscale_foo]')\
        .with_content(/^processname=maxscale_foo$/)\
        .with_content(/^servicename=maxscale_foo$/)\
        .with_content(/--config=\/etc\/maxscale\/maxscale_foo.cnf/)\
        .with_content(/--datadir=\/var\/data\/maxscale_foo/)\
        .with_content(/--logdir=\/var\/log\/maxscale_foo/)\
        .with_content(/--cachedir=\/var\/cache\/maxscale_foo/)\
        .with_content(/--piddir=\/var\/run\/maxscale_foo/)\
        .with_content(/--language=\/var\/lib\/maxscale_foo/)\
        .with_content(/--user=nobody/)
    end
    it do
      should contain_file('/etc/maxscale/maxscale_foo.cnf')\
        .with_ensure('present')\
        .with_require('[Class[Maxscale::Install]{:name=>"Maxscale::Install"}, File[/etc/maxscale]{:path=>"/etc/maxscale"}]')
        .with_content(/^\[maxscale\]$/)\
        .with_content(/^threads=1$/)\
        .with_content(/^\[Binlog Listener\]$/)\
        .with_content(/^type=service$/)
    end
    it do
      should contain_file('/var/cache/maxscale_foo/binlog/master.ini')\
        .with_ensure('present')\
        .with_require('[Class[Maxscale::Install]{:name=>"Maxscale::Install"}, File[/var/cache/maxscale_foo/binlog]{:path=>"/var/cache/maxscale_foo/binlog"}]')\
        .with_content(/^\[binlog_configuration\]$/)\
        .with_content(/^master_host=10.0.0.125$/)\
        .with_content(/^master_port=3306$/)\
        .with_content(/^master_user=maxscale$/)\
        .with_content(/^master_password=PLEASE_CHANGE_ME!3!$/)\
        .with_content(/^filestem=mysql-bin$/)
    end
    it do
      should contain_service('maxscale_foo')\
        .with_ensure('stopped')\
        .with_hasrestart(true)\
        .with_hasstatus(true)\
        .that_subscribes_to('File[/etc/maxscale/maxscale_foo.cnf]')
    end
  end
end
