# Class: freight
#
# This class installs and configures a local APT repo using freight
#
# Parameters:
# - The $freight_docroot chooses a docroot to serve the repo out of
#     (used for the vhost and for freight config)
# - The $freight_gpgkey is the gpg key used to sign the repository
# - The $freight_libdir is where the freight stores the debs, before
#     hard-linking them into the vhost docroot
#
# Actions:
# - Install appropriate apache vhost for freight instance
# - Add rcrowley's repository key so freight can be apt-installed
# - Install, configure and setup freight instance
# - Installs gpg-agent for signing packages
#
# Requires:
# - The apache class and vhost definition
#
# Sample Usage:
#   class { 'freight':
#     freight_docroot     => '/var/www/html',
#     freight_gpgkey      => 'me@somewhere.com',
#     freight_libdir      => '/var/lib/freight',
#   }
#
class freight ($freight_docroot, $freight_gpgkey, $freight_libdir) {
  include apache

  package { 'freight':
    ensure  => present,
    require => Apt::Source["rcrowley.list"],
  }

  package { 'gnupg-agent':
    ensure  => present,
  }

  file { [$freight_docroot, $freight_libdir]:
    ensure    => directory,
    group     => "enterprise",
    require   => Group["enterprise"],
  }

  file { '/etc/freight.conf':
    ensure => present,
    content => template('freight/freight.conf.erb'),
    require => Package['freight'],
  }

  apache::vhost { 'freight.puppetlabs.lan':
    priority => '10',
    port => '80',
    docroot => $freight_docroot,
    template => 'freight/apache2.conf.erb',
    require => File[$freight_docroot],
  }

  apt::source { "rcrowley.list":
    uri           => "http://packages.rcrowley.org/",
    require       => Exec["rcrowley_key"],
  }

  exec { "import rcrowley apt key":
    user    => root,
    alias   => "rcrowley_key",
    command => "/usr/bin/wget -q -O - http://packages.rcrowley.org/pubkey.gpg | apt-key add -",
    unless  => "/usr/bin/apt-key list | grep -q 7DF49CEF",
    before  => Exec["apt-get update"];
  }

  exec { "start gpg-agent":
    user      => root,
    alias     => "gpg-exec",
    command   => "/bin/bash -c 'eval \$(gpg-agent --daemon)'",
    unless    => "/usr/bin/pgrep -u root gpg-agent",
    require   => Package["gnupg-agent"],
  }
}

