import 'package:flutter/material.dart';
import '../../services/database/converters.dart';
import '../../l10n/l10n_extension.dart';

extension BookFormatExt on BookFormat {
  String label(BuildContext context) {
    switch (this) {
      case BookFormat.paperback: return context.l10n.formatPaperback;
      case BookFormat.hardcover: return context.l10n.formatHardcover;
      case BookFormat.leatherbound: return context.l10n.formatLeatherbound;
      case BookFormat.rustic: return context.l10n.formatRustic;
      case BookFormat.digital: return context.l10n.formatDigital;
      case BookFormat.other: return context.l10n.formatOther;
    }
  }

  IconData get icon {
    switch (this) {
      case BookFormat.paperback:
      case BookFormat.hardcover:
      case BookFormat.leatherbound:
      case BookFormat.rustic:
        return Icons.menu_book_outlined;
      case BookFormat.digital:
        return Icons.tablet_android_outlined;
      case BookFormat.other:
        return Icons.inventory_2_outlined;
    }
  }
}

extension BookFormatNullableExt on BookFormat? {
  String label(BuildContext context) => this?.label(context) ?? '—';

  IconData get icon => this?.icon ?? Icons.inventory_2_outlined;
}
