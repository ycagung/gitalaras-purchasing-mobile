import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspro/theme/app_colors.dart';
import 'package:signature/signature.dart';

/// Asks the user to draw their signature. Returns it as a base64-encoded PNG
/// (cropped to the strokes, black on transparent), or null if cancelled.
Future<String?> showSignatureDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  Color confirmColor = AppColors.green,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _SignatureDialog(
      title: title,
      confirmLabel: confirmLabel,
      confirmColor: confirmColor,
    ),
  );
}

class _SignatureDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final Color confirmColor;

  const _SignatureDialog({
    required this.title,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  State<_SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<_SignatureDialog> {
  final _controller = SignatureController(
    penStrokeWidth: 2.5,
    penColor: Colors.black,
    strokeCap: StrokeCap.round,
    strokeJoin: StrokeJoin.round,
  );
  bool _exporting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _exporting = true);
    final bytes = await _controller.toPngBytes();
    if (!mounted) return;
    if (bytes == null) {
      setState(() => _exporting = false);
      return;
    }
    Navigator.of(context).pop(base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Draw your signature below',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.mono70),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.mono30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  controller: _controller,
                  height: 200,
                  backgroundColor: AppColors.pampas,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _exporting ? null : _controller.clear,
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: _exporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, points, _) => ElevatedButton(
            onPressed: points.isEmpty || _exporting ? null : _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.confirmColor,
            ),
            child: Text(
              widget.confirmLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
