# Please use separate .cnf templates for each type of server.
# Keep this independent and modular. It should be includable without the mariadb class.

class mariadb::config(
    $config   = 'mariadb/default.my.cnf.erb',
    $prompt   = '',
    $password = 'undefined',
    $datadir  = '/srv/sqldata',
    $tmpdir   = '/srv/tmp',
    ) {

    $server_id = inline_template(
        "<%= ia = @ipaddress.split('.'); server_id = ia[0] + ia[2] + ia[3]; server_id %>"
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
        content => template("mariadb/root.my.cnf.erb"),
    }

    file { '/etc/mysql/my.cnf':
        ensure => link,
        target => '/etc/my.cnf',
    }

    file { "$datadir":
        ensure  => directory,
        owner   => 'mysql',
        group   => 'mysql',
        mode    => '0755',
    }

    file { "$tmpdir":
        ensure  => directory,
        owner   => 'mysql',
        group   => 'mysql',
        mode    => '0755',
    }
}