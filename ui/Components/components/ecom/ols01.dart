import 'package:flutter/material.dart';

class OlshopinWidget extends StatelessWidget {
  const OlshopinWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olshopin'),
        leading: const Icon(Icons.menu),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Kunjungi Toko'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: 'Semua',
                    items: const [
                      DropdownMenuItem(
                        value: 'Semua',
                        child: Text('Semua'),
                      ),
                      DropdownMenuItem(
                        value: 'Terbaru',
                        child: Text('Terbaru'),
                      ),
                      DropdownMenuItem(
                        value: 'Terlama',
                        child: Text('Terlama'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16.0),
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8.0),
                const Text('2022/05/20 - 2022/...'),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Nama',
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('2022-04-02 11:12:31'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mulyadi - COD'),
                        const SizedBox(height: 4.0),
                        Text('Menunggu Konfirmasi'),
                        const SizedBox(height: 4.0),
                        Text('Jumlah : 1'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}