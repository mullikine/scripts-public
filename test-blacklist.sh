#!/bin/bash
export TTY

filter_by_duplicate_repo_names() {
    filter-out-row-nums "$(get-row-nums-for-repo-duplicates | s join , | s chomp)"
}

filter_through_repo_blacklists() {
    echo "Filtering repositories." 1>&2
    eipct "! xargs -l gh-isarchived" |
        filter_by_duplicate_repo_names
    echo "Done filtering repositories." 1>&2
}

cl-pipeline-query list_projects | filter_through_repo_blacklists
