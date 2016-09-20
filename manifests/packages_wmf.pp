# MariaDB WMF patched build installed in /opt.
# Unless you're setting up a production server, you probably want vanilla mariadb::packages

class mariadb::packages_wmf(
    $mariadb10 = true,
    ) {

    package { [
        'libaio1',
        'percona-toolkit',
        'percona-xtrabackup',
        'libjemalloc1',
        'pigz',
    ]:
        ensure => present,
    }

    if ($mariadb10 == true) {

        package { [
            'wmf-mariadb10',
        ]:
            ensure => present,
        }
    }
    else {

        package { [
            'wmf-mariadb',
        ]:
            ensure => present,
        }
    }

    # if you have installed the wmf mariadb package,
    # create a custom, safer mysqld_safe
    # Required until a new package is created
    include mariadb::mysqld_safe
}
