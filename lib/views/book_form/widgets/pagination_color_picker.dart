import 'package:flutter/material.dart';
import '../../../widgets/app_color_picker.dart';
import '../../../l10n/l10n_extension.dart';

void showPaginationColorPicker(BuildContext context, String? initialColor, Function(String?) onSelected) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.paginationChooseColor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          AppColorPicker(
            selectedColor: (initialColor != null && initialColor.isNotEmpty) 
                ? Color(int.parse('0xFF$initialColor')) 
                : null,
            allowNoColor: true,
            onColorSelected: (color) {
              if (color == null) {
                onSelected(null);
              } else {
                final hex = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
                onSelected(hex);
              }
              Navigator.pop(ctx);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}
