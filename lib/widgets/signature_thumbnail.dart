import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspro/theme/app_colors.dart';

/// Small preview of an approver's signature; tap to view it full size.
class SignatureThumbnail extends StatelessWidget {
  final String url;

  const SignatureThumbnail({super.key, required this.url});

  Widget _image({double? height}) => Image.network(
        url,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Text(
          'Signature unavailable',
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.mono70),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: InteractiveViewer(child: _image()),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.pampas,
          border: Border.all(color: AppColors.mono30),
          borderRadius: BorderRadius.circular(6),
        ),
        child: _image(height: 40),
      ),
    );
  }
}
