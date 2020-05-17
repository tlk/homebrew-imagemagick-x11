class Imagemagick < Formula
  desc "Tools and libraries to manipulate images in many formats (X11 support)"
  homepage "https://www.imagemagick.org/"
  url "https://dl.bintray.com/homebrew/mirror/ImageMagick-7.0.10-13.tar.xz"
  mirror "https://www.imagemagick.org/download/releases/ImageMagick-7.0.10-13.tar.xz"
  sha256 "9d129eae1db867fa367b7c7ca9b0e9ae6f1cbd65a9f6db7e8176823a75ef0a0a"
  head "https://github.com/ImageMagick/ImageMagick.git"

  bottle do
    sha256 "b10e8afca599ac07fecb3ff139d31937230a24461aed96df06da092cdf32e792" => :catalina
    sha256 "a2285a4ebf17b064722af82aa7563a26806c799a436454e87bd32f7156a11aba" => :mojave
    sha256 "ee94f9ed87751d73f9f9d58528ae22e13fb53a22adfe432fa65a3bfddff140ad" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "ghostscript"
  depends_on "jpeg"
  depends_on "libheif"
  depends_on "libomp"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libtool"
  depends_on "little-cms2"
  depends_on "openexr"
  depends_on "openjpeg"
  depends_on "webp"
  depends_on "xz"
  depends_on :x11

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"

  skip_clean :la

  def install
    # Avoid references to shim
    inreplace Dir["**/*-config.in"], "@PKG_CONFIG@", Formula["pkg-config"].opt_bin/"pkg-config"

    args = %W[
      --disable-osx-universal-binary
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
      --without-fftw
      --without-pango
      --without-wmf
      --enable-openmp
      ac_cv_prog_c_openmp=-Xpreprocessor\ -fopenmp
      ac_cv_prog_cxx_openmp=-Xpreprocessor\ -fopenmp
      LDFLAGS=-lomp
      X_CFLAGS=-I#{MacOS.sdk_path}/usr/include/libxml2
      X_LIBS=-L#{MacOS.sdk_path}/usr/lib\ -lxml2\ -lz\ -lpthread\ -licucore\ -lm
    ]

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
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
