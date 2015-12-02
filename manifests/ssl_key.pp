class mariadb::ssl_key ($file) {
    file { "/etc/mysql/ssl/${file}":
        ensure    => file,
        owner     => 'root',
        group     => 'mysql',
        mode      => '0440',
        show_diff => false,
        backup    => false,
        content   => secret("mysql/${file}"),
        require   => File['/etc/mysql/ssl'],
    }
}
