//import 'package:printing/printing.dart';


class PrintingServices{

}


/* 

Installing 

Add this package to your package's pubspec.yaml file as described on the installation tab

Import the libraries

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
Enable Swift on the iOS project, in ios/Podfile:

target 'Runner' do
   use_frameworks!    # <-- Add this line
For macOS applications, add the following print entitlement to the files macos/Runner/Release.entitlements and macos/Runner/DebugProfile.entitlements:

<key>com.apple.security.print</key>
<true/>
If you want to manually set the Pdf.js library version for the web, a small script has to be added to your web/index.html file, just before </head>. Otherwise it is loaded automatically:

<script>
  var dartPdfJsVersion = "3.2.146";
</script>
5.1. If you want to manually set the alternative location for loading Pdf.js library for the web, the following script has to be added to your web/index.html file, just before </head>.

<script>
  var dartPdfJsBaseUrl = "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.2.146/";
</script>
It is possible to use local directory which will be resolved to the host where the web app is running.

<script>
  var dartPdfJsBaseUrl = "assets/js/pdf/3.2.146/";
</script>
For Windows and Linux, you can force the pdfium version and architecture on your main CMakeLists.txt with:

set(PDFIUM_VERSION "4929" CACHE STRING "" FORCE)
set(PDFIUM_ARCH "x64" CACHE STRING "" FORCE)
See the releases here: https://github.com/bblanchon/pdfium-binaries/releases

Examples 

final doc = pw.Document();

doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text('Hello World'),
        ); // Center
      })); // Page
To load an image from a Flutter asset:

final image = await imageFromAssetBundle('assets/image.png');

doc.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Center(
        child: pw.Image(image),
      ); // Center
    })); // Page
To use a TrueType font from a flutter bundle:

final ttf = await fontFromAssetBundle('assets/open-sans.ttf');

doc.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Center(
        child: pw.Text('Dart is awesome', style: pw.TextStyle(font: ttf, fontSize: 40)),
      ); // Center
    })); // Page
To save the pdf file using the path_provider library:

final output = await getTemporaryDirectory();
final file = File('${output.path}/example.pdf');
await file.writeAsBytes(await doc.save());
You can also print the document using the iOS or Android print service:

await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save());
Or share the document to other applications:

await Printing.sharePdf(bytes: await doc.save(), filename: 'my-document.pdf');
To print an HTML document:

import HTMLtoPDFWidgets

await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
  const body = '''
    <h1>Heading Example</h1>
    <p>This is a paragraph.</p>
    <img src="image.jpg" alt="Example Image" />
    <blockquote>This is a quote.</blockquote>
    <ul>
      <li>First item</li>
      <li>Second item</li>
      <li>Third item</li>
    </ul>
    ''';

  final pdf = pw.Document();
  final widgets = await HTMLToPdf().convert(body);
  pdf.addPage(pw.MultiPage(build: (context) => widgets));
  return await pdf.save();
});
Convert a Pdf to images, one image per page, get only pages 1 and 2 at 72 dpi:

await for (var page in Printing.raster(await doc.save(), pages: [0, 1], dpi: 72)) {
  final image = page.toImage(); // ...or page.toPng()
  print(image);
}
To print an existing Pdf file from a Flutter asset:

final pdf = await rootBundle.load('document.pdf');
await Printing.layoutPdf(onLayout: (_) => pdf.buffer.asUint8List());
Display your PDF document 

This package also comes with a PdfPreview widget to display a pdf document.

PdfPreview(
  build: (format) => doc.save(),
);
This widget is compatible with Android, iOS, macOS, Linux, Windows and web.

Designing your PDF document 

A good starting point is to use PdfPreview which features hot-reload pdf build and refresh.

Take a look at the example tab for a sample project.

Update the _generatePdf method with your design.

Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => pw.Placeholder(),
      ),
    );

    return pdf.save();
  }
This widget also features a debug switch at the bottom right to display the drawing constraints used. This switch is available only on debug builds.

Moving on to your production application, you can keep the _generatePdf function and print the document using:

final title = 'Flutter Demo';
await Printing.layoutPdf(onLayout: (format) => _generatePdf(format, title));
Encryption, Digital Signature, and loading a PDF Document 

Encryption using RC4-40, RC4-128, AES-128, and AES-256 is fully supported using a separate library. This library also provides SHA1 or SHA-256 Digital Signature using your x509 certificate. The graphic signature is represented by a clickable widget that shows Digital Signature information. It implememts a PDF parser to load an existing document and add pages, change pages, and add a signature.

More information here: https://pub.nfet.net/pdf_crypto/

 */