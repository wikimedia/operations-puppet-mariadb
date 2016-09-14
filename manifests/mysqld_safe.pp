# Make /opt/wmf-mariadb10/bin/mysqld_safe managed by puppet. This allows us to make quick
# changes to harden the wrapper without rebuilding the custom wmf-mariabd10 package
# Once all trusty dbs are gone, we can hopefully discard mysqld_safe in favour of a custom
# systemd service unit
class role::mariadb::mysqld_safe {

    file { '/opt/wmf-mariadb10/bin/mysqld_safe':
        ensure => present,
        owner  => 'root',
        group  => 'mysql',
        mode   => '0755',
        source => 'puppet:///files/mariadb/mysqld_safe',
    }
}
