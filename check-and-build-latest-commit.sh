#!/bin/bash

set -e -u -x

scriptdir="$(readlink -f "$(dirname "${0}")")"

WORKSPACE="${1}"
BRANCH="${2:-master}"
REPOSITORY="${3:-https://github.com/nextcloud/desktop}"

commit=$(git ls-remote "${REPOSITORY}" "refs/heads/${BRANCH}" |
             awk '{print $1}')

commitfiledir="${scriptdir}/commits"
commitfile="${commitfiledir}/latest-commit-${BRANCH}"
if test -f "${commitfile}"; then
    exists="yes"
else
    exists="no"
fi

if test "${exists}" = "no" -o "${commit}" != "$(cat "${commitfile}")"; then
    mkdir -p "${commitfiledir}"
    echo "${commit}" > "${commitfile}"
    if test "${exists}" = "no"; then
        git -C "${scriptdir}" add "${commitfile}"
    fi
    git -C "${scriptdir}" commit -a -m "Updated latest commit for branch ${BRANCH}"
    git -C "${scriptdir}" push

    "${scriptdir}/debian-build.sh" "${WORKSPACE}" \
                                   "${commit}" "${BRANCH}" "${REPOSITORY}"
fi
