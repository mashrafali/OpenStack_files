# == Class: contrail::analytics::install
#
# Install the analytics service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for analytics
#
class contrail::analytics::install (
  $contrail_version = 4,
) {
  if $contrail_version == 3 {
    package { 'python-redis' :
      ensure => absent,
      before => Package['python-gevent'],
    }
  }
  package { 'python-gevent' :
    ensure => latest,
  } ->
  package { 'contrail-openstack-analytics' :
    ensure => latest,
  } ->
  package { 'contrail-docs' :
    ensure => latest,
  }
}
