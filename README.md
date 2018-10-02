# Imager

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

TBD

## Usage

TBD

## License

See [LICENSE](LICENSE) file.

[DICOM]: https://en.wikipedia.org/wiki/DICOM "DICOM - Wikipedia"
