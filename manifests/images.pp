define pxe::images ($os,$ver,$arch,$baseurl='') {
  $tftp_root = $::pxe::tftp_root
  pxe::images::resources { "$os $ver $arch": 
    os   => $os,
    ver  => $ver,
    arch => $arch;
  }

  File <| title == "$tftp_root/images" |>
  File <| title == "$tftp_root/images/$os" |>
  File <| title == "$tftp_root/images/$os/$ver" |>
  File <| title == "$tftp_root/images/$os/$ver/$arch" |>

  case $os {
    debian,ubuntu: {
      pxe::images::debian {
        "$os $ver $arch":
          arch    => "$arch",
          ver     => "$ver",
          os      => "$os",
          baseurl => $baseurl ? {
            ''      => undef,
            default => $baseurl
          };
      }
    }
    centos: {
      pxe::images::centos {
        "$os $ver $arch":
          arch    => "$arch",
          ver     => "$ver",
          os      => "$os",
          baseurl => $baseurl ? {
            ''      => undef,
            default => $baseurl
          };
      }
    }
    redhat: {
      pxe::images::redhat {
        "$os $ver $arch":
          arch    => "$arch",
          ver     => "$ver",
          os      => "$os",
          baseurl => $baseurl ? {
            ''      => undef,
            default => $baseurl
          };
      }
    }

    default: { err ("images for $os not configured") }
  }
}

