# Please use separate .cnf templates for each type of server.
# Keep this independent and modular. It should be includable
# without the mariadb class.

# Accepted values for the $semi_sync parameter are:
# 'off' | 'slave' | 'master' | 'both'

# Accepted values for the $replication_role parameter are:
# 'standalone' | 'slave' | 'master' | 'multisource_slave'

class mariadb::config(
    $config           = 'mariadb/default.my.cnf.erb',
    $prompt           = '',
    $password         = 'undefined',
    $datadir          = '/srv/sqldata',
    $tmpdir           = '/srv/tmp',
    $sql_mode         = '',
    $read_only        = 'off',
    $p_s              = 'off',
    $ssl              = 'off',
    $binlog_format    = 'MIXED',
    $semi_sync        = 'off',
    $replication_role = 'standalone',
    ) {

    $server_id = inline_template(
        "<%= @ipaddress.split('.').inject(0)\
{|total,value| (total << 8 ) + value.to_i} %>"
    )

    file { '/etc/my.cnf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template($config),
    }

    file { '/root/.my.cnf':
        owner   => 'root',
        group   => 'root',
        mode    => '0400',
        content => template('mariadb/root.my.cnf.erb'),
    }

    file { '/etc/mysql':
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { '/etc/mysql/my.cnf':
        ensure  => link,
        target  => '/etc/my.cnf',
        require => File['/etc/mysql'],
    }

    # Include these manually. If we're testing on systems with tarballs
    # instead of debs, the user won't exist.
    group { 'mysql':
        ensure => present,
    }

    user { 'mysql':
        ensure     => present,
        gid        => 'mysql',
        shell      => '/bin/false',
        home       => '/nonexistent',
        system     => true,
        managehome => false,
    }

    file { $datadir:
        ensure => directory,
        owner  => 'mysql',
        group  => 'mysql',
        mode   => '0755',
    }

    file { $tmpdir:
        ensure => directory,
        owner  => 'mysql',
        group  => 'mysql',
        mode   => '0755',
    }

    file { '/usr/lib/nagios/plugins/check_mariadb.pl':
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => 'puppet:///files/icinga/check_mariadb.pl',
    }

    if ($ssl == 'on' or $ssl == 'multiple-ca' or $ssl == 'puppet-cert') {

        # This creates also /etc/mysql/ssl
        ::base::expose_puppet_certs { '/etc/mysql':
            ensure          => present,
            provide_private => true,
            user            => 'mysql',
            group           => 'mysql',
        }

        file { '/etc/mysql/ssl/cacert.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/cacert.pem'),
        }
        file { '/etc/mysql/ssl/server-key.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/server-key.pem'),
        }
        file { '/etc/mysql/ssl/server-cert.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/server-cert.pem'),
        }
        file { '/etc/mysql/ssl/client-key.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/client-key.pem'),
        }
        file { '/etc/mysql/ssl/client-cert.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/client-cert.pem'),
        }

    }

    if ($ssl == 'multiple-ca') {
        # Temporary CA certificate with multiple PEM for backward compatibility
        # Rewritten with exec because of the missing concat module
        exec { 'multiple-ca':
            command => '/bin/cat /etc/ssl/certs/Puppet_Internal_CA.pem /etc/mysql/ssl/cacert.pem > /etc/mysql/ssl/ca.crt',
            creates => '/etc/mysql/ssl/ca.crt',
            require => File['/etc/mysql/ssl/cacert.pem'],
        }

        file { '/etc/mysql/ssl/ca.crt':
            ensure  => present,
            owner   => 'mysql',
            group   => 'mysql',
            mode    => '0444',
            require => Exec['multiple-ca'],
        }

    }
}
