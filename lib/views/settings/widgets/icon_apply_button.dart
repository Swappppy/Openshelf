import 'package:flutter/material.dart';
import '../../../models/app_icon_config.dart';

class IconApplyButton extends StatelessWidget {
  final Color currentColor;
  final String? activeIconName;
  final VoidCallback onApply;

  const IconApplyButton({
    super.key,
    required this.currentColor,
    required this.activeIconName,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final config = AppIconConfig.getByColor(currentColor);
    final isAlreadyActive = config?.name == (activeIconName ?? 'default');
    
    if (isAlreadyActive) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onApply,
        icon: const Icon(Icons.published_with_changes),
        label: const Text("Aplicar cambio de icono"),
        style: FilledButton.styleFrom(
          backgroundColor: currentColor,
          foregroundColor: currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
