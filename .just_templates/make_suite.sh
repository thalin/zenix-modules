#!/usr/bin/env bash

suite_DIR="modules/nixos/suites"

suite_name=$1

if [ -f ${suite_DIR}/${suite_name}.nix ]; then
  echo "suite ${suite_name} already exists."
  exit
fi

cp .just_templates/suite_template.nix ${suite_DIR}/${suite_name}.nix
sed -i -e "s/suite_NAME/${suite_name}/" ${suite_DIR}/${suite_name}.nix
