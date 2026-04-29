#!/bin/bash

SOURCEHISTORY=https://github.com/Homebrew/homebrew-core/commits/main/Formula/i/imagemagick-full.rb
SOURCE=https://raw.githubusercontent.com/Homebrew/homebrew-core/main/Formula/i/imagemagick-full.rb
FORMULA=Formula/imagemagick.rb
PATCHFILE=Patch/imagemagick-x11.patch

fetch_upstream() {
    curl --silent --output $FORMULA $SOURCE
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

show_how_to_update_patch_file_manually() {
    echo ""
    echo "Sometimes the upstream formula changes in a way such that the patch file must be updated manually."
    echo ""
    echo "How to update the patch file manually:"
    echo "  1. bin/patchtool.sh --fetch-upstream"
    echo "  2. bin/patchtool.sh --remove-bottle"
    echo "  3. git commit -m 'Interrim: Merge upstream but without X11 patch' $FORMULA"
    echo "  4. # manually edit and update $FORMULA"
    echo "  5. bin/patchtool.sh --commit-patch-file-and-formula"
    echo "  6. git push origin master"
}


commit_patch_file_and_formula() {
    msg="Update patch for $SOURCEHISTORY"
    git diff --unified=1 $FORMULA > $PATCHFILE
    git commit -m "$msg" $PATCHFILE

    git_commit_formula
}

case $1 in
    "--fetch-upstream")
        fetch_upstream
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

    "--commit-patch-file-and-formula")
        commit_patch_file_and_formula
        ;;

    *)
        show_how_to_update_patch_file_manually
        ;;
esac
