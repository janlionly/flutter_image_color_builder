# Image Color Builder

[![pub package](https://img.shields.io/pub/v/image_color_builder.svg)](https://pub.dartlang.org/packages/image_color_builder)<a href="https://github.com/janlionly/flutter_image_color_builder"><img src="https://img.shields.io/github/stars/janlionly/flutter_image_color_builder.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>

A Flutter package for generating the image and the image's dominant color with a given image url.

## Usage

See examples to `/example` folder.

```dart
ImageColorBuilder(
  url: 'https://picsum.photos/200',
  builder: (BuildContext context, Image image, Color imageColor) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: imageColor.withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: image,
    );
  }
)
```

## Author

Visit my github: [janlionly](https://github.com/janlionly)<br>
Contact with me by email: janlionly@gmail.com

## Contribute
I would love you to contribute to **ImageColorBuilder**

## License
**ImageColorBuilder** is available under the MIT license. See the [LICENSE](https://github.com/janlionly/flutter_image_color_builder/blob/master/LICENSE) file for more info.
