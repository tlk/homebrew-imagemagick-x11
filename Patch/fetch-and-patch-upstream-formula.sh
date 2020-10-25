#!/bin/sh

SOURCE=https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/imagemagick.rb
FORMULA=Formula/imagemagick.rb
PATCHFILE=Patch/imagemagick-x11.patch

wget -q -O - $SOURCE \
    | sed 's/manipulate images in many formats"/manipulate images in many formats (X11 support)"/g' \
    | sed '/  bottle do/,/  end/d' \
    > $FORMULA || exit 1

patch $FORMULA $PATCHFILE || exit 2

git diff --exit-code $FORMULA

if [ $? -eq 0 ]; then
    echo "Nothing to commit. This is okay."
    exit 0
fi

echo ""
echo "Committing patched formulae..."

git commit \
    -m "Merge upstream" \
    -m "" \
    -m "Source $SOURCE" \
    $FORMULA || exit 3
