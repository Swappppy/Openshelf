import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import 'database_provider.dart';
import '../l10n/l10n_extension.dart';

/// Provider for handling complex book-related UI operations like duplication.
final bookOperationsProvider = Provider((ref) => BookOperationsController(ref));

class BookOperationsController {
  final Ref ref;
  BookOperationsController(this.ref);

  /// Shows a confirmation dialog and performs the duplication logic in a transaction.
  Future<void> confirmAndDuplicate(BuildContext context, Book book) async {
    final l10n = context.l10n;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookDetailDuplicateTitle),
        content: Text(l10n.bookDetailDuplicateConfirm(book.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.duplicate),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final db = ref.read(databaseProvider);
        await db.duplicateBook(book.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.addedToLibrary),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
          );
        }
      }
    }
  }
}
