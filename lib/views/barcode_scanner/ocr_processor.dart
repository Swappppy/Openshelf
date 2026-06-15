import 'dart:io';
import 'package:image/image.dart' as img;
import 'ocr_models.dart';

class OcrCropParams {
  final String inputPath;
  final String outputPath;
  final double widthPercent;
  final double heightPercent;

  OcrCropParams({
    required this.inputPath,
    required this.outputPath,
    required this.widthPercent,
    required this.heightPercent,
  });
}

/// Helper class to perform image processing in a background Isolate.
class OcrProcessor {
  /// Decodes, crops and saves an image. Returns processing details.
  static Future<OcrProcessingResult> processAndCrop(OcrCropParams params) async {
    try {
      final File originalFile = File(params.inputPath);
      if (!originalFile.existsSync()) return OcrProcessingResult(success: false);

      final bytes = await originalFile.readAsBytes();
      final img.Image? fullImage = img.decodeImage(bytes);

      if (fullImage == null) return OcrProcessingResult(success: false);

      // Calculate crop area centered in the image
      final int cropWidth = (fullImage.width * params.widthPercent).toInt();
      final int cropHeight = (fullImage.height * params.heightPercent).toInt();
      final int x = (fullImage.width - cropWidth) ~/ 2;
      final int y = (fullImage.height - cropHeight) ~/ 2;

      final croppedImage = img.copyCrop(
        fullImage,
        x: x,
        y: y,
        width: cropWidth,
        height: cropHeight,
      );

      final File croppedFile = File(params.outputPath);
      await croppedFile.writeAsBytes(img.encodePng(croppedImage));

      return OcrProcessingResult(
        success: true,
        imageWidth: cropWidth,
        imageHeight: cropHeight,
        cropX: x,
        cropY: y,
      );
    } catch (e) {
      return OcrProcessingResult(success: false);
    }
  }
}
