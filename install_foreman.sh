#!/bin/bash
#
# Description:  Runs the foreman installer as a separate process so we don't
#               have to worry about a nonzero exit status (which we don't care
#               about most of the time).
#

/usr/sbin/foreman-installer
exit 0
