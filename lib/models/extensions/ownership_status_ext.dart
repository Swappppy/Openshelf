import 'package:flutter/material.dart';
import '../../services/database/converters.dart';
import '../../l10n/l10n_extension.dart';

extension OwnershipStatusExt on OwnershipStatus {
  String label(BuildContext context) {
    switch (this) {
      case OwnershipStatus.bought: return context.l10n.ownershipStatusBought;
      case OwnershipStatus.gifted: return context.l10n.ownershipStatusGifted;
      case OwnershipStatus.borrowed: return context.l10n.ownershipStatusBorrowed;
      case OwnershipStatus.returned: return context.l10n.ownershipStatusReturned;
      case OwnershipStatus.sold: return context.l10n.ownershipStatusSold;
      case OwnershipStatus.other: return context.l10n.ownershipStatusOther;
    }
  }

  IconData get icon {
    switch (this) {
      case OwnershipStatus.bought: return Icons.shopping_cart_outlined;
      case OwnershipStatus.gifted: return Icons.card_giftcard_outlined;
      case OwnershipStatus.borrowed: return Icons.handshake_outlined;
      case OwnershipStatus.returned: return Icons.keyboard_return_outlined;
      case OwnershipStatus.sold: return Icons.sell_outlined;
      case OwnershipStatus.other: return Icons.more_horiz_outlined;
    }
  }

  Color get color {
    switch (this) {
      case OwnershipStatus.bought: return Colors.blue;
      case OwnershipStatus.gifted: return Colors.purple;
      case OwnershipStatus.borrowed: return Colors.orange;
      case OwnershipStatus.returned: return Colors.green;
      case OwnershipStatus.sold: return Colors.red;
      case OwnershipStatus.other: return Colors.grey;
    }
  }
}

extension OwnershipStatusNullableExt on OwnershipStatus? {
  String label(BuildContext context) => this?.label(context) ?? '—';
  
  IconData get icon => this?.icon ?? Icons.more_horiz_outlined;
  
  Color get color => this?.color ?? Colors.grey;
}
