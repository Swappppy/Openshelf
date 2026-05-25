import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' show Value;
import '../models/tag_type.dart';
import '../services/database.dart';
import '../services/cover_service.dart';
import '../services/permission_service.dart';
import '../controllers/database_provider.dart';
import '../l10n/l10n_extension.dart';
import 'app_color_picker.dart';

Future<Tag?> showTagFormDialog(BuildContext context, WidgetRef ref, {Tag? existing, String? initialName, required String title, required TagType type}) {
  final ctrl = TextEditingController(text: existing?.name ?? initialName ?? '');
  String? selectedColor = existing?.color;
  String? imagePath = existing?.imagePath;

  return showDialog<Tag?>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        String hint = context.l10n.tagNameLabel;
        if (type == TagType.imprint) hint = context.l10n.imprintNameLabel;
        if (type == TagType.collection) hint = context.l10n.collectionNameLabel;

        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == TagType.imprint) ...[
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final result = await PermissionService.requestGallery();
                            if (result != GalleryPermissionResult.granted) return;
                            if (!context.mounted) return;
                            final l10n = context.l10n;
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery);
                            if (picked == null) return;
                            final cropped = await CoverService.cropImprint(
                              picked.path, 
                              title: l10n.cropImprintTitle,
                              doneButtonTitle: l10n.done,
                              cancelButtonTitle: l10n.cancel,
                            );
                            if (cropped == null) return;
                            final saved = await CoverService.saveImprintImage(cropped);
                            setState(() => imagePath = saved);
                          },
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                            child: imagePath != null && imagePath!.isNotEmpty
                                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(imagePath!), fit: BoxFit.cover))
                                : Center(child: Icon(Icons.business_outlined, size: 32, color: Theme.of(context).colorScheme.outline)),
                          ),
                        ),
                        if (imagePath != null)
                          Positioned(top: 0, right: 0, child: GestureDetector(onTap: () => setState(() => imagePath = null), child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), padding: const EdgeInsets.all(2), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: Text(context.l10n.photo),
                        onPressed: () async {
                          if (!await PermissionService.requestCamera()) return;
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.camera);
                          if (picked == null) return;
                          if (!context.mounted) return;
                          final l10n = context.l10n;
                          final cropped = await CoverService.cropImprint(
                            picked.path, 
                            title: l10n.cropImprintTitle,
                            doneButtonTitle: l10n.done,
                            cancelButtonTitle: l10n.cancel,
                          );
                          if (cropped == null) return;
                          final saved = await CoverService.saveImprintImage(cropped);
                          setState(() => imagePath = saved);
                        },
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        icon: const Icon(Icons.link, size: 16),
                        label: Text(context.l10n.url),
                        onPressed: () async {
                          final urlCtrl = TextEditingController();
                          final url = await showDialog<String>(
                            context: context,
                            builder: (urlCtx) => AlertDialog(
                              title: Text(context.l10n.imprintUrlDialogTitle),
                              content: TextField(controller: urlCtrl, keyboardType: TextInputType.url, decoration: InputDecoration(hintText: context.l10n.imprintUrlHint, border: const OutlineInputBorder())),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(urlCtx), child: Text(context.l10n.cancel)),
                                FilledButton(onPressed: () => Navigator.pop(urlCtx, urlCtrl.text.trim()), child: Text(context.l10n.download)),
                              ],
                            ),
                          );
                          if (url == null || url.isEmpty) return;
                          if (!context.mounted) return;
                          final l10n = context.l10n;
                          final saved = await CoverService.saveImprintFromUrl(
                            url, 
                            cropTitle: l10n.cropImprintTitle,
                            doneButtonTitle: l10n.done,
                            cancelButtonTitle: l10n.cancel,
                          );
                          if (saved != null) setState(() => imagePath = saved);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: ctrl, 
                  decoration: InputDecoration(hintText: hint)
                ),
                if (type == TagType.tag) ...[
                  const SizedBox(height: 20),
                  Text(context.l10n.tagColorLabel, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 12),
                  AppColorPicker(
                    selectedColor: selectedColor != null ? Color(int.parse('0xFF$selectedColor')) : null,
                    onColorSelected: (color) {
                      setState(() => selectedColor = color?.toARGB32().toRadixString(16).substring(2).toUpperCase());
                    },
                    circleSize: 32,
                    spacing: 8,
                    allowNoColor: true,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
            TextButton(
              onPressed: () async {
                final name = ctrl.text.trim();
                if (name.isNotEmpty) {
                  Tag? result;
                  if (existing == null) {
                    final id = await ref.read(databaseProvider).insertTag(TagsCompanion(
                      name: Value(name), 
                      type: Value(type),
                      color: Value(selectedColor),
                      imagePath: Value(imagePath),
                    ));
                    result = Tag(
                      id: id,
                      name: name,
                      type: type,
                      color: selectedColor,
                      imagePath: imagePath,
                    );
                  } else {
                    result = existing.copyWith(
                      name: name,
                      color: Value(selectedColor),
                      imagePath: Value(imagePath),
                    );
                    await ref.read(databaseProvider).updateTag(result);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, result);
                }
              }, 
              child: Text(context.l10n.save)
            ),
          ],
        );
      },
    ),
  );
}
