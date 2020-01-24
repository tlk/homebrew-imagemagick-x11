# Homebrew ImageMagick with X11 support

This is a macOS [Homebrew tap](https://docs.brew.sh/Taps) for ImageMagick with X11 support.

## How do I install this?
```
brew uninstall imagemagick

brew cask install xquartz
brew tap tlk/imagemagick-x11
brew install tlk/imagemagick-x11/imagemagick
```

## Verify that it works
```
# Start X11
open /Applications/Utilities/XQuartz.app

# Show the ImageMagick wizard in a window
display wizard:
```

## Details about Homebrew
`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).


## Related
* https://github.com/Homebrew/homebrew-core/issues/49082
* https://imagemagick.org/discourse-server/viewtopic.php?f=3&t=37386
* https://stackoverflow.com/a/59720020/936466
