library image_color_builder;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http; 

class ImageColorBuilder extends StatelessWidget {
  const ImageColorBuilder({required this.url, required this.builder, super.key});
   /// Image URL
  final String url;
  /// Builder function
  final Widget Function(BuildContext context, Image image, Color imageColor) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: _getImageColor(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        return builder(context, Image.memory(snapshot.data!.first), snapshot.data!.last);
      }
    );
  }
  
  Future<List> _getImageColor() async {
    final response = await http.get(Uri.parse(url));
    final codec = await instantiateImageCodec(response.bodyBytes);
    final frameInfo = await codec.getNextFrame();
    final paletteGenerator = await PaletteGenerator.fromImage(frameInfo.image);
    return [response.bodyBytes, paletteGenerator.dominantColor?.color ?? Colors.white];
  }
}

