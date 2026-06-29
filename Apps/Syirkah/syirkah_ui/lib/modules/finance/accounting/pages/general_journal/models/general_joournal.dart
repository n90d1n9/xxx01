
class GeneralJournal {
  final String ref;
  final String tanggal;
  final String keterangan;
  final String noDept;
  final double debet;
  final double kredit;
  final String noProyek;

  GeneralJournal({
    required this.ref,
    required this.tanggal,
    required this.keterangan,
    required this.noDept,
    required this.debet,
    required this.kredit,
    required this.noProyek,
  });
}