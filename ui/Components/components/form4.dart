
import 'package:flutter/material.dart';

class Chat1 extends StatefulWidget {
  Chat1({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _Chat1State createState() => _Chat1State();
}

class _Chat1State extends State<Chat1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hati-hati penipuan! Mohon tidak bertransaksi di luar Tokopedia dan tidak memberikan data pribadi kepada penjual, seperti nomor HP dan alamat. Tetap berinteraksi melalui aplikasi Tokopedia, ya.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text('Baca Panduan Keamanan'),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ada Bebas Ongkir untuk 1 pesanan/transaksi di toko ini!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Cek Info Terbaru'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/product.png'),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You Pin Mesin Vacuu...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Rp329.000',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mau tanya apa, nih?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.arrow_upward),
                      SizedBox(width: 8),
                      Text('Hi, ini stoknya masih ada?'),
                      SizedBox(width: 8),
                      Icon(Icons.sentiment_satisfied),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 8),
                      Text('Ongkir ke alamat saya berapa, ya?'),
                      SizedBox(width: 8),
                      Icon(Icons.sentiment_satisfied),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tulis pesan...',
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.chat),
                      SizedBox(width: 8),
                      Icon(Icons.send),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}