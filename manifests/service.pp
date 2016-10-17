# Make /etc/init/mysql managed by puppet. This allows us to make quick
# changes to harden the wrapper without rebuilding the custom wmf-mariabd10
# package
# Once all trusty dbs are gone, we can hopefully discard init.d in favour
# of a custom systemd service unit
class mariadb::service (
    $package = 'wmf-mariadb10',
    ) {

    $basedir = "/opt/${package}"
    file { "${basedir}/service":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('mariadb/mariadb.server.erb'),
        require => Package["${package}"],
    }

    file { '/etc/init.d/mysql':
        ensure  => 'link',
        target  => "${basedir}/service",
        require => File["${basedir}/service"],
    }

    file { '/etc/init.d/mariadb':
        ensure  => 'link',
        target  => "${basedir}/service",
        require => File["${basedir}/service"],
    }

    # MySQL DOES NOT START BY DEFAULT- do not register it automatically
}
