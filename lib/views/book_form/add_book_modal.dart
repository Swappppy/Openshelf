import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/l10n_extension.dart';
import 'book_form_view.dart';
import '../book_search/book_search_view.dart';
import '../barcode_scanner/barcode_scanner_view.dart';

class AddBookModal extends ConsumerWidget {
  const AddBookModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            context.l10n.addBook,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.addBookModalSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // Opciones
          _AddOption(
            icon: Icons.edit_outlined,
            title: context.l10n.addManually,
            subtitle: context.l10n.addManuallySubtitle,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, _) => const BookFormView(),
                  transitionsBuilder: (_, animation, _, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 350),
                ),
              );
            },
          ),
          _AddOption(
            icon: Icons.search,
            title: context.l10n.searchBook,
            subtitle: context.l10n.searchBookSubtitle,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookSearchView(),
                ),
              );
            },
          ),
          _AddOption(
            icon: Icons.qr_code_scanner,
            title: context.l10n.scanBarcode,
            subtitle: context.l10n.scanBarcodeSubtitle,
            onTap: () async {
              // Captura el navigator del contexto raíz ANTES de cerrar el modal
              final rootNav = Navigator.of(context, rootNavigator: true);

              // Cierra el modal
              Navigator.of(context).pop();

              // Espera a que el modal termine de cerrar, luego abre el scanner
              await Future.microtask(() {});

              final String? code = await rootNav.push<String>(
                MaterialPageRoute(
                  builder: (_) => const BarcodeScannerView(),
                ),
              );

              debugPrint('AddBookModal: Scanner returned code: $code');

              if (code != null) {
                rootNav.push(
                  MaterialPageRoute(
                    builder: (_) => BookSearchView(initialQuery: code),
                  ),
                );
              } else {
                debugPrint('AddBookModal: Scanner cancelled by user');
              }
            },
          ),
          _AddOption(
            icon: Icons.document_scanner_outlined,
            title: context.l10n.scanBatch,
            subtitle: context.l10n.scanBatchSubtitle,
            onTap: () async {
              final rootNav = Navigator.of(context, rootNavigator: true);
              Navigator.of(context).pop();
              await Future.microtask(() {});

              await rootNav.push(
                MaterialPageRoute(
                  builder: (_) => const BarcodeScannerView(batchMode: true),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.onPrimaryContainer),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
      onTap: onTap,
    );
  }
}
