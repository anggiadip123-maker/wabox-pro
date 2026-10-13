import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String _normalizePhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.startsWith('0')) {
    digits = '62${digits.substring(1)}';
  }
  return digits.replaceAll('+', '');
}

class DirectChatScreen extends StatefulWidget {
  const DirectChatScreen({super.key});

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _openChat() async {
    final phone = _normalizePhone(_phoneController.text);
    if (phone.isEmpty) {
      setState(() => _error = 'Masukkan nomor WhatsApp dulu');
      return;
    }
    setState(() => _error = null);
    final message = _messageController.text.trim();
    final uri = Uri.https(
        'wa.me', '/$phone', message.isEmpty ? null : {'text': message});
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      setState(() => _error = 'Tidak bisa membuka WhatsApp. Pastikan aplikasi WhatsApp terpasang.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Buka langsung chat WhatsApp ke nomor tertentu tanpa perlu '
            'menyimpan kontak terlebih dahulu. Akan membuka aplikasi '
            'WhatsApp resmi di HP Anda.',
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
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Pesan (opsional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.message),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openChat,
            icon: const Icon(Icons.chat),
            label: const Text('Buka di WhatsApp'),
          ),
        ],
      ),
    );
  }
}
