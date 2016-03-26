# Please use separate .cnf templates for each type of server.
# Keep this independent and modular. It should be includable
# without the mariadb class.

class mariadb::config(
    $config        = 'mariadb/default.my.cnf.erb',
    $prompt        = '',
    $password      = 'undefined',
    $datadir       = '/srv/sqldata',
    $tmpdir        = '/srv/tmp',
    $sql_mode      = '',
    $read_only     = 'off',
    $p_s           = 'off',
    $ssl           = 'off',
    $binlog_format = 'MIXED',
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

    if ($ssl == 'on' or $ssl == 'multiple-ca') {

        file { '/etc/mysql/ssl':
            ensure  => directory,
            owner   => 'root',
            group   => 'mysql',
            mode    => '0750',
            require => File['/etc/mysql']
        }
        file { '/etc/mysql/ssl/cacert.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/cacert.pem'),
            require   => File['/etc/mysql/ssl'],
        }
        file { '/etc/mysql/ssl/server-key.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/server-key.pem'),
            require   => File['/etc/mysql/ssl'],
        }
        file { '/etc/mysql/ssl/server-cert.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/server-cert.pem'),
            require   => File['/etc/mysql/ssl'],
        }
        file { '/etc/mysql/ssl/client-key.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/client-key.pem'),
            require   => File['/etc/mysql/ssl'],
        }
        file { '/etc/mysql/ssl/client-cert.pem':
            ensure    => file,
            owner     => 'root',
            group     => 'mysql',
            mode      => '0440',
            show_diff => false,
            backup    => false,
            content   => secret('mysql/client-cert.pem'),
            require   => File['/etc/mysql/ssl'],
        }

        ::base::expose_puppet_certs { '/etc/mysql':
            ensure          => present,
            provide_private => true,
            user            => 'mysql',
            group           => 'mysql',
        }
    }

    if ($ssl == 'multiple-ca') {
        # Temporary CA certificate with multiple PEM for backward compatibility
        # Rewritten with exec because of the missing concat module
        exec { 'multiple-ca':
            command => '/bin/cat /etc/ssl/certs/Puppet_Internal_CA.pem /etc/mysql/ssl/cacert.pem > /etc/mysql/ssl/ca.crt',
            creates => '/etc/mysql/ssl/ca.crt',
            require => [
                File['/etc/ssl/certs/Puppet_Internal_CA.pem'],
                File['/etc/mysql/ssl/cacert.pem'],
            ],
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
