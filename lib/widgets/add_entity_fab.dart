import 'package:flutter/material.dart';
import '../views/book_form/add_book_modal.dart';

/// A reusable FloatingActionButton that handles adding books or other entities.
/// Supports a custom [onPressed] to override the default "Add Book" behavior.
/// Includes the consistent animation and styling used across the app.
class AddEntityFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool visible;

  const AddEntityFab({
    super.key,
    this.onPressed,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: visible ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: visible ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: onPressed ?? () => _showAddBookModal(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddBookModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddBookModal(),
    );
  }
}
