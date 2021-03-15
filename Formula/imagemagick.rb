class Imagemagick < Formula
  desc "Tools and libraries to manipulate images in many formats (X11 support)"
  homepage "https://www.imagemagick.org/"
  url "https://dl.bintray.com/homebrew/mirror/ImageMagick-7.0.11-3.tar.xz"
  mirror "https://www.imagemagick.org/download/releases/ImageMagick-7.0.11-3.tar.xz"
  sha256 "3a970d1afd5e8fa08754ee8e097af4b7b088e6cd17cf55f1d3a9999d20018bc5"
  license "ImageMagick"
  head "https://github.com/ImageMagick/ImageMagick.git"

  livecheck do
    url "https://download.imagemagick.org/ImageMagick/download/"
    regex(/href=.*?ImageMagick[._-]v?(\d+(?:\.\d+)+-\d+)\.t/i)
  end


  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "ghostscript"
  depends_on "jpeg"
  depends_on "libheif"
  depends_on "liblqr"
  depends_on "libomp"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libtool"
  depends_on "little-cms2"
  depends_on "openexr"
  depends_on "openjpeg"
  depends_on "webp"
  depends_on "xz"

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  depends_on "libx11"
  depends_on "graphviz" => :optional

  skip_clean :la


  # experimental patch, see details at the bottom of this file
  patch :DATA

  # Alternative to the patch. Adding these dependencies allows the project to
  # build but the `display wizard` segfaults.
  #
  # depends_on "libxext"
  # depends_on "libsm"
  # depends_on "libxt"


  def install
    # Avoid references to shim
    inreplace Dir["**/*-config.in"], "@PKG_CONFIG@", Formula["pkg-config"].opt_bin/"pkg-config"


    # Add a symlink that points to the X11 include files provided by XQuartz.
    # This prevents the `display wizard` command from segfaulting.
    ln_s "/opt/X11/include/X11", "#{buildpath}/X11"


    # Adding -I/opt/X11/include and -L/opt/X11/lib via compiler flags is blocked
    # by the HOMEBREW_CCCFG=Osa setting. (=sa works, maybe)
    #
    # See the following for details:
    #   https://github.com/Homebrew/brew/blob/master/Library/Homebrew/extend/ENV/super.rb#L83-L88
    #   https://github.com/Homebrew/brew/blob/master/Library/Homebrew/shims/super/cc#L36
    #   https://github.com/Homebrew/brew/blob/master/Library/Homebrew/shims/super/cc#L108
    #   https://github.com/Homebrew/brew/blob/master/Library/Homebrew/shims/super/cc#L140
    #   https://github.com/Homebrew/brew/blob/master/Library/Homebrew/shims/super/cc#L171       <-- refurbish_arg,
    #   https://github.com/Homebrew/brew/blob/master/Library/Homebrew/shims/super/cc#L252-L254      /opt/X11 is being filtered out
    #   https://github.com/Homebrew/brew/blob/master/Library/Homebrew/shims/super/cc#L270
    #   https://github.com/Homebrew/brew/blob/master/Library/Homebrew/shims/super/cc#L357

    # Consider appending /opt/X11/lib/pkgconfig to PKG_CONFIG_PATH and/or
    # adding a symlink to /opt/X11/lib during build instead of depending on
    # libx11/xorgproto.

    # See also the "x11" method that was removed from brew recently:
    # (Library/Homebrew/extend/os/mac/extend/ENV/std.rb)
    # https://github.com/Homebrew/brew/commit/87dd13aea6691e9d5e0f3ba8d1d1f862a809212a#diff-ed4c0c77ea1a192666ae8a1758389fb65054649d71e0e39e14ee08e919fdb2b3L13-L34


    args = %W[
      --enable-osx-universal-binary=no
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-opencl
      --enable-shared
      --enable-static
      --with-freetype=yes
      --with-modules
      --with-openjp2
      --with-openexr
      --with-webp=yes
      --with-heic=yes
      --with-gslib
      --with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts
      --with-lqr
      --without-fftw
      --without-pango
      --without-wmf
      --enable-openmp
      ac_cv_prog_c_openmp=-Xpreprocessor\ -fopenmp
      ac_cv_prog_cxx_openmp=-Xpreprocessor\ -fopenmp
      LDFLAGS=-lomp\ -lz
    ]

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_BASE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[Modules freetype jpeg png tiff].each do |feature|
      assert_match feature, features
    end
    assert_match "Helvetica", shell_output("#{bin}/identify -list font")
  end
end


# *EXPERIMENTAL PATCH*
#
# The ImageMagick configure script runs a number of compiler tests to check
# for the existence of libraries such as libxext and libxt (-lXext -lXt).
#
# When the configure script is checking for XShmAttach in -lXext it does so
# by testing that -lXext is present but without testing if
# X11/extensions/XShm.h can be included.
#
# This check enables MAGICKCORE_HAVE_SHARED_MEMORY
# This causes MagickCore/xwindow.c to include X11/extensions/XShm.h
# This causes the `make install` step to fail
#
# As an experiment, the configure script is patched to test if
# X11/extensions/XShm.h can be included.

__END__
diff --git a/configure b/configure
index 662e288..4b4bc59 100755
--- a/configure
+++ b/configure
@@ -27835,6 +27835,8 @@ LIBS="-lICE $X_EXTRA_LIBS $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */

+#include <X11/ICE/ICElib.h>
+
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
@@ -27931,6 +27933,8 @@ LIBS="-lXext  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
+#include <X11/extensions/XShm.h>
+
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
@@ -27978,6 +27982,8 @@ LIBS="-lXext  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
+#include <X11/extensions/shape.h>
+
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
@@ -28020,6 +28026,8 @@ LIBS="-lXt  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
+#include <X11/Intrinsic.h>
+
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
