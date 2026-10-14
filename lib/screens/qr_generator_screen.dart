import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

String _normalizePhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.startsWith('0')) {
    digits = '62${digits.substring(1)}';
  }
  return digits.replaceAll('+', '');
}

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _qrBoundaryKey = GlobalKey();
  String? _qrData;

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _generate() {
    final phone = _normalizePhone(_phoneController.text);
    if (phone.isEmpty) return;
    final message = _messageController.text.trim();
    final uri = Uri.https(
        'wa.me', '/$phone', message.isEmpty ? null : {'text': message});
    setState(() => _qrData = uri.toString());
  }

  Future<void> _shareQr() async {
    final boundary = _qrBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/wabox_qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = await File(path).writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Buat kode QR untuk link chat WhatsApp. Siapa pun yang memindai '
            'akan langsung diarahkan ke chat dengan nomor ini.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Nomor WhatsApp',
              hintText: 'contoh: 0812xxxxxxx',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Pesan pembuka (opsional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.message),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Buat QR'),
          ),
          if (_qrData != null) ...[
            const SizedBox(height: 28),
            Center(
              child: RepaintBoundary(
                key: _qrBoundaryKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: QrImageView(
                    data: _qrData!,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _shareQr,
              icon: const Icon(Icons.share),
              label: const Text('Bagikan QR'),
            ),
          ],
        ],
      ),
    );
  }
}
