library image_color_builder;

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

// import 'dart:developer' as dev;
class _Dev {
  static void log(String msg) {
    // dev.log(msg);
  }
}

class ImageColorBuilder extends StatelessWidget {
  const ImageColorBuilder({
    required this.builder, 
    this.url, 
    this.isCached = true, 
    this.maxCachedCount = 50, 
    this.fit, 
    super.key
  });
   /// Image URL
  final String? url;

  /// Image Box Fix
  final BoxFit? fit;

  /// Whether cached images
  final bool isCached;

  /// Cached store
  static final Map<String, List> _cachedImages = {};

  /// Max Cached Count
  final int maxCachedCount;

  /// Builder function
  final Widget Function(BuildContext context, Image? image, Color? imageColor) builder;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return builder(context, null, null);
    }
    final cache = _cachedImages[url];
    if (isCached && cache != null && cache.length >= 2) {
      return builder(
        context, 
        Image.memory(cache[0], fit: fit ?? BoxFit.fill),
        cache[1],
      );
    }
    return FutureBuilder<List>(
      future: _getImageColor(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData || snapshot.hasError || snapshot.data!.isEmpty) {
          return builder(context, null, null);
        }
        return builder(
          context, 
          (snapshot.data?.first != null ? Image.memory(snapshot.data![0], fit: fit ?? BoxFit.fill) : null), 
          (snapshot.data != null && snapshot.data!.length >= 2 ? snapshot.data![1] : null)
        );
      }
    );
  }
  
  Future<List> _getImageColor() async {
    if (url != null && url!.isNotEmpty) {
      final targetUrl = url!;

      late final Codec codec;
      late final FrameInfo frameInfo;
      late final PaletteGenerator paletteGenerator;
      late Uint8List imageBytes;

      http.Response? response;
      Object? error;

      try {
        if (targetUrl.toLowerCase().startsWith('http')) {
          response = await http.get(Uri.parse(targetUrl));
          imageBytes = response.bodyBytes;
        } else {
          imageBytes = (await rootBundle.load(targetUrl)).buffer.asUint8List();
        }
        codec = await instantiateImageCodec(imageBytes);
        frameInfo = await codec.getNextFrame();
        paletteGenerator = await PaletteGenerator.fromImage(frameInfo.image);
      } catch (e) {
        error = e;
      }

      if (error == null && (response == null || (response.statusCode == 200))) {
        if (isCached) {
          _cachedImages[targetUrl] = [
            imageBytes, 
            paletteGenerator.dominantColor?.color, 
            DateTime.now().microsecondsSinceEpoch
          ];
          _Dev.log('current images:${_cachedImageDescription()}');
          _clearHalfOfCache();
        }
        return [imageBytes, paletteGenerator.dominantColor?.color];
      }
    }
    return [];
  }

  void _clearHalfOfCache() {
    if (_cachedImages.length >= maxCachedCount) {
      _Dev.log('origin images:${_cachedImageDescription()}');
      final sorted = _cachedImages.entries.toList()..sort((e1, e2) => e1.value[2].compareTo(e2.value[2]));
      for (var i = 0; i < maxCachedCount/2; i++) {
        _Dev.log('removed the datetime: ${sorted[i].value[2]}');
        _cachedImages.remove(sorted[i].key);
      }
      _Dev.log('updated images:${_cachedImageDescription()}');
    }
  }

  String _cachedImageDescription() {
    String description = '\n';
    for (String key in _cachedImages.keys) {
      description += '  $key: [${_cachedImages[key]![1]}, ${_cachedImages[key]![2]}],\n';
    }
    return '\n{$description}\n';
  }
}

