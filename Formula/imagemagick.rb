class Imagemagick < Formula
  desc "Tools and libraries to manipulate images in many formats (X11 support)"
  homepage "https://www.imagemagick.org/"
  url "https://dl.bintray.com/homebrew/mirror/ImageMagick-7.0.10-57.tar.xz"
  mirror "https://www.imagemagick.org/download/releases/ImageMagick-7.0.10-57.tar.xz"
  sha256 "5018d15f12963bd6d86c8a667fba2795ec818a71612b6064f84a0c29a545af21"
  license "ImageMagick"
  head "https://github.com/ImageMagick/ImageMagick.git"

  livecheck do
    url "https://www.imagemagick.org/download/"
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

  skip_clean :la

  #
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
  # As an experiment, the configure script is patched to test for the existence
  # of X11/extensions/XShm.h (see the bottom of this file).
  #
  # In addition, the configure script is patched to align with a vanilla build
  # of ImageMagick.
  #
  # These patches allows the project to build but the `display wizard`
  # segfaults.
  #
  patch :DATA


  # Alternative to the patches. Adding these dependencies allows the project to
  # build but the `display wizard` segfaults.
  #
  # depends_on "libxext"
  # depends_on "libsm"
  # depends_on "libxt"


  def install
    # Avoid references to shim
    inreplace Dir["**/*-config.in"], "@PKG_CONFIG@", Formula["pkg-config"].opt_bin/"pkg-config"

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
