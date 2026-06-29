import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syirkah/modules/finance/accounting/pages/general_journal/new_table.dart';
import 'package:syirkah/modules/finance/accounting/pages/general_journal/widgets/gj_table.dart';

import '../blogic/general_journal_states.dart';
import '../models/general_joournal.dart';


class GeneralJournalPage extends ConsumerStatefulWidget {
  const GeneralJournalPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GeneralJournalPageState();
}

class _GeneralJournalPageState extends ConsumerState<GeneralJournalPage> {

  @override
  Widget build(BuildContext context) {
    final journalEntries = ref.watch(generalJournalProvider);

    return GLTable(data: journalEntries);
  }
}

class DaftarJurnal extends ConsumerWidget {
  const DaftarJurnal({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
      var list = [
    GeneralJournal(ref: '101', tanggal: '', keterangan: '', noDept: '', debet: 10000, kredit: 9000, noProyek: '', ),
    GeneralJournal(ref: '102', tanggal: '', keterangan: '', noDept: '', debet: 10000, kredit: 9000, noProyek: '', ),
    GeneralJournal(ref: '103', tanggal: '', keterangan: '', noDept: '', debet: 10000, kredit: 9000, noProyek: '', ),
    GeneralJournal(ref: '104', tanggal: '', keterangan: '', noDept: '', debet: 10000, kredit: 9000, noProyek: '', ),
    GeneralJournal(ref: '105', tanggal: '', keterangan: '', noDept: '', debet: 10000, kredit: 9000, noProyek: '', )

  ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contoh Laporan Accounting'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Jurnal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Semua Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Wednesday, January 01, 2014 - Friday, February 21, 2014',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
           // GeneralJournalPage(),
          ],
        ),
      ),
    );
  }
}
