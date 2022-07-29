#!/bin/bash

ABOUT="ABOUT.txt"
DEPENDENCIES="Dependencies"
DEPENDENCIES_WORKING_DIRECTORY="_Dependencies"

INSTALL_SCRIPT="Installable/install.sh"
CURRENT_SCRIPT="Versionable/current.sh"
INSTALLED_SCRIPT="Versionable/installed.sh"

function GET_VERSIONS {

  if ! test -e "$CURRENT_SCRIPT"; then

    echo "ERROR: '$CURRENT_SCRIPT' not found at: $(pwd)"
    exit 1
  fi

  if ! test -e "$INSTALLED_SCRIPT"; then

    echo "ERROR: '$INSTALLED_SCRIPT' not found at: $(pwd)"
    exit 1
  fi

  CURRENT="$(sh "$CURRENT_SCRIPT")"
  INSTALLED="$(sh "$INSTALLED_SCRIPT")"
}

if test -e "$ABOUT"; then

  cat "$ABOUT"
  echo "Dependencies installation started"
fi

if test -e "$DEPENDENCIES"; then

  echo "Installing the dependencies"
  for i in "$DEPENDENCIES"/*.sh; do

    # shellcheck disable=SC1090
    . "$i"
    echo "Dependency: '$i'"
    echo "Dependency tag: $DEPENDABLE_TAG"
    echo "Dependency branch: $DEPENDABLE_BRANCH"
    echo "Dependency repository: $DEPENDABLE_REPOSITORY"

    TO_REPLACE="${i%.*}"
    DEPENDABLE_WORKING_DIRECTORY="${TO_REPLACE//"$DEPENDENCIES"/Cache}"
    echo "Dependency working directory: $DEPENDABLE_WORKING_DIRECTORY"

    WORKING_DIRECTORY="$DEPENDENCIES_WORKING_DIRECTORY/$DEPENDABLE_WORKING_DIRECTORY"
    if ! test -e "$WORKING_DIRECTORY"; then

      echo "Initializing the dependency to: '$WORKING_DIRECTORY'"

      if mkdir -p "$WORKING_DIRECTORY" && cd "$WORKING_DIRECTORY" &&
        git clone --recurse-submodules "$DEPENDABLE_REPOSITORY" .; then

        GET_VERSIONS

        echo "Current: '$CURRENT'"
        echo "Installed: '$INSTALLED'"

        if [[ "$INSTALLED" == "$CURRENT" ]]; then

          echo "The '$i' is already installed, version: $CURRENT"
        else

          if sh "$INSTALL_SCRIPT"; then

            echo "The dependency initialized to: '$WORKING_DIRECTORY'"
          else

            echo "ERROR: The dependency was NOT initialized to: '$WORKING_DIRECTORY'"
          fi
        fi
      else

        echo "ERROR: Could not initialize the dependency to '$WORKING_DIRECTORY'"
        exit 1
      fi

    else

      echo "The dependency ALREADY initialized to: '$WORKING_DIRECTORY'"

      if cd "$WORKING_DIRECTORY" && git fetch && git pull && git submodule init && git submodule update; then

        GET_VERSIONS

        echo "Current: '$CURRENT'"
        echo "Installed: '$INSTALLED'"

        if [[ "$INSTALLED" == "$CURRENT" ]]; then

          echo "The '$i' is already installed, version: $CURRENT"

        else

          echo "Updating..."

          if sh "$INSTALL_SCRIPT"; then

            echo "The dependency at '$WORKING_DIRECTORY' has been updated"
          else

            echo "ERROR: The dependency at '$WORKING_DIRECTORY' has NOT been updated"
          fi
        fi

      else

        echo "ERROR: Could not update the dependency at '$WORKING_DIRECTORY'"
        exit 1
      fi
    fi
  done
else

  echo "ERROR: '$DEPENDENCIES' installation directory does not exist"
  exit 1
fi
