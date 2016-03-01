# mariadb heartbeat capability
class mariadb::heartbeat (
    $shard = 'unknown',
) {
    #TODO: Create a systemd service file
    file { '/etc/init.d/pt-heartbeat':
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
        source => 'puppet:///modules/mariadb/pt-heartbeat.init',
    }

    # custom modified version of pt-heartbeat that includes an
    # extra column "shard"
    file { '/usr/local/bin/pt-heartbeat-wikimedia':
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
        source => 'puppet:///modules/mariadb/pt-heartbeat-wikimedia',
    }

    service { 'pt-heartbeat':
        ensure    => running,
        start     => "/etc/init.d/pt-heartbeat start ${shard}",
        require   => [  File['/etc/init.d/pt-heartbeat'],
                        File['/usr/local/bin/pt-heartbeat-wikimedia'],
                        ],
        subscribe => [  File['/etc/init.d/pt-heartbeat'],
                        File['/usr/local/bin/pt-heartbeat-wikimedia'],
                        ],
        hasstatus => false,
    }
}
