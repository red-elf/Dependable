#!/bin/bash

ABOUT="ABOUT.txt"
DEPENDENCIES="Dependencies"
DEPENDENCIES_WORKING_DIRECTORY="_Dependencies"

if test -e "$ABOUT"; then

  cat "$ABOUT"
  echo "Dependencies installation started"
fi

if test -e "$DEPENDENCIES"; then

  echo "Installing the dependencies"
  for i in "$DEPENDENCIES"/*.sh; do

      # shellcheck disable=SC1090
      . "$i"
      echo "Dependency: $i"
      echo "Dependency repository: $DEPENDABLE_REPOSITORY"
      echo "Dependency branch: $DEPENDABLE_BRANCH"
      echo "Dependency tag: $DEPENDABLE_TAG"

      if ! test -e "$DEPENDENCIES_WORKING_DIRECTORY"; then

        mkdir "$DEPENDENCIES_WORKING_DIRECTORY"
      fi
  done
else

  echo "ERROR: '$DEPENDENCIES' installation directory does not exist"
  exit 1
fi