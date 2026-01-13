import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

const Color primaryColor = Color(0xFF3A2EC3);

const List<Color> qrColors = [
  Colors.white,
  Colors.grey,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.cyan,
  Colors.purple,
];

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  String? _qrData;
  Color _qrColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Create QR', style: TextStyle(color: Colors.white)),
      backgroundColor: primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Stack(
      children: [
        Column(
          children: [
            Container(height: 220, color: primaryColor),
            Expanded(child: Container(color: Colors.grey.shade50)),
          ],
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _qrColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black12, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                            ],
                          ),
                          child: _qrData == null || _qrData!.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Text(
                                    'Masukkan teks/link untuk generate QR',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : PrettyQrView.data(
                                  data: _qrData!,
                                  decoration: const PrettyQrDecoration(
                                    shape: PrettyQrSmoothSymbol(),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Link atau Teks',
                          hintText: 'https://example.com atau teks apa saja',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() => _qrData = value.trim().isEmpty ? null : value.trim());
                        },
                      ),
                      const SizedBox(height: 24),

                      Text(
                          'Pilih Warna Background QR',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: qrColors.map((color) {
                            return GestureDetector(
                              onTap: () => setState(() => _qrColor = color),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _qrColor == color ? Colors.black : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black12, blurRadius: 6),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _qrData = null;
                                    _qrColor = Colors.white;
                                  });
                                },
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Reset'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  if (_qrData == null || _qrData!.isEmpty) return;

                                  // Delay kecil untuk render selesai
                                  await Future.delayed(const Duration(milliseconds: 100));

                                  final Uint8List? imageBytes = await _screenshotController.capture(
                                    pixelRatio: MediaQuery.of(context).devicePixelRatio,
                                  );

                                  if (imageBytes != null) {
                                    await Share.shareXFiles([
                                      XFile.fromData(
                                        imageBytes,
                                        name: 'qrcode_dateTime.png',
                                        mimeType: 'image/png',
                                      ),
                                    ]);
                                  }
                                },
                                icon: const Icon(Icons.share),
                                label: const Text('Share QR'),
                                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                              ),
                            ),
                          ],
                        ),

                        
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  }
}