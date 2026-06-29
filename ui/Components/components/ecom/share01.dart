import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareWidget extends StatelessWidget {
  const ShareWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olshopin'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bagikan toko mu sekarang juga!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Olshopin membantu kamu untuk menjangkau pelanggan di manapun dan kapanpun. Hanya dengan membagikan link toko, pelanggan dapat mengetahui produk menarik yang kamu tawarkan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Link Olshopin Saya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'http://olshopin.com/t/256919',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: 'http://olshopin.com/t/256919'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link berhasil disalin!'),
                        ),
                      );
                    },
                    child: const Text('Salin'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bagikan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Share.share(
                      'http://olshopin.com/t/256919',
                      subject: 'Olshopin',
                    );
                  },
                  icon: const Icon(Icons.facebook),
                ),
                IconButton(
                  onPressed: () {
                    Share.share(
                      'http://olshopin.com/t/256919',
                      subject: 'Olshopin',
                    );
                  },
                  icon:  Icon(Icons.chat_bubble),
                ),
                IconButton(
                  onPressed: () {
                    Share.share(
                      'http://olshopin.com/t/256919',
                      subject: 'Olshopin',
                    );
                  },
                  icon: const Icon(Icons.link),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Kenapa harus Olshopin?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.circle, color: Colors.yellow),
                SizedBox(width: 10),
                Text('Gratis!'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Atur Toko Saya'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse('http://olshopin.com/t/256919'));
                  },
                  child: const Text('Kunjungi Toko'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}