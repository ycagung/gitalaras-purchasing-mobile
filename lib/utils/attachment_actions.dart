import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:gspro/models/attachment.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

// Attachment names can contain path separators (synced POs are named after
// the PO number, e.g. "PO/2604/0519-....pdf"), which breaks writing the file
// on iOS and gets mangled by Android's save dialog.
String safeFileName(String name) =>
    name.replaceAll(RegExp(r'[\\/:*?"<>|]+'), '-');

bool _hasLink(Attachment doc) =>
    doc.presignedUrl != null && doc.presignedUrl!.isNotEmpty;

Future<http.Response> _fetch(Attachment doc) async {
  final response = await http.get(Uri.parse(doc.presignedUrl!));
  if (response.statusCode != 200) {
    throw Exception('Failed to download: HTTP ${response.statusCode}');
  }
  return response;
}

/// Images open in an in-app viewer; anything else (PDFs) is downloaded to a
/// temp file and handed to the device's default viewer.
Future<void> previewAttachment(BuildContext context, Attachment doc) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!_hasLink(doc)) {
    messenger.showSnackBar(
      SnackBar(content: Text('Preview not available for ${doc.name}')),
    );
    return;
  }

  if (doc.mimeType.startsWith('image/')) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            doc.presignedUrl!,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
            errorBuilder: (context, error, stackTrace) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Failed to load image'),
            ),
          ),
        ),
      ),
    );
    return;
  }

  messenger.showSnackBar(SnackBar(content: Text('Opening ${doc.name}...')));
  try {
    final response = await _fetch(doc);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${doc.id}-${safeFileName(doc.name)}');
    await file.writeAsBytes(response.bodyBytes, flush: true);

    final result = await OpenFilex.open(
      file.path,
      type: doc.mimeType.isNotEmpty ? doc.mimeType : null,
    );
    if (result.type != ResultType.done) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.type == ResultType.noAppToOpen
                ? 'No app found to open ${doc.name}'
                : 'Could not open file: ${result.message}',
          ),
        ),
      );
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}

Future<void> downloadAttachment(BuildContext context, Attachment doc) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!_hasLink(doc)) {
    messenger.showSnackBar(
      SnackBar(content: Text('Download link not available for ${doc.name}')),
    );
    return;
  }

  messenger.showSnackBar(
    SnackBar(content: Text('Downloading ${doc.name}...')),
  );
  try {
    final response = await _fetch(doc);
    final name = safeFileName(doc.name);
    final hasExt = name.contains('.');
    final ext = hasExt ? name.split('.').last : '';
    final nameWithoutExt = hasExt ? name.substring(0, name.lastIndexOf('.')) : name;

    final savedPath = await FileSaver.instance.saveAs(
      name: nameWithoutExt,
      bytes: response.bodyBytes,
      ext: ext,
      mimeType: MimeType.other,
      customMimeType: doc.mimeType,
    );

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          savedPath != null && savedPath.isNotEmpty
              ? 'Download complete'
              : 'Download cancelled',
        ),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}
