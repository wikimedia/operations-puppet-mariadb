class mariadb::ssl_key ($filename) {
    file { "/etc/mysql/ssl/${filename}":
        ensure    => file,
        owner     => 'root',
        group     => 'mysql',
        mode      => '0440',
        show_diff => false,
        backup    => false,
        content   => secret("mysql/${filename}"),
        require   => File['/etc/mysql/ssl'],
    }
}
