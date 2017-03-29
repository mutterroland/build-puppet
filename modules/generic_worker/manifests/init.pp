class generic_worker {
    include packages::mozilla::generic_worker

    case $::operatingsystem {
        Darwin: {
            $macos_version = regsubst($::macosx_productversion_major, '\.', '-')
            $taskcluster_client_id = secret('generic_worker_macosx_client_id')
            $taskcluster_access_token = hiera('generic_worker_macosx_access_token')
            $livelog_secret = hiera('livelog_secret')

            file { '/Library/LaunchAgents/net.generic.worker.plist':
                ensure => present,
                content => template('generic_worker/generic-worker.plist.erb'),
                mode => 0644,
                owner => root,
                group => wheel,
            }
            file { '/etc/generic-worker.config':
                ensure => present,
                content => template('generic_worker/generic-worker.config.erb'),
                mode => 0644,
                owner => root,
                group => wheel,
            }
            service { "net.generic.worker":
                require   => [
                    File["/Library/LaunchAgents/net.generic.worker.plist"],
                ],
                enable    => true;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
