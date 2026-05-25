import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {

  final variants = {
    'color0': 0xFFE53935, 'color1': 0xFFD81B60, 'color2': 0xFF8E24AA,
    'color3': 0xFF3949AB, 'color4': 0xFF1E88E5, 'color5': 0xFF00ACC1,
    'color6': 0xFF00897B, 'color7': 0xFF43A047, 'color8': 0xFFC0CA33,
    'color9': 0xFFFB8C00, 'color10': 0xFF6D4C41, 'color11': 0xFF757575,
    'color12': 0xFFF4511E, 'color13': 0xFF5E35B1, 'color14': 0xFF039BE5,
    'color15': 0xFF7CB342, 'color16': 0xFFFDD835, 'color17': 0xFF546E7A,
    'color18': 0xFFB71C1C, 'color19': 0xFF1B5E20, 'color20': 0xFF0D47A1,
    'color21': 0xFF4A148C, 'color22': 0xFFE65100, 'color23': 0xFF263238,
  };

  final resPath = 'android/app/src/main/res';
  final densities = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (var entry in variants.entries) {
    final name = entry.key;
    final colorValue = entry.value;
    
    for (var density in densities.entries) {
      final dirName = density.key;
      final size = density.value;
      
      final image = img.Image(width: size, height: size, numChannels: 4);
      // Clear with transparent
      img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
      
      drawIconToImage(image, colorValue);
      
      final fileName = 'ic_launcher_$name.png';
      final fullPath = '$resPath/$dirName/$fileName';
      
      final dir = Directory('$resPath/$dirName');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      
      await File(fullPath).writeAsBytes(img.encodePng(image));
    }
  }

  // Ensure default icon (Classic)
  for (var density in densities.entries) {
    final dirName = density.key;
    final size = density.value;
    final image = img.Image(width: size, height: size, numChannels: 4);
    img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
    drawIconToImage(image, 0xFF6750A4);
    final fullPath = '$resPath/$dirName/ic_launcher.png';
    await File(fullPath).writeAsBytes(img.encodePng(image));
  }
}

void drawIconToImage(img.Image image, int accentColorValue) {
  final double w = image.width.toDouble();
  final double h = image.height.toDouble();
  
  // Background: Deep dark blue-grey (NOT BLACK)
  final bgColor = img.ColorRgba8(30, 30, 45, 255); 
  
  // Book Colors
  final neutralBookColor = img.ColorRgba8(100, 100, 120, 255); 
  final shelfColor = img.ColorRgba8(120, 120, 140, 255);       
  
  // Accent color extraction
  final r = (accentColorValue >> 16) & 0xFF;
  final g = (accentColorValue >> 8) & 0xFF;
  final b = accentColorValue & 0xFF;
  final accentColor = img.ColorRgba8(r, g, b, 255);
  final stripeColor = img.ColorRgba8(0, 0, 0, 60);

  // 1. Draw background
  img.fillRect(image, x1: 0, y1: 0, x2: w.toInt(), y2: h.toInt(), color: bgColor);

  // 2. Left book (neutral)
  fillSimpleRect(image, w * 0.23, h * 0.34, w * 0.17, h * 0.44, neutralBookColor);
  
  // 3. Middle book (Accent)
  fillSimpleRect(image, w * 0.43, h * 0.22, w * 0.20, h * 0.56, accentColor);
  
  // 4. Stripe on accent book
  fillSimpleRect(image, w * 0.43, h * 0.29, w * 0.20, h * 0.02, stripeColor);
  
  // 5. Right book (neutral)
  fillSimpleRect(image, w * 0.65, h * 0.40, w * 0.16, h * 0.38, neutralBookColor);
  
  // 6. Shelf
  fillSimpleRect(image, w * 0.19, h * 0.78, w * 0.62, h * 0.04, shelfColor);
}

void fillSimpleRect(img.Image image, double x, double y, double width, double height, img.Color color) {
  img.fillRect(image, 
    x1: x.toInt(), y1: y.toInt(), 
    x2: (x + width).toInt(), y2: (y + height).toInt(), 
    color: color
  );
}
