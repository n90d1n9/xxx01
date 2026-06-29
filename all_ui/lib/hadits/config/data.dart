// Sample Data
import '../models/book.dart';
import '../models/hadith.dart';
import '../models/multilingual_text.dart';
import '../models/rawi.dart';

final sampleBooks = [
  Book(
    id: 'b1',
    name: MultilingualText(
      id: 'Shahih Bukhari',
      en: 'Sahih Bukhari',
      ar: 'صحيح البخاري',
    ),
    author: MultilingualText(
      id: 'Imam Bukhari',
      en: 'Imam al-Bukhari',
      ar: 'الإمام البخاري',
    ),
    description: MultilingualText(
      id: 'Koleksi hadits sahih yang paling otentik',
      en: 'The most authentic collection of hadith',
      ar: 'أصح كتب الحديث',
    ),
  ),
  Book(
    id: 'b2',
    name: MultilingualText(
      id: 'Muwatta Malik',
      en: 'Muwatta Malik',
      ar: 'موطأ مالك',
    ),
    author: MultilingualText(
      id: 'Imam Malik',
      en: 'Imam Malik ibn Anas',
      ar: 'الإمام مالك بن أنس',
    ),
    description: MultilingualText(
      id: 'Kitab hadits tertua yang masih ada',
      en: 'The earliest surviving book of hadith',
      ar: 'أقدم كتب الحديث الموجودة',
    ),
  ),
];

final sampleRawis = [
  Rawi(
    id: 'r1',
    name: MultilingualText(
      id: 'Abu Hurairah',
      en: 'Abu Hurairah',
      ar: 'أبو هريرة',
    ),
    birthYear: '19 SH',
    deathYear: '59 H',
    region: MultilingualText(id: 'Madinah', en: 'Madinah', ar: 'المدينة'),
    biography: MultilingualText(
      id: 'Sahabat Nabi yang meriwayatkan hadits terbanyak',
      en: 'Companion who narrated the most hadiths',
      ar: 'أكثر الصحابة رواية للحديث',
    ),
    teachers: [],
    students: ['r2', 'r3'],
  ),
  Rawi(
    id: 'r2',
    name: MultilingualText(
      id: 'Said bin Al-Musayyib',
      en: 'Sa\'id ibn al-Musayyib',
      ar: 'سعيد بن المسيب',
    ),
    birthYear: '13 H',
    deathYear: '94 H',
    region: MultilingualText(id: 'Madinah', en: 'Madinah', ar: 'المدينة'),
    biography: MultilingualText(
      id: 'Salah satu ulama tabi\'in terbesar',
      en: 'One of the greatest scholars of the Tabi\'in',
      ar: 'من كبار التابعين',
    ),
    teachers: ['r1'],
    students: ['r4'],
  ),
  Rawi(
    id: 'r3',
    name: MultilingualText(id: 'Az-Zuhri', en: 'Az-Zuhri', ar: 'الزهري'),
    birthYear: '50 H',
    deathYear: '124 H',
    region: MultilingualText(id: 'Madinah', en: 'Madinah', ar: 'المدينة'),
    biography: MultilingualText(
      id: 'Pelopor penulisan hadits',
      en: 'Pioneer of hadith compilation',
      ar: 'أول من دون الحديث',
    ),
    teachers: ['r1'],
    students: ['r5'],
  ),
  Rawi(
    id: 'r4',
    name: MultilingualText(
      id: 'Yahya bin Said',
      en: 'Yahya ibn Sa\'id',
      ar: 'يحيى بن سعيد',
    ),
    birthYear: '20 H',
    deathYear: '143 H',
    region: MultilingualText(id: 'Madinah', en: 'Madinah', ar: 'المدينة'),
    biography: MultilingualText(
      id: 'Ahli hadits dan fiqih terkemuka',
      en: 'Renowned hadith and fiqh scholar',
      ar: 'من علماء الحديث والفقه',
    ),
    teachers: ['r2'],
    students: ['r6'],
  ),
  Rawi(
    id: 'r5',
    name: MultilingualText(
      id: 'Malik bin Anas',
      en: 'Malik ibn Anas',
      ar: 'مالك بن أنس',
    ),
    birthYear: '93 H',
    deathYear: '179 H',
    region: MultilingualText(id: 'Madinah', en: 'Madinah', ar: 'المدينة'),
    biography: MultilingualText(
      id: 'Imam mazhab Maliki, penulis Al-Muwatta',
      en: 'Founder of Maliki school, author of Al-Muwatta',
      ar: 'إمام دار الهجرة، صاحب الموطأ',
    ),
    teachers: ['r3'],
    students: [],
  ),
  Rawi(
    id: 'r6',
    name: MultilingualText(
      id: 'Imam Bukhari',
      en: 'Imam al-Bukhari',
      ar: 'الإمام البخاري',
    ),
    birthYear: '194 H',
    deathYear: '256 H',
    region: MultilingualText(id: 'Bukhara', en: 'Bukhara', ar: 'بخارى'),
    biography: MultilingualText(
      id: 'Penulis kitab hadits paling sahih',
      en: 'Author of the most authentic hadith collection',
      ar: 'صاحب أصح كتب الحديث',
    ),
    teachers: ['r4'],
    students: [],
  ),
];

final sampleHadiths = [
  Hadith(
    id: 'h1',
    arabicText:
        'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
    translation: MultilingualText(
      id:
          'Sesungguhnya setiap amal perbuatan tergantung pada niatnya, dan sesungguhnya setiap orang akan mendapat balasan sesuai dengan apa yang dia niatkan.',
      en:
          'Verily actions are by intentions, and for every person is what he intended.',
      ar: 'إنما الأعمال بالنيات وإنما لكل امرئ ما نوى',
    ),
    explanation: MultilingualText(
      id:
          'Hadits ini menjelaskan pentingnya niat dalam setiap amal ibadah dan perbuatan. Niat yang baik akan mengubah perbuatan biasa menjadi ibadah.',
      en:
          'This hadith explains the importance of intention in every act of worship and deed. A good intention transforms ordinary actions into worship.',
      ar: 'هذا الحديث يبين أهمية النية في كل عمل وعبادة',
    ),
    sanad: ['r6', 'r4', 'r2', 'r1'],
    grade: 'Sahih',
    bookId: 'b1',
    chapter: MultilingualText(
      id: 'Kitab Permulaan Wahyu',
      en: 'Book of Revelation',
      ar: 'كتاب بدء الوحي',
    ),
    number: 1,
    topics: ['Niat', 'Iman', 'Amal'],
    relatedHadiths: ['h2', 'h3'],
  ),
  Hadith(
    id: 'h2',
    arabicText: 'الدِّينُ النَّصِيحَةُ',
    translation: MultilingualText(
      id: 'Agama adalah nasihat.',
      en: 'The religion is sincerity and sincere advice.',
      ar: 'الدين النصيحة',
    ),
    explanation: MultilingualText(
      id:
          'Hadits ini menekankan bahwa inti dari agama adalah memberikan nasihat yang tulus kepada Allah, Rasul-Nya, para pemimpin, dan kaum muslimin.',
      en:
          'This hadith emphasizes that the essence of religion is sincere advice to Allah, His Messenger, the leaders, and the Muslims.',
      ar: 'يبين هذا الحديث أن جوهر الدين هو النصيحة',
    ),
    sanad: ['r5', 'r3', 'r1'],
    grade: 'Sahih',
    bookId: 'b2',
    chapter: MultilingualText(
      id: 'Kitab Akhlak yang Baik',
      en: 'Book of Good Character',
      ar: 'كتاب حسن الخلق',
    ),
    number: 47,
    topics: ['Nasihat', 'Iman', 'Akhlak'],
    relatedHadiths: ['h1'],
  ),
  Hadith(
    id: 'h3',
    arabicText: 'خَيْرُ الْكَلَامِ مَا قَلَّ وَدَلَّ',
    translation: MultilingualText(
      id: 'Sebaik-baik perkataan adalah yang sedikit namun jelas maknanya.',
      en: 'The best speech is that which is concise and clear.',
      ar: 'خير الكلام ما قل ودل',
    ),
    explanation: MultilingualText(
      id:
          'Hadits ini mengajarkan untuk berbicara dengan ringkas namun bermakna, tidak bertele-tele dalam perkataan.',
      en:
          'This hadith teaches us to speak concisely yet meaningfully, without being verbose.',
      ar: 'يعلمنا هذا الحديث الإيجاز في الكلام',
    ),
    sanad: ['r6', 'r4', 'r2', 'r1'],
    grade: 'Hasan',
    bookId: 'b1',
    chapter: MultilingualText(
      id: 'Kitab Ilmu',
      en: 'Book of Knowledge',
      ar: 'كتاب العلم',
    ),
    number: 68,
    topics: ['Ilmu', 'Perkataan', 'Akhlak'],
    relatedHadiths: ['h1'],
  ),
];
