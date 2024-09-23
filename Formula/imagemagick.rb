class Imagemagick < Formula
  desc "Tools and libraries to manipulate images in many formats (X11 support)"
  homepage "https://imagemagick.org/index.php"
  url "https://imagemagick.org/archive/releases/ImageMagick-7.1.1-38.tar.xz"
  sha256 "48de548d4977fc226c982ca03b9d6ad8001b47d8dc142b49fdca69333bc4ad82"
  license "ImageMagick"
  revision 2
  head "https://github.com/ImageMagick/ImageMagick.git", branch: "main"

  livecheck do
    url "https://imagemagick.org/archive/"
    regex(/href=.*?ImageMagick[._-]v?(\d+(?:\.\d+)+-\d+)\.t/i)
  end


  depends_on "pkg-config" => :build
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "ghostscript"
  depends_on "jpeg-turbo"
  depends_on "jpeg-xl"
  depends_on "libheif"
  depends_on "liblqr"
  depends_on "libpng"
  depends_on "libraw"
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

  on_macos do
    depends_on "gettext"
    depends_on "glib"
    depends_on "imath"
    depends_on "libomp"
  end

  on_linux do
    depends_on "libx11"
  end

  skip_clean :la

  depends_on "libx11"
  depends_on "graphviz" => :optional

  patch :DATA
 
  def install
    # Add a symlink that points to the X11 include files provided by XQuartz.
    # This prevents the `display wizard` command from segfaulting.
    ln_s "/opt/X11/include/X11", "#{buildpath}/X11"

    # Avoid references to shim
    inreplace Dir["**/*-config.in"], "@PKG_CONFIG@", Formula["pkg-config"].opt_bin/"pkg-config"
    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_BASE_VERSION}", "${PACKAGE_NAME}"

    args = [
      "--enable-osx-universal-binary=no",
      "--disable-silent-rules",
      "--disable-opencl",
      "--enable-shared",
      "--enable-static",
      "--with-freetype=yes",
      "--with-modules",
      "--with-openjp2",
      "--with-openexr",
      "--with-webp=yes",
      "--with-heic=yes",
      "--with-raw=yes",
      "--with-gslib",
      "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts",
      "--with-lqr",
      "--without-djvu",
      "--without-fftw",
      "--without-pango",
      "--without-wmf",
      "--enable-openmp",
    ]
    if OS.mac?
      args += [
        # Work around "checking for clang option to support OpenMP... unsupported"
        "ac_cv_prog_c_openmp=-Xpreprocessor -fopenmp",
        "ac_cv_prog_cxx_openmp=-Xpreprocessor -fopenmp",
        "LDFLAGS=-lomp -lz",
      ]
    end

    system "./configure", *std_configure_args, *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")

    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/magick -version")
    %w[Modules freetype heic jpeg png raw tiff].each do |feature|
      assert_match feature, features
    end

    # Check support for a few specific image formats, mostly to ensure LibRaw linked correctly.
    formats = shell_output("#{bin}/magick -list format")
    ["AVIF  HEIC      rw+", "ARW  DNG       r--", "DNG  DNG       r--"].each do |format|
      assert_match format, formats
    end
    assert_match "Helvetica", shell_output("#{bin}/magick -list font")
  end
end


# *PATCH*
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
# To work around this issue the configure script is patched to test if
# X11/extensions/XShm.h can be included.

__END__
diff --git a/configure b/configure
index 662e288..4b4bc59 100755
--- a/configure
+++ b/configure
@@ -29496,6 +29496,8 @@
 LIBS="-lICE $X_EXTRA_LIBS $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
+
+#include <X11/ICE/ICElib.h>

 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
@@ -29593,6 +29595,8 @@
 LIBS="-lXext  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
+
+#include <X11/extensions/XShm.h>

 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
@@ -29640,6 +29644,8 @@
 LIBS="-lXext  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
+
+#include <X11/extensions/shape.h>

 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
@@ -29682,6 +29688,8 @@
 LIBS="-lXt  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
+
+#include <X11/Intrinsic.h>

 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
