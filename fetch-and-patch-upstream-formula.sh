#!/bin/sh

set -e

FORMULA=Formula/imagemagick.rb

wget -q -O - https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/imagemagick.rb \
    | sed 's/manipulate images in many formats"/manipulate images in many formats (X11 support)"/g' \
    | sed '/  bottle do/,/  end/d' \
    > $FORMULA

patch $FORMULA imagemagick-x11.patch

git commit \
    -m "Merge upstream" \
    -m "" \
    -m "Source https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/imagemagick.rb" \
    $FORMULA

