# MariaDB 10 multi-source replication

define mariadb::monitor_replication(
    $is_critical   = true,
    $contact_group = 'dba',
    $lag_warn      = 60,
    $lag_crit      = 300,
    $socket        = '/tmp/mysql.sock',
    $multisource   = true,
    $warn_stopped  = true,
    ) {

    include passwords::nagios::mysql
    $password = $passwords::nagios::mysql::mysql_check_pass

    $check_mariadb = "/usr/lib/nagios/plugins/check_mariadb.pl --sock=${socket} --user=nagios --pass=${password}"

    $check_mariadb = $multisource ? {
        true  => "${check_mariadb} --set=default_master_connection=${name}",
        false => "${check_mariadb}"
    }

    $check_mariadb = $warn_stopped ? {
        true  => "${check_mariadb} --warn-stopped",
        false => "${check_mariadb} --no-warn-stopped"
    }

    nrpe::monitor_service { "mariadb_slave_io_state_${name}":
        description   => "MariaDB Slave IO: ${name}",
        nrpe_command  => "${check_mariadb} --check=slave_io_state",
        critical      => true,
        contact_group => $contact_group,
    }

    nrpe::monitor_service { "mariadb_slave_sql_state_${name}":
        description   => "MariaDB Slave SQL: ${name}",
        nrpe_command  => "${check_mariadb} --check=slave_sql_state",
        critical      => true,
        contact_group => $contact_group,
    }

    nrpe::monitor_service { "mariadb_slave_sql_lag_${name}":
        description   => "MariaDB Slave Lag: ${name}",
        nrpe_command  => "${check_mariadb} --check=slave_sql_lag --sql-lag-warn=${lag_warn} --sql-lag-crit=${lag_crit}",
        critical      => true,
        contact_group => $contact_group,
    }
}