#!/usr/bin/env bash

set -o errexit -o nounset

target="/var/vcap/all-releases/jobs-src/diego/rep/templates/bpm-pre-start.erb"
sentinel="${target}.patch_sentinel"
if [[ -f "${sentinel}" ]]; then
  if sha256sum --check "${sentinel}" ; then
    echo "Patch already applied. Skipping"
    exit 0
  fi
  echo "Sentinel mismatch, re-patching"
fi

# Use the ephemeral data directory for the rootfs.
patch --verbose "${target}" <<'EOT'
@@ -5,3 +5,7 @@
 $bin_dir/set-rep-kernel-params

 $bin_dir/setup_mounted_data_dirs
+
+mkdir -p /var/vcap/data/shared-packages/
+cp -r /var/vcap/packages/healthcheck /var/vcap/data/shared-packages/
+cp -r /var/vcap/packages/proxy /var/vcap/data/shared-packages/
EOT

sha256sum "${target}" > "${sentinel}"
