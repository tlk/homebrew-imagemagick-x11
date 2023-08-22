#!/bin/bash

SOURCEHISTORY=https://github.com/Homebrew/homebrew-core/commits/master/Formula/i/imagemagick.rb
SOURCE=https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/i/imagemagick.rb
FORMULA=Formula/imagemagick.rb
PATCHFILE=Patch/imagemagick-x11.patch

fetch_upstream() {
    wget -q -O - $SOURCE > $FORMULA
}

update_description() {
    exp='s/manipulate images in many formats"/manipulate images in many formats (X11 support)"/g'
    mv $FORMULA ${FORMULA}.tmp
    sed "$exp" ${FORMULA}.tmp > $FORMULA
}

remove_bottle() {
    exp='/  bottle do/,/  end/d'
    mv $FORMULA ${FORMULA}.tmp
    sed "$exp" ${FORMULA}.tmp > $FORMULA
}

apply_patch() {
    patch $FORMULA $PATCHFILE
}

git_commit_formula() {
    git diff --exit-code $FORMULA

    if [ $? -eq 0 ]; then
        echo "Nothing to commit. This is okay."
        exit 0
    fi

    echo ""
    echo "Committing formula"

    git commit \
        -m "Merge upstream" \
        -m "" \
        -m "Source $SOURCE" \
        $FORMULA
}

manual_patch_update0() {
    echo "Running --fetch-upstream, --update-description and --remove-bottle"
    fetch_upstream
    update_description
    remove_bottle
    echo ""
    echo "Sometimes the upstream formula changes in a way so the patch file no longer applies and must be updated."
    echo ""
    echo "How to update the patch file manually:"
    echo "  1. bin/patchtool.sh --manual-patch-update-1   # this makes an interrim commit"
    echo "  2. update $FORMULA manually"
    echo "  3. bin/patchtool.sh --manual-patch-update-2   # commit patch file and formula"
    echo "  4. git push origin master"
}

manual_patch_update1() {
    msg="Interrim: Merge upstream but without X11 patch"
    git commit -m "$msg" $FORMULA
}

manual_patch_update2() {
    msg="Update patch for $SOURCEHISTORY"
    git diff $FORMULA > $PATCHFILE
    git commit -m "$msg" $PATCHFILE

    git_commit_formula
}

case $1 in
    "--fetch-upstream")
        fetch_upstream
        ;;

    "--update-description")
        update_description
        ;;

    "--remove-bottle")
        remove_bottle
        ;;

    "--apply-patch")
        apply_patch
        ;;

    "--git-commit-formula")
        git_commit_formula
        ;;

    "--manual-patch-update-1")
        manual_patch_update1
        ;;

    "--manual-patch-update-2")
        manual_patch_update2
        ;;

    *)
        manual_patch_update0
        ;;
esac
