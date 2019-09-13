#!/usr/bin/env bash

package_upgrade() {
  local REPO_NAME="$1"
  shift

  local ORG_NAME="$(echo "${REPO_NAME}" | sed -E 's|^(.+)/(.+)$|\1|g')"
  local PROJECT_NAME="$(echo "${REPO_NAME}" | sed -E 's|^(.+)/(.+)$|\2|g')"

  rm -fR "${PROJECT_NAME}"

  if [ ! -d "${PROJECT_NAME}" ]; then
    if git clone "git@github.com:${REPO_NAME}.git" "${PROJECT_NAME}"; then
      echo "Successfully cloned ${REPO_NAME}"
    else
      exit 1
    fi
  fi

  local PROJECT_DIR="${PROJECT_NAME}"

  (
    cd "${PROJECT_DIR}"
    echo "[upgrade] $(basename "${PROJECT_DIR}") (in ${PROJECT_DIR})"
    asdf local nodejs 12.10.0
    asdf local yarn 1.17.3
    ([ -f .circleci/config.yml ] && sed -i'' -E 's_/nodejs(:|@).+$_/nodejs\112.10.0_g' .circleci/config.yml)
    rm -f yarn.lock package-lock.json
    yarn install
    yarn outdated --json | node ../yarn-upgrade.js
    npm install
    (grep --quiet '"lint":' package.json && yarn lint)
    (grep --quiet '"build":' package.json && yarn build)
    (grep --quiet '"documentation":' package.json && yarn documentation)
    (grep --quiet '"test":' package.json && yarn test)
    git add .
    git diff --cached -w
    printf '💡 Should I commit these changes? (y/N) '
    read OK_TO_COMMIT
    if [ "${OK_TO_COMMIT}" = 'y' ]; then
      git commit -m "📦 Upgrade dependencies to their latest versions"

      grep -E '^  "version": ".+",' package.json | head -1
      printf '🏁 Next version: '
      read NEXT_VERSION
      if [ -n "${NEXT_VERSION}" ]; then
        sed -i'' -E "s|^  \"version\": \"(.+)\",|  \"version\": \"${NEXT_VERSION}\",|g" package.json
        npm install
        git diff package.json
        git status
        printf '💡 Should I commit these changes? (y/N) '
        read OK_TO_COMMIT_VERSION
        if [ "${OK_TO_COMMIT_VERSION}" = 'y' ]; then
          git add package.json package-lock.json
          git commit -m "🏁 v${NEXT_VERSION} Release"
        fi
      fi

      git push
    fi
  )
  rm -fR "${PROJECT_DIR}"
}

for REPO_NAME in $*; do
  package_upgrade "${REPO_NAME}"
done
