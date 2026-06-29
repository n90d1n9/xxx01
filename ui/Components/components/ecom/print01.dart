import 'package:flutter/material.dart';
//import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PrintPreview extends StatefulWidget {
  const PrintPreview({Key? key}) : super(key: key);

  @override
  State<PrintPreview> createState() => _PrintPreviewState();
}

class _PrintPreviewState extends State<PrintPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selaras',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jl Buah mangga 3 no 23',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '29195720201014094531',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '2020-10-14',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'ocha',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '09:45:31',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'No.0-1',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Asinan Sayur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1 x 30.000',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Rp 30.000',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Bayar',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Rp 30.000',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Kembali',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Rp 0',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Link Kritik dan Saran:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'olshopin.com/f/256919',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/kasir_pintar.png'),
                ElevatedButton(
                  onPressed: () {
                    _generatePdf();
                  },
                  child: const Text('Cetak'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Selaras',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
               pw.SizedBox(height: 8),
              pw.Text(
                'Jl Buah mangga 3 no 23',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                '29195720201014094531',
                style: pw.TextStyle(fontSize: 16),
              ),
               pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children:  [
                   pw.Text(
                    '2020-10-14',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'ocha',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
               pw.SizedBox(height: 4),
              pw.Text(
                '09:45:31',
                style: pw.TextStyle(fontSize: 14),
              ),
               pw.SizedBox(height: 4),
              pw.Text(
                'No.0-1',
                style: pw.TextStyle(fontSize: 14),
              ),
               pw.SizedBox(height: 16),
              pw.Text(
                'Asinan Sayur',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
               pw.SizedBox(height: 8),
              pw.Text(
                '1 x 30.000',
                style: pw.TextStyle(fontSize: 16),
              ),
               pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children:  [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                  pw.Text(
                    'Rp 30.000',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                ],
              ),
               pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children:  [
                  pw.Text(
                    'Bayar',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                  pw.Text(
                    'Rp 30.000',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                ],
              ),
               pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children:  [
                  pw.Text(
                    'Kembali',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                  pw.Text(
                    'Rp 0',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                ],
              ),
               pw.SizedBox(height: 16),
              pw.Text(
                'Link Kritik dan Saran:',
                style: pw.TextStyle(fontSize: 14),
              ),
               pw.SizedBox(height: 4),
              pw.Text(
                'olshopin.com/f/256919',
                style: pw.TextStyle(fontSize: 14),
              ),
               pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  /* pw.Image.asset('assets/kasir_pintar.png'),
                  TextButton(
                    onPressed: () {},
                    child: const pw.Text('Cetak'),
                  ), */
                ],
              ),
            ],
          );
        },
      ),
    );

   /*  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      return pdf.save();
    }); */
  }
}