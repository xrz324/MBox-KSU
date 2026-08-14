#!/bin/sh

version=$(awk -F= '$1 == "version" { print $2; exit }' module.prop)
zip -r -o -X -ll "mbox_${version}.zip" \
  module.prop customize.sh uninstall.sh mbox_service.sh box
