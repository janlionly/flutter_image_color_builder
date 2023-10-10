import 'package:flutter_test/flutter_test.dart';
import 'package:image_color_builder/image_color_builder.dart';

import 'package:flutter/material.dart';

void main() {
  test('generating the image and the dominant color with a given image url', () {
    ImageColorBuilder(
      url: 'https://picsum.photos/200',
      builder: (BuildContext context, Image? image, Color? imageColor) {
        return Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: imageColor?.withOpacity(0.8) ?? Colors.red,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: image ?? const Text('No image?'),
        );
      },
    );
  });
}
