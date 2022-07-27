# Dependable

Define and install project dependencies.

## How to use

- Clone the 'Dependable' in the root of the project as the git submodule under the 'Dependable' directory
- In the root of the project create a directory called 'Dependencies'
- Optional: In the root of the project create the 'ABOUT.txt'
- For each dependency create a separate .sh file with the content that satisfies the required form
- Execute: `sh Dependable/install.sh` from the root of your project

## Dependency sh scripts

Each dependency requires to satisfy the following form:

```shell
#!/bin/bash
REPOSITORY="YOUR_GIT_REPOSITORY_PATH" # Mandatory
BRANCH="YOUR_GIT_BRANCH"              # If edfined the TAG value is not required
TAG="YOUR_GIT_TAG"                    # If edfined the BRANCH value is not required
```
