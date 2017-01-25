#!/bin/sh
#
# Prevent commits to default (master) branch.

# The branch that is to be protected
PROTECTED_BRANCH="master"

# A stub for future (so that hook is enabled for all by default, but
# can be disabled per project config)
allowprotected=$(git config --bool hooks.allowProtectedBranchCommit)

# Redirect all output to stderr
exec 1>&2

CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ "$CURRENT_BRANCH" = "$PROTECTED_BRANCH" ]
then
	cat <<EOF
Error: Attempting to commit to protected branch "$PROTECTED_BRANCH".

A strict policy is enabled for this repo, whereas only merge commits
are allowed and direct commits to master branch are forbidden.
EOF
        exit 1
fi
