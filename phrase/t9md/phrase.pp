# Phrase: service
#======================================================================
class apache {
 service { 'apache': require => Class['squid'] }
}

# Phrase: apache class
#======================================================================
class apache {
 service { 'apache': require => Package['httpd'] }
}

class apache-ssl inherits apache {
 Service['apache'] { require +> [ File['apache.pem'], File['/etc/httpd/conf/httpd.conf'] ] }
}

#  Phrase: service
# ======================================================================
service { 'sshd':
 subscribe => File['sshdconfig'],
}

#  Phrase: file
# ======================================================================
file { 'sshdconfig':
  path => $operatingsystem ? {
    solaris => '/usr/local/etc/ssh/sshd_config',
    default => '/etc/ssh/sshd_config',
  },
  owner => 'root',
  group => 'root',
  mode  => '0644',
}

#  Phrase: exec
# ======================================================================
Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }
exec { 'echo this works': }

#  Phrase: thips
# ======================================================================
filebucket { main:
    server => puppet
}

#  Phrase: platform determine
# ======================================================================
class unix {
   file { '/etc/passwd':
        owner => 'root',
        group => 'root',
        mode  => 644;
   }
   file { '/etc/shadow':
        owner => 'root',
        group => 'root',
        mode  => 440;
   }
}

#  Phrase: SSH config sample
# ======================================================================
file { 'sshdconfig':
   name  => '/usr/local/etc/ssh/sshd_config',
   owner => 'root',
}

file { '/usr/local/etc/ssh/sshd_config':
   owner => 'sshd',
}

#  Phrase: Language Tutorial
# ======================================================================
# http://docs.puppetlabs.com/guides/language_guide.html
# http://wiki.opscode.com/display/chef/Resources

#  Phrase: type list
# ======================================================================
# These are the types known to puppet:
# augeas          - Apply the changes (single or array of changes ...
# computer        - Computer object management using DirectorySer ...
# cron            - Installs and manages cron jobs
# exec            - Executes external commands
# file            - Manages local files, including setting owners ...
# filebucket      - A repository for backing up files
# group           - Manage groups
# host            - Installs and manages host entries
# k5login         - Manage the 
# macauthorization - Manage the Mac OS X authorization database
# mailalias       - Creates an email alias in the local alias dat ...
# maillist        - Manage email lists
# mcx             - MCX object management using DirectoryService  ...
# mount           - Manages mounted filesystems, including puttin ...
# nagios_command  - The Nagios type command
# nagios_contact  - The Nagios type contact
# nagios_contactgroup - The Nagios type contactgroup
# nagios_host     - The Nagios type host
# nagios_hostdependency - The Nagios type hostdependency
# nagios_hostescalation - The Nagios type hostescalation
# nagios_hostextinfo - The Nagios type hostextinfo
# nagios_hostgroup - The Nagios type hostgroup
# nagios_service  - The Nagios type service
# nagios_servicedependency - The Nagios type servicedependency
# nagios_serviceescalation - The Nagios type serviceescalation
# nagios_serviceextinfo - The Nagios type serviceextinfo
# nagios_servicegroup - The Nagios type servicegroup
# nagios_timeperiod - The Nagios type timeperiod
# notify          - Sends an arbitrary message to the puppetd run ...
# package         - Manage packages
# resources       - This is a metatype that can manage other reso ...
# schedule        - Defined schedules for Puppet
# selboolean      - Manages SELinux booleans on systems with SELi ...
# selmodule       - Manages loading and unloading of SELinux poli ...
# service         - Manage running services
# ssh_authorized_key - Manages SSH authorized keys
# sshkey          - Installs and manages ssh host keys
# tidy            - Remove unwanted files based on specific crite ...
# user            - Manage users
# yumrepo         - The client-side description of a yum reposito ...
# zfs             - Manage zfs
# zone            - Solaris zones
# zpool           - Manage zpools

# Phrase: if else
#======================================================================
if $variable == 'foo' {
   include bar
} else {
   include foobar
}

# Phrase: regexp example
#======================================================================
case $hostname {
   /^j(ack|ill)$/:   { include hill    } # apply the hill class
   /^[hd]umpty$/:    { include wall    } # apply the wall class
   default:          { include generic } # apply the generic class
}

# Phrase: operating sstem
#======================================================================
$owner = $operatingsystem ? {
   /(redhat|debian)/   => 'bin',
   default => undef,
}

# Phrase: appent to array
#======================================================================
$ssh_users = [ 'myself', 'someone' ]

class test {
  $ssh_users += ['someone_else']
}

# Phrase: define
#======================================================================
define svn_repo($path) {
   exec {"create_repo_${name}":
       command => "/usr/bin/svnadmin create $path/$title",
       unless => "/bin/test -d $path",
   }
   if $require {
       Exec["create_repo_${name}"]{
           require +> $require,
       }
   }
}

# Phrase: class
#======================================================================
class unix {
   file {
       '/etc/passwd':
           owner => 'root',
           group => 'root',
           mode  => 644;
       '/etc/shadow':
           owner => 'root',
           group => 'root',
           mode  => 440;
   }
}

# inherits
class freebsd inherits unix {
  File['/etc/passwd'] { group => 'wheel' }
  File['/etc/shadow'] { group => 'wheel' }
}
# undef when inherits
class freebsd inherits unix {
  File['/etc/passwd'] { group => undef }
}
class apache-ssl inherits apache {
  # host certificate is required for SSL to function
  Service['apache'] { require +> File['apache.pem'] }
}
# Phrase: file sshdconfig
#======================================================================
service { 'sshd':
   subscribe => File[sshdconfig],
}

file { 'sshdconfig':
   name => $operatingsystem ? {
       solaris => '/usr/local/etc/ssh/sshd_config',
       default => '/etc/ssh/sshd_config',
   },
   owner => root,
   group => root,
   mode  => 644,
}

# Phrase: file
#======================================================================
file { '/etc/passwd':
   owner => root,
   group => root,
   mode  => 644,
}

# Phrase: keepalived
#======================================================================
class keepalived {
  package { "adsys-keepalived":
    ensure => installed
  }
  File {
    owner => root, group => root, mode => 644, ensure => present,
    require => Package["adsys-keepalived"]
  }
  file {
    "/etc/keepalived/conf":
      ensure => "directory";
    "/etc/keepalived/conf/vrrp.conf":
      source => "puppet:///modules/keepalived/${adsys_role}/vrrp.conf.${hostname}";
    "/etc/keepalived/conf/check.conf":
      source => "puppet:///modules/keepalived/${adsys_role}/check.conf";
    "/etc/keepalived/conf/check":
      source => "puppet:///modules/keepalived/${adsys_role}/check",
      recurse => true;
  }
  service {
    [ "keepalived-vrrp", "keepalived-check" ]:
      enable => true,
      require => Package["adsys-keepalived"];
  }
}

# Phrase: cron_job example
#======================================================================
class cron_job::mb_direct {
  Cron_job { src_dir_uri => "puppet:///modules/cron_job/tracking" }
  cron_job {
    'logrotate_lighttpd.sh':             minute => 0;
    'logrm_lighttpd.sh':      hour => 4, minute => 0;
  }  
}


