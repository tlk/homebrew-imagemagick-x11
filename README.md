# Homebrew ImageMagick with X11 support

This is a macOS [Homebrew](https://brew.sh) [tap](https://docs.brew.sh/Taps) for ImageMagick with X11 support.

It tracks the upstream ImageMagick formula and enables the following:
- X11 support
- Graphviz support

Updated on a [weekly](.github/workflows/weekly-update.yml) basis thanks to [Github Actions](https://github.com/features/actions).

## How do I install this?
```
brew uninstall imagemagick  # without X11 support
brew install --cask xquartz
brew install tlk/imagemagick-x11/imagemagick
```

## Verify that it works
```
display wizard:
display myfile.jpg
```

## Graphviz support
Note that ImageMagick has support for [graphviz DOT-files](https://en.wikipedia.org/wiki/DOT_(graph_description_language)) if the `--with-graphviz` option is used during install:
```
brew uninstall imagemagick
brew install tlk/imagemagick-x11/imagemagick --with-graphviz
display mygraph.dot
convert mygraph.dot mygraph.png
```

## Updated every week
The formula is updated weekly which means that Homebrew will automatically build and install the latest version.

If this is undesirable consider checking out the Homebrew ["pin" feature](https://docs.brew.sh/FAQ#how-do-i-stop-certain-formulae-from-being-updated) or the Homebrew [environment variables](https://docs.brew.sh/Manpage#environment) `HOMEBREW_NO_AUTO_UPDATE` and `HOMEBREW_NO_INSTALL_UPGRADE`.

## Background
* https://github.com/Homebrew/homebrew-core/issues/49082
* https://imagemagick.org/discourse-server/viewtopic.php?f=3&t=37386
* https://stackoverflow.com/a/59720020/936466
