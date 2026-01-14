// lib/ui/qr_generator_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  bool _isGeneratingPdf = false;

  bool get _hasQr => _qrData != null && _qrData!.isNotEmpty;

  Future<Uint8List?> _captureQr() async {
    if (!_hasQr) return null;

    // Delay kecil biar widget pasti sudah ke-render
    await Future.delayed(const Duration(milliseconds: 120));

    final imageBytes = await _screenshotController.capture(
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );

    return imageBytes;
  }

  Future<void> _shareQr() async {
    if (!_hasQr) return;

    try {
      final imageBytes = await _captureQr();
      if (imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal capture QR untuk share')),
        );
        return;
      }

      await Share.shareXFiles(
        [
          XFile.fromData(
            imageBytes,
            name: 'qrcode_${DateTime.now().millisecondsSinceEpoch}.png',
            mimeType: 'image/png',
          ),
        ],
        text: 'QR Code untuk: $_qrData\nDibuat dengan aplikasi QR S&G.',
        subject: 'Share QR Code dari QR S&G',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi error saat share: $e')));
    }
  }

  Future<void> _sendQr() async {
    if (!_hasQr) return;

    try {
      final imageBytes = await _captureQr();
      if (imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal capture QR untuk dikirim')),
        );
        return;
      }

      await Share.shareXFiles(
        [
          XFile.fromData(
            imageBytes,
            name: 'qrcode_send_${DateTime.now().millisecondsSinceEpoch}.png',
            mimeType: 'image/png',
          ),
        ],
        text:
            'Halo,\n\nBerikut QR Code untuk: $_qrData\nDibuat menggunakan aplikasi QR S&G oleh Hammam Mubarak.',
        subject: 'QR Code dari QR S&G App',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error saat mengirim: $e')),
      );
    }
  }

  Future<void> _generateAndPrintPdf() async {
    if (!_hasQr) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final imageBytes = await _captureQr();
      if (imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal capture QR untuk PDF')),
        );
        setState(() => _isGeneratingPdf = false);
        return;
      }

      final pdf = pw.Document();
      final qrImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(32),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'QR Code Ticket',
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(16),
                    border: pw.Border.all(color: PdfColors.grey400, width: 1),
                  ),
                  child: pw.Image(qrImage, width: 220, height: 220),
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Link / Teks:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _qrData ?? '-',
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated by Hammam Mubarak - QR S&G',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'QR_Code_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error saat generate PDF: $e')),
      );
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

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
                              border: Border.all(
                                color: Colors.black12,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: !_hasQr
                                ? const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Text(
                                      'Masukkan teks/link untuk generate QR',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            setState(() {
                              final trimmed = value.trim();
                              _qrData = trimmed.isEmpty ? null : trimmed;
                            });
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
                                    color: _qrColor == color
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Row bawah: Reset | Share | Send | Print
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
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Reset'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _hasQr ? _shareQr : null,
                                icon: const Icon(Icons.share),
                                label: const Text('Share'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _hasQr ? _sendQr : null,
                                icon: const Icon(Icons.send),
                                label: const Text('Send'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _hasQr && !_isGeneratingPdf
                                    ? _generateAndPrintPdf
                                    : null,
                                icon: _isGeneratingPdf
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.print),
                                label: const Text('Print'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                ),
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
