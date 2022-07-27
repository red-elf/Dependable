# Dependable

Define and install project dependencies.

## How to use

- Clone the 'Dependable' in the root of the project as the git submodule under the 'Dependable' directory
- In the root of the project create a directory called 'Dependencies'
- Optional: In the root of the project create the 'ABOUT.txt'
- For each dependency create a separate .sh file with the content that satisfies the required form
- Execute: `sh Dependable/install_dependencies.sh` from the root of your project

## The dependency shell scripts

Each dependency requires to satisfy the following form:

```shell
#!/bin/bash
export DEPENDABLE_REPOSITORY="YOUR_GIT_REPOSITORY_PATH" # Mandatory
export DEPENDABLE_BRANCH="YOUR_GIT_BRANCH"              # If defined the TAG value is not required
export DEPENDABLE_TAG="YOUR_GIT_TAG"                    # If defined the BRANCH value is not required
```
