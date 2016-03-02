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

    exec { 'pt-heartbeat':
        command => "/usr/bin/perl \
                    /usr/local/bin/pt-heartbeat-wikimedia \
                    --defaults-file=/root/.my.cnf -D heartbeat \
                    --shard=${shard} --update --replace --interval=0.5 \
                    -S /tmp/mysql.sock --daemonize \
                    --pid /var/run/pt-heartbeat.pid",
        unless  => '/bin/ps --pid $(cat /var/run/pt-heartbeat.pid) \
                    > /dev/null 2>&1',
        user    => 'root',
        require => File['/usr/local/bin/pt-heartbeat-wikimedia'],
    }
}
