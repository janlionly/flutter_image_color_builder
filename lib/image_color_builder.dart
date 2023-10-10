library image_color_builder;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http; 

class ImageColorBuilder extends StatelessWidget {
  const ImageColorBuilder({required this.builder, this.url, super.key});
   /// Image URL
  final String? url;

  /// Builder function
  final Widget Function(BuildContext context, Image? image, Color? imageColor) builder;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return builder(context, null, null);
    }
    return FutureBuilder<List>(
      future: _getImageColor(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData || snapshot.hasError || snapshot.data!.isEmpty) {
          return builder(context, null, null);
        }
        return builder(
          context, 
          (snapshot.data?.first != null ? Image.memory(snapshot.data![0]) : null), 
          (snapshot.data?.length == 2 ? snapshot.data![1] : null)
        );
      }
    );
  }
  
  Future<List> _getImageColor() async {
    if (url != null && url!.isNotEmpty) {
      final targetUrl = url!;
      late final http.Response response;
      late final Codec codec;
      late final FrameInfo frameInfo;
      late final PaletteGenerator paletteGenerator;
      Object? error;
      try {
        response = await http.get(Uri.parse(targetUrl));
        codec = await instantiateImageCodec(response.bodyBytes);
        frameInfo = await codec.getNextFrame();
        paletteGenerator = await PaletteGenerator.fromImage(frameInfo.image);
      } catch (e) {
        error = e;
      }
      if (error == null && response.statusCode == 200) {
        return [response.bodyBytes, paletteGenerator.dominantColor?.color];
      }
    }
    return [];
  }
}

