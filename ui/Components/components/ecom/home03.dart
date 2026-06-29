import 'package:flutter/material.dart';

class PPOBWidget extends StatelessWidget {
  const PPOBWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('PPOB'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Atur Harga'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Beranda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deposit PPOB',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp 2.889.000',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('+ Deposit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Prabayar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildPPOBItem(
                  icon: Icons.wifi_tethering,
                  title: 'Pulsa Seluler',
                ),
                _buildPPOBItem(
                  icon: Icons.data_usage,
                  title: 'Paket Data',
                ),
                _buildPPOBItem(
                  icon: Icons.bolt,
                  title: 'Token Listrik',
                ),
                _buildPPOBItem(
                  icon: Icons.account_balance_wallet,
                  title: 'Ewallet',
                ),
                _buildPPOBItem(
                  icon: Icons.videogame_asset,
                  title: 'Voucher',
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Pascabayar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Perubahan biaya Admin dan potongan PPOB Pasca Bayar. Cek di sini',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildPPOBItem(
                  icon: Icons.phone_in_talk,
                  title: 'Telkom',
                ),
                _buildPPOBItem(
                  icon: Icons.lightbulb,
                  title: 'PLN',
                ),
                _buildPPOBItem(
                  icon: Icons.bolt,
                  title: 'Pulsa Pasca',
                ),
                _buildPPOBItem(
                  icon: Icons.local_gas_station,
                  title: 'PGN',
                ),
                _buildPPOBItem(
                  icon: Icons.water_drop,
                  title: 'Air PDAM',
                ),
                _buildPPOBItem(
                  icon: Icons.home,
                  title: 'PBB',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPPOBItem({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}