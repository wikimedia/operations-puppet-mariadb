# mariadb heartbeat capability
class mariadb::heartbeat {
    #TODO: Create a systemd service file
    file { '/etc/init.d/pt-heartbeat':
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
        source => 'puppet:///modules/mariadb/pt-heartbeat.init',
    }

    service { 'pt-heartbeat':
        ensure    => running,
        require   => File['/etc/init.d/pt-heartbeat'],
        subscribe => File['/etc/init.d/pt-heartbeat'],
        hasstatus => false,
    }
}
