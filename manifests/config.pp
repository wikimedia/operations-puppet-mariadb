# Please use separate .cnf templates for each type of server.
# Keep this independent and modular. It should be includable 
# without the mariadb class.

class mariadb::config(
    $config    = 'mariadb/default.my.cnf.erb',
    $prompt    = '',
    $password  = 'undefined',
    $datadir   = '/srv/sqldata',
    $tmpdir    = '/srv/tmp',
    $sql_mode  = '',
    $read_only = 'off',
    $p_s       = 'off',
    $ssl       = 'off',
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

    if ($ssl == 'on') {

        file { '/etc/mysql/ssl':
            ensure  => directory,
            owner   => 'root',
            group   => 'mysql',
            mode    => '0750',
            require => File['/etc/mysql']
        }
        ssl_key { 'cacert':
            filename => 'cacert.pem',
        }
        ssl_key { 'server-key':
            filename => 'server-key.pem',
        }
        ssl_key { 'server-cert':
            filename => 'server-cert.pem',
        }
        ssl_key { 'client-key':
            filename => 'client-key.pem',
        }
        ssl_key { 'client-cert':
            filename => 'client-cert.pem',
        }
    }
}
