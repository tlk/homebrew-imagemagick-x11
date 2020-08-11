#!/bin/sh

set -e

SOURCE=https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/imagemagick.rb
FORMULA=Formula/imagemagick.rb

wget -q -O - $SOURCE \
    | sed 's/manipulate images in many formats"/manipulate images in many formats (X11 support)"/g' \
    | sed '/  bottle do/,/  end/d' \
    > $FORMULA

patch $FORMULA imagemagick-x11.patch

git commit \
    -m "Merge upstream" \
    -m "" \
    -m "Source $SOURCE" \
    $FORMULA

