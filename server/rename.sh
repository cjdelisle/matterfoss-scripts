#!/usr/bin/env bash

# This script is designed to replace all instances of the word Mattermost with
# Matterfoss. Mattermost is a trademark of Mattermost Inc. and this script was
# designed with the intention of avoiding confusion between this Free Software
# project and any commercial product provided Mattermost Inc.

SED=$(command -v gsed || command -v sed)
FIND=$(command -v gfind || command -v find)

update_paths() {
    OLDPATH="github.com/mattermost/mattermost-server"
    NEWPATH="github.com/cjdelisle/matterfoss-server"
    REGEX="s@$OLDPATH@$NEWPATH@g"
    $FIND ./ -name '*.go' -exec $SED -i -e $REGEX {} \;
    $FIND ./ -name '*.go.tmpl' -exec $SED -i -e $REGEX {} \;
    $SED -i -e $REGEX ./go.mod
    rm ./go.sum
}

change_cmd() {
    $FIND ./ -name '*.go' -exec $SED -i -e "s@cmd/mattermost@cmd/matterfoss@g" {} \;
    mv ./cmd/mattermost ./cmd/matterfoss
}

remove_files() {
    rm -rf ./.circleci
    rm -rf ./.github
    rm -f CHANGELOG.md
    rm -f docker-compose.makefile.yml
    rm -f CONTRIBUTING.md
    rm -f README.md
    rm -f SECURITY.md
    rm -f Makefile
    rm -f config.mk
    rm -f config/README.md
    rm -f docker-compose.yaml
    rm -rf ./build
    rm -rf ./doc
    rm -f ./go.tools.mod
    rm -f ./go.tools.sum
    rm -f ./*.yml
    rm -f ./CODEOWNERS ## this seems to be a technical file, not a notice
    rm -f .codecov.yml
    rm -f .gitlab-ci.yml
    rm -f .golangci.yml
}

change_go_files() {
    $FIND ./* -type f -name '*.go' -exec gawk -i inplace '{
        if ($0 ~ "Mattermost") {
            if ($0 ~ "All Rights Reserved") {
                /* This is a copyright notice, leave it alone */
            } else {
                gsub(/Mattermost/, "Matterfoss");
            }
        }
        gsub(/mattermost\.com/, "matterfoss.org");
        gsub(/mattermost\.org/, "matterfoss.org");
        if ($0 !~ "\"github.com/mattermost") {
            /* We want to preserve golang dependencies */
            gsub(/mattermost/, "matterfoss");
        }
        print;
    }' {} \;
}

change_non_go_files() {
    $FIND ./* -type f -exec grep -Iq . {} \; -print | \
        grep -v '\.git/' | \
        grep -v '\.go$' | \
        grep -v '^./\(vendor\|LICENSE\|NOTICE\|go\.\)' | \
        grep -v '.go.tmpl\|/rename.sh' | \
    while read -r x; do
        gawk -i inplace '{
            gsub(/mattermost/, "matterfoss");
            gsub(/Mattermost/, "Matterfoss");
            print;
        }' "$x";
    done
}

rename_scripts() {
    $FIND ./ -type f -name '*mattermost*' | while read -r x; do
        mv "$x" "${x//mattermost/matterfoss}"
    done
}

update_paths
change_cmd
remove_files
change_go_files
change_non_go_files
rename_scripts
