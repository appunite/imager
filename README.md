# Imager

[![CircleCI](https://circleci.com/gh/appunite/imager.svg?style=svg)](https://circleci.com/gh/appunite/imager)
[![Coverage Status](https://coveralls.io/repos/github/appunite/imager/badge.svg?branch=master)](https://coveralls.io/github/appunite/imager?branch=master)

Image processing proxy server written in Elixir.

## Why?

We needed to generate thumbnails for various files in one of our client's
product.  We have tried to use SNS channel to produce them for new images only
however this approach has few disadvantages:

- you need to specify all needed image sizes upfront, so any change in needed
  sizes requires redeployment of UI and image processing service
- configuration of given application is quite complicated as it requires several
  manual steps; this is especially troublesome in our situation as our
  application need simple way to deploy by unskilled sysop on-premise

With given requirements we could use one of existing on-demand image processing
services like:

- [Thumbor](https://github.com/thumbor/thumbor), quite popular service written
  in Python which uses OpenCV bindings to process images
- [Imaginary](https://github.com/h2non/imaginary), written in Go wrapper over
  libvips library
- [Imageflow](https://github.com/imazen/imageflow), written in Rust, AGPL
  reimplementation of [ImageResizer](https://imageresizing.net)

However we also needed support for PDFs and [DICOM][] images which is available
only in Imaginary.  However the API of the Imaginary do not provide enough
flexibility, Imageflow/ImageResizer-like API is much easier to integrate with
UI.  Imageflow would be a perfect solution (even despite AGPL license), however
lack of PDF and DICOM support made it completely infeasible in our situation.

## Production ready?

No.  We use it in our production release, but it is still prone to rapid changes
in the API.  Current API is direct mapping to ImageMagick options, however in
future releases we probably provide higher level API more similar to Imageflow
which would allow us to provide support for different processing libraries, not
only ImageMagick.

## Installation

### Docker

Currently the only officially supported installation way is via official Docker
image that can be found on [Docker Hub][hub].

1. First we need to generate configuration file for Imager

  ```
  $ docker run --rm appunite/imager:latest config > config.toml
  ```

1. Edit `config.toml`.  Documentation is available within the file itself.
1. Run container providing configuration.

  ```
  $ docker run --rm -v './config.toml:/etc/imager/config.toml:ro' -p 8080:80 appunite/imager:latest
  ```

## Usage

Assuming that you have store named `local` and there is file named `lenna.png`
you can access this file directly via on <http://localhost:8080/local/lenna.png>,
to generate thumbnail of size `50x50` pixels you can then use
<http://localhost:8080/local/lenna.png?thumbnail=50x50>.

Currently available options are:

- `thumbnail=<size>`
- `strip`
- `gravity=<gravity>`
- `extent=<size>`
- `flatten`
- `background=<colour>`
- `format=<format>`

Which maps 1:1 to their respective [ImageMagick flags][im-flags].

## License

See [LICENSE](LICENSE) file.

[im-flags]: https://imagemagick.org/script/command-line-processing.php#option
[DICOM]: https://en.wikipedia.org/wiki/DICOM "DICOM - Wikipedia"
[hub]: https://hub.docker.com/r/appunite/imager/ "appunite/imager - Docker Hub"
