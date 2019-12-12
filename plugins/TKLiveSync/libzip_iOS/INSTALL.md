libzip uses [cmake](https://cmake.org) to build.

For running the tests, you need to have [perl](https://www.perl.org).

You'll need [zlib](http://www.zlib.net/) (at least version 1.1.2). It
comes with most operating systems.

For supporting bzip2-compressed zip archives, you need
[bzip2](http://bzip.org/).

For AES (encryption) support, you need one of these cryptographic libraries,
listed in order of preference:

- Apple's CommonCrypto (available on macOS and iOS)
- [GnuTLS](https://www.gnutls.org/)
- [mbed TLS](https://tls.mbed.org/)
- [OpenSSL](https://www.openssl.org/) >= 1.0.
- Microsoft Windows Cryptography Framework

If you don't want a library even if it is installed, you can
pass `-DENABLE_<LIBRARY>=OFF` to cmake, where `<LIBRARY>` is one of
`COMMONCRYPTO`, `GNUTLS`, `MBEDTLS`, or `OPENSSL`.

The basic usage is
```sh
mkdir build
cd build
cmake ..
make
make test
make install
```

Some useful parameters you can pass to `cmake` with `-Dparameter=value`:

- `BUILD_SHARED_LIBS`: set to `ON` or `OFF` to enable/disable building
  of shared libraries, defaults to `ON`
- `CMAKE_INSTALL_PREFIX`: for setting the installation path
- `DOCUMENTATION_FORMAT`: choose one of 'man', 'mdoc', and 'html' for
  the installed documentation (default: decided by cmake depending on
  available tools)
  
If you want to compile with custom `CFLAGS`, set them in the environment
before running `cmake`:
```sh
CFLAGS=-DMY_CUSTOM_FLAG cmake ..
```

If you are compiling on a system with a small stack size, add
`-DZIP_ALLOCATE_BUFFER` to `CFLAGS`.

You can get verbose build output with by passing `VERBOSE=1` to
`make`.

You can also check the [cmake FAQ](https://cmake.org/Wiki/CMake_FAQ).
