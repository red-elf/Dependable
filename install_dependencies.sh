#!/bin/bash

ABOUT="ABOUT.txt"
DEPENDENCIES="Dependencies"

if [ -z "$DEPENDABLE_DEPENDENCIES_HOME" ]; then

  DEPENDABLE_DEPENDENCIES_HOME="$(pwd)"
  export DEPENDABLE_DEPENDENCIES_HOME
fi

echo "The dependencies home directory: '$DEPENDABLE_DEPENDENCIES_HOME'"

INSTALL_SCRIPT="Installable/install.sh"
CURRENT_SCRIPT="Versionable/current.sh"
INSTALLED_SCRIPT="Versionable/installed.sh"

DEPENDENCIES_WORKING_DIRECTORY="$DEPENDABLE_DEPENDENCIES_HOME/_Dependencies"

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

      CLONE=true
      if [ -z "$DEPENDABLE_PARENT_REPOSITORY" ]; then

        DEPENDABLE_PARENT_REPOSITORY="$DEPENDABLE_REPOSITORY"
        DEPENDABLE_PARENT_BRANCH="$DEPENDABLE_BRANCH"
        DEPENDABLE_PARENT_TAG="$DEPENDABLE_TAG"

        export DEPENDABLE_PARENT_REPOSITORY
        export DEPENDABLE_PARENT_BRANCH
        export DEPENDABLE_PARENT_TAG

        echo "Parent repository set to: '$DEPENDABLE_PARENT_REPOSITORY'"
        echo "Parent branch set to: '$DEPENDABLE_PARENT_BRANCH'"
        echo "Parent tag set to: '$DEPENDABLE_PARENT_TAG'"

      else

        if [[ "$DEPENDABLE_PARENT_REPOSITORY" == "$DEPENDABLE_REPOSITORY" ]]; then

          CLONE=false

          echo "Parent repository information is available, parent repository is: '$DEPENDABLE_PARENT_REPOSITORY'"

          if [ -z "$DEPENDABLE_PARENT_BRANCH" ]; then

            if [ -n "$DEPENDABLE_PARENT_TAG" ]; then

              if ! [[ "$DEPENDABLE_PARENT_TAG" == "$DEPENDABLE_TAG" ]]; then

                CLONE=true
              fi
            fi
          else

            if ! [[ "$DEPENDABLE_PARENT_BRANCH" == "$DEPENDABLE_BRANCH" ]]]; then

              CLONE=true
            fi
          fi
        fi
      fi

      if "$CLONE" = true; then

        if mkdir -p "$WORKING_DIRECTORY" && cd "$WORKING_DIRECTORY" &&
          git clone --recurse-submodules "$DEPENDABLE_REPOSITORY" .; then

          if [ -n "$DEPENDABLE_BRANCH" ]; then

            if ! git checkout "$DEPENDABLE_BRANCH"; then

              echo "ERROR: Could not checkout the branch: '$DEPENDABLE_BRANCH'"
              exit 1
            fi
          else

            if ! git checkout "$DEPENDABLE_TAG"; then

              echo "ERROR: Could not checkout the tag: '$DEPENDABLE_TAG'"
              exit 1
            fi
          fi

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
              exit 1
            fi
          fi
        else

          echo "ERROR: Could not initialize the dependency to '$WORKING_DIRECTORY'"
          exit 1
        fi

      else

        echo "WARNING: The repository will not be cloned to avoid the circular dependency issue"
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
            exit 1
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
