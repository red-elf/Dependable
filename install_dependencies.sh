#!/bin/bash

HERE="$(pwd)"
DEPENDENCIES="Dependencies"
DIR_HOME=$(eval echo ~"$USER")
FILE_ZSH_RC="$DIR_HOME/.zshrc"
FILE_BASH_RC="$DIR_HOME/.bashrc"

FILE_RC=""
    
if test -e "$FILE_ZSH_RC"; then

  FILE_RC="$FILE_ZSH_RC"

else

    if test -e "$FILE_BASH_RC"; then

      FILE_RC="$FILE_BASH_RC"

    else

      echo "ERROR: No '$FILE_ZSH_RC' or '$FILE_BASH_RC' found on the system"
      exit 1
    fi
fi

# shellcheck disable=SC1090
. "$FILE_RC" >/dev/null 2>&1

if [ -z "$SUBMODULES_HOME" ]; then

  echo "ERROR: The SUBMODULES_HOME is not defined"
  exit 1
fi

if [ -z "$DEPENDABLE_DEPENDENCIES_HOME" ]; then

  DEPENDABLE_DEPENDENCIES_HOME="$(pwd)"
  export DEPENDABLE_DEPENDENCIES_HOME
fi

INSTALL_SCRIPT="$SUBMODULES_HOME/Installable/install.sh"
CURRENT_SCRIPT="$SUBMODULES_HOME/Versionable/current.sh"
INSTALLED_SCRIPT="$SUBMODULES_HOME/Versionable/installed.sh"
UPSTREAMS_SCRIPT="$SUBMODULES_HOME/Upstreamable/install_upstreams.sh"

if ! test -e "$INSTALL_SCRIPT"; then

    echo "ERROR: Script not found '$INSTALL_SCRIPT'"
    exit 1
fi

if ! test -e "$CURRENT_SCRIPT"; then

    echo "ERROR: Script not found '$CURRENT_SCRIPT'"
    exit 1
fi

if ! test -e "$INSTALLED_SCRIPT"; then

    echo "ERROR: Script not found '$INSTALLED_SCRIPT'"
    exit 1
fi

if ! test -e "$UPSTREAMS_SCRIPT"; then

    echo "ERROR: Script not found '$UPSTREAMS_SCRIPT'"
    exit 1
fi

echo "The dependencies home directory: '$DEPENDABLE_DEPENDENCIES_HOME'"

DEPENDENCIES_WORKING_DIRECTORY="$DEPENDABLE_DEPENDENCIES_HOME/_Dependencies"
DEPENDENCIES_PROCESSED="$DEPENDENCIES_WORKING_DIRECTORY/processed_dependencies.txt"

GET_VERSIONS() {

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

UNSET_DEPENDABLE_VARIABLES() {

  unset DEPENDABLE_TAG
  unset DEPENDABLE_BRANCH
  unset DEPENDABLE_REPOSITORY

  if [ -n "$DEPENDABLE_TAG" ]; then

    echo "ERROR: The DEPENDABLE_TAG environment variable is still set"
    exit 1
  fi

  if [ -n "$DEPENDABLE_BRANCH" ]; then

    echo "ERROR: The DEPENDABLE_BRANCH environment variable is still set"
    exit 1
  fi

  if [ -n "$DEPENDABLE_REPOSITORY" ]; then

    echo "ERROR: The DEPENDABLE_REPOSITORY environment variable is still set"
    exit 1
  fi
}

FORMAT_DEPENDENCY() {

  REPO="$1"
  BRANCH="$2"
  TAG=$3

  FORMATTED_DEPENDENCY="repo:$REPO/branch:$BRANCH/tag:$TAG"
  echo "Formatted dependency: $FORMATTED_DEPENDENCY"
  export FORMATTED_DEPENDENCY
}

if ! test -e "$DEPENDENCIES_PROCESSED"; then

  DEPENDABLE_PARENT_REPOSITORY="$(git config --get remote.origin.url)"
  DEPENDABLE_PARENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  DEPENDABLE_PARENT_TAG="$(git describe --tags --abbrev=0)"

  FORMAT_DEPENDENCY "$DEPENDABLE_PARENT_REPOSITORY" "$DEPENDABLE_PARENT_BRANCH" "$DEPENDABLE_PARENT_TAG"

  if ! test -e "$DEPENDENCIES_PROCESSED"; then

    mkdir -p "$DEPENDENCIES_WORKING_DIRECTORY" && touch "$DEPENDENCIES_PROCESSED"
  fi

  if ! test -e "$DEPENDENCIES_PROCESSED"; then

    echo "ERROR: '$DEPENDENCIES_PROCESSED' does not exist"
    exit 1
  fi

  echo "$FORMATTED_DEPENDENCY" >"$DEPENDENCIES_PROCESSED"
fi

if test -e "$DEPENDENCIES"; then

  echo "Installing the dependencies"
  
  for i in "$DEPENDENCIES"/*.sh; do

    UNSET_DEPENDABLE_VARIABLES

    if test -e "$i"; then

      # shellcheck disable=SC1090
      . "$i"

    else

      echo "WARNING: No dependencies defined at '$(pwd)'"
      exit 0
    fi

    echo "Dependency: '$i'"
    echo "Dependency tag: $DEPENDABLE_TAG"
    echo "Dependency branch: $DEPENDABLE_BRANCH"
    echo "Dependency repository: $DEPENDABLE_REPOSITORY"

    REPO="$DEPENDABLE_REPOSITORY"

    NAME=$(echo "$REPO" | sed 's:.*/::' | grep -o -P '(?<=).*(?=.git)')
    
    if [ "$NAME" = "" ]; then

        NAME=$(echo "$REPO" | sed 's:.*/::' | grep -o -P '(?<=/).*(?=)')
    fi

    if [ "$NAME" = "" ]; then

        NAME=$(echo "$REPO" | grep -o -P '(?<=https:/).*' | sed 's:.*/::')
    fi

    if [ "$NAME" = "" ]; then

        echo "ERROR: No name obtained for repo '$REPO'"
        exit 1
    fi

    DEPENDABLE_WORKING_DIRECTORY="Cache/$NAME"

    echo "Dependency working directory: $DEPENDABLE_WORKING_DIRECTORY"

    WORKING_DIRECTORY="$DEPENDENCIES_WORKING_DIRECTORY/$DEPENDABLE_WORKING_DIRECTORY"
    if ! test -e "$WORKING_DIRECTORY"; then

      CLONE=true

      FORMAT_DEPENDENCY "$DEPENDABLE_REPOSITORY" "$DEPENDABLE_BRANCH" "$DEPENDABLE_TAG"

      # shellcheck disable=SC2002
      if cat "$DEPENDENCIES_PROCESSED" | grep "$FORMATTED_DEPENDENCY"; then

        CLONE=false

      else

        echo "$FORMATTED_DEPENDENCY" >>"$DEPENDENCIES_PROCESSED"
      fi

      if [ "$CLONE" == true ]; then

        echo "Initializing the dependency to: '$WORKING_DIRECTORY'"

        if mkdir -p "$WORKING_DIRECTORY" && cd "$WORKING_DIRECTORY" &&
          git clone --recurse-submodules "$DEPENDABLE_REPOSITORY" .; then

          if [ -n "$DEPENDABLE_BRANCH" ]; then

            echo "We are about to checkout the branch: '$DEPENDABLE_BRANCH'"
            if ! git checkout "$DEPENDABLE_BRANCH"; then

              echo "ERROR: Could not checkout the branch: '$DEPENDABLE_BRANCH'"
              exit 1
            fi
          else

            if ! git checkout main; then
              if ! git checkout master; then

                echo "ERROR: Failed to checkout the main branch before checking out the tag: '$DEPENDABLE_TAG'"
                exit 1;
              fi
            fi

            if [ -n "$DEPENDABLE_TAG" ]; then

              echo "We are about to checkout the tag: '$DEPENDABLE_TAG'"
              if ! git checkout "$DEPENDABLE_TAG"; then

                echo "ERROR: Could not checkout the tag: '$DEPENDABLE_TAG'"
                exit 1
              fi
            fi
          fi

          GET_VERSIONS

          echo "Current: '$CURRENT'"
          echo "Installed: "
          echo "$INSTALLED"

          IFS='
          '
          for ITEM in $INSTALLED; do

            if [ "$ITEM" = "$CURRENT" ]; then

              cd "$HERE" && \
                echo "The '$ITEM' is already installed, version: $CURRENT"
            else

              if test -e "$UPSTREAMS_SCRIPT"; then

                if test -e "Upstreams"; then

                  if sh "$UPSTREAMS_SCRIPT"; then

                    echo "Upstreamable completed"

                  else

                    echo "ERROR: Upstreamable failed"
                    exit 1
                  fi
                fi
              fi

              if sh "$INSTALL_SCRIPT"; then

                cd "$HERE" && \
                  echo "The dependency initialized to: '$WORKING_DIRECTORY'"

              else

                echo "ERROR: The dependency was NOT initialized to: '$WORKING_DIRECTORY'"
                exit 1
              fi
            fi
          done
        else

          echo "ERROR: Could not initialize the dependency to '$WORKING_DIRECTORY'"
          exit 1
        fi

      else

        echo "WARNING: The repository will not be cloned to avoid the circular dependency issue"
      fi

    else

      echo "The dependency ALREADY initialized to: '$WORKING_DIRECTORY'"

      if [ -z "$DEPENDABLE_TAG" ]; then

        if cd "$WORKING_DIRECTORY" && git fetch && git pull && git submodule init && git submodule update; then

            GET_VERSIONS

            echo "Current: '$CURRENT'"
            echo "Installed:"
            echo "$INSTALLED"

            if [[ "$INSTALLED" == *"$CURRENT"* ]] && ! [[ "$CURRENT" == *"-SNAPSHOT"* ]] ; then

              cd "$HERE" && \
                echo "The '$i' is already installed, version: $CURRENT"

            else

              echo "Updating..."

              if test -e "$UPSTREAMS_SCRIPT"; then

                if test -e "Upstreams"; then

                  if sh "$UPSTREAMS_SCRIPT"; then

                    echo "Upstreamable completed"

                  else

                    echo "ERROR: Upstreamable failed"
                    exit 1
                  fi
                fi
              fi

              if sh "$INSTALL_SCRIPT"; then

                cd "$HERE" && \
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

      else

        echo "We are on the tag: '$DEPENDABLE_TAG'"
      fi
    fi
  done
else

  echo "No dependencies to process"
fi
