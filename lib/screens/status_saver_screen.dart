import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

bool _isVideo(String path) {
  final ext = path.toLowerCase();
  return ext.endsWith('.mp4') || ext.endsWith('.3gp') || ext.endsWith('.mov');
}

class StatusSaverScreen extends StatefulWidget {
  const StatusSaverScreen({super.key});

  @override
  State<StatusSaverScreen> createState() => _StatusSaverScreenState();
}

class _StatusSaverScreenState extends State<StatusSaverScreen> {
  List<PlatformFile> _files = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );
    if (result == null) return;
    setState(() => _files = result.files);
  }

  Future<void> _shareFile(PlatformFile f) async {
    if (f.path == null) return;
    await Share.shareXFiles([XFile(f.path!)]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pilih foto/video status WhatsApp yang sudah pernah Anda '
                'lihat (biasanya tersimpan otomatis di galeri HP pada '
                'album "WhatsApp" atau "WhatsApp Business") untuk disimpan '
                'ulang atau dibagikan ke aplikasi lain.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.folder_open),
                label: const Text('Pilih File Status'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _files.isEmpty
              ? const Center(
                  child: Text('Belum ada file dipilih',
                      style: TextStyle(color: Colors.black38)),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _files.length,
                  itemBuilder: (context, i) {
                    final f = _files[i];
                    final isVideo = _isVideo(f.name);
                    return GestureDetector(
                      onTap: () => _shareFile(f),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: isVideo || f.path == null
                                ? Container(
                                    color: Colors.black12,
                                    child: const Icon(Icons.movie, size: 36),
                                  )
                                : Image.file(File(f.path!), fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.share,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
