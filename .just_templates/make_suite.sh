#!/usr/bin/env bash

SUITE_NAME=$1
SUITE_TYPE=${2:-nixos}

SUITE_DIR="modules/${SUITE_TYPE}/suites"

if [ -f ${SUITE_DIR}/${SUITE_NAME}.nix ]; then
  echo "suite ${SUITE_NAME} already exists."
  exit
fi

cp .just_templates/suite_template.nix ${SUITE_DIR}/${SUITE_NAME}.nix
sed -i -e "s/SUITE_NAME/${SUITE_NAME}/g" ${SUITE_DIR}/${SUITE_NAME}.nix
