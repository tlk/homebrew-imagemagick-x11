# Homebrew ImageMagick with X11 support

This is a macOS [Homebrew](https://brew.sh) [tap](https://docs.brew.sh/Taps) for ImageMagick with X11 support. It  is updated [weekly](.github/workflows/weekly-update.yml) (see [Github Actions](https://github.com/features/actions)) and tracks the regular ImageMagick formula but with X11 support enabled.

## How do I install this?
```
brew uninstall imagemagick  # without x11 support
brew cask install xquartz
brew install tlk/imagemagick-x11/imagemagick
```

## Verify that it works
```
# Start X11
open /Applications/Utilities/XQuartz.app

# Show the ImageMagick wizard in a window
display wizard:
```

## Background
* https://github.com/Homebrew/homebrew-core/issues/49082
* https://imagemagick.org/discourse-server/viewtopic.php?f=3&t=37386
* https://stackoverflow.com/a/59720020/936466
