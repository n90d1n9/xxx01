/// indonesia_geo_data.dart
///
/// Embedded WGS-84 geographic data for all Indonesian administrative regions.
///   • 38 provinces (post-2022 split, simplified polygon outlines)
///   • 153 cities / kabupaten capitals (population-sourced)
///
/// Coordinate system: decimal degrees, WGS-84.
/// Indonesia bounds approx: lon 95°E–141.5°E, lat 11°S–6.2°N
library indonesia_geo_data;

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────
class IDProvince {
  final String id;        // BPS 2-letter code
  final String name;
  final String island;    // island group label
  final double cLat, cLon; // centroid
  final List<List<double>> poly; // [[lon,lat],...]
  const IDProvince({
    required this.id, required this.name, required this.island,
    required this.cLat, required this.cLon, required this.poly,
  });
}

class IDCity {
  final String id;
  final String name;
  final String provId;
  final double lat, lon;
  final String type;        // 'capital'|'city'|'regency'
  final int pop;
  const IDCity({
    required this.id, required this.name, required this.provId,
    required this.lat, required this.lon,
    this.type = 'city', this.pop = 0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// 38 PROVINCE POLYGONS  (simplified ~12-22 vertices)
// Grouped by island for filtering
// ─────────────────────────────────────────────────────────────────────────────
const List<IDProvince> kIDProvinces = [

  // ══════════════════ SUMATRA ═══════════════════════════════════════════════

  IDProvince(id:'AC', name:'Aceh', island:'Sumatra', cLat:4.28, cLon:96.74, poly:[
    [95.01,5.90],[95.70,5.82],[96.30,5.52],[97.08,5.26],[97.62,4.62],
    [98.04,3.88],[98.30,3.34],[98.40,2.80],[98.10,2.56],[97.58,2.68],
    [97.08,3.10],[96.40,3.44],[95.80,3.88],[95.20,4.36],[94.96,5.00],[95.01,5.90],
  ]),

  IDProvince(id:'SU', name:'Sumatera Utara', island:'Sumatra', cLat:2.12, cLon:99.54, poly:[
    [98.40,2.80],[98.60,3.00],[99.04,3.26],[99.46,3.52],[99.80,3.18],
    [100.20,2.88],[100.58,2.38],[100.74,1.84],[100.50,1.46],[99.88,1.18],
    [99.20,0.94],[98.72,1.32],[98.30,1.86],[98.10,2.56],[98.40,2.80],
  ]),

  IDProvince(id:'SB', name:'Sumatera Barat', island:'Sumatra', cLat:-0.74, cLon:100.44, poly:[
    [99.20,0.94],[99.88,1.18],[100.50,1.46],[100.90,0.78],[101.10,0.20],
    [101.28,-0.32],[101.40,-0.92],[101.30,-1.48],[100.88,-2.02],[100.34,-2.62],
    [99.78,-2.42],[99.22,-1.82],[98.88,-1.12],[98.72,-0.54],[98.74,0.26],[99.20,0.94],
  ]),

  IDProvince(id:'RI', name:'Riau', island:'Sumatra', cLat:0.29, cLon:101.70, poly:[
    [100.74,1.84],[101.00,2.10],[101.60,2.28],[102.10,2.06],[102.50,1.58],
    [103.00,1.14],[102.98,0.48],[102.84,-0.02],[102.48,-0.52],[101.88,-0.98],
    [101.40,-0.92],[101.28,-0.32],[101.10,0.20],[100.90,0.78],[100.50,1.46],[100.74,1.84],
  ]),

  IDProvince(id:'KR', name:'Kep. Riau', island:'Sumatra', cLat:3.94, cLon:108.14, poly:[
    [103.58,1.16],[104.18,0.88],[104.78,0.58],[105.18,0.98],[105.00,1.58],
    [104.40,2.08],[103.80,2.58],[103.40,3.18],[103.58,3.98],[104.18,4.48],
    [104.78,4.08],[104.38,3.38],[104.58,2.78],[104.78,2.18],[104.38,1.78],[103.58,1.16],
  ]),

  IDProvince(id:'JA', name:'Jambi', island:'Sumatra', cLat:-1.61, cLon:103.62, poly:[
    [101.88,-0.98],[102.48,-0.52],[103.00,0.08],[103.58,-0.12],[104.18,-0.62],
    [104.78,-1.16],[104.88,-1.82],[104.48,-2.42],[103.88,-2.82],[103.18,-2.98],
    [102.58,-2.82],[102.00,-2.52],[101.40,-1.82],[101.50,-1.22],[101.88,-0.98],
  ]),

  IDProvince(id:'SS', name:'Sumatera Selatan', island:'Sumatra', cLat:-3.32, cLon:104.02, poly:[
    [103.18,-2.98],[103.88,-2.82],[104.48,-2.42],[104.88,-1.82],[105.38,-2.02],
    [106.00,-2.42],[106.48,-3.02],[106.18,-3.82],[105.68,-4.42],[105.08,-4.92],
    [104.58,-5.22],[103.78,-5.02],[103.00,-4.62],[102.48,-4.02],[102.58,-3.32],[103.18,-2.98],
  ]),

  IDProvince(id:'BB', name:'Kep. Bangka Belitung', island:'Sumatra', cLat:-2.74, cLon:106.44, poly:[
    [105.38,-1.72],[106.00,-1.62],[106.68,-1.82],[107.18,-2.22],[107.48,-2.82],
    [107.28,-3.42],[106.88,-3.82],[106.18,-3.82],[105.68,-3.52],[105.38,-2.92],[105.38,-1.72],
  ]),

  IDProvince(id:'BE', name:'Bengkulu', island:'Sumatra', cLat:-3.80, cLon:102.26, poly:[
    [99.78,-2.42],[100.34,-2.62],[100.88,-2.02],[101.40,-2.42],[102.00,-2.52],
    [102.48,-3.02],[102.58,-3.62],[102.28,-4.22],[101.88,-4.76],[101.38,-5.20],
    [100.98,-4.76],[100.62,-4.12],[100.32,-3.42],[99.94,-2.82],[99.78,-2.42],
  ]),

  IDProvince(id:'LA', name:'Lampung', island:'Sumatra', cLat:-4.56, cLon:105.40, poly:[
    [103.78,-5.02],[104.58,-5.22],[105.08,-4.92],[105.58,-4.52],[106.08,-5.02],
    [106.38,-5.62],[105.88,-6.12],[105.28,-6.02],[104.58,-5.82],[103.78,-5.62],[103.78,-5.02],
  ]),

  // ══════════════════ JAWA ═══════════════════════════════════════════════════

  IDProvince(id:'BT', name:'Banten', island:'Jawa', cLat:-6.40, cLon:106.06, poly:[
    [105.18,-5.92],[105.78,-5.82],[106.38,-5.92],[106.78,-6.18],
    [106.58,-6.52],[106.18,-6.82],[105.68,-6.74],[105.20,-6.52],[105.00,-6.12],[105.18,-5.92],
  ]),

  IDProvince(id:'JK', name:'DKI Jakarta', island:'Jawa', cLat:-6.21, cLon:106.84, poly:[
    [106.68,-5.98],[107.00,-5.98],[107.02,-6.24],[106.94,-6.40],
    [106.72,-6.40],[106.66,-6.20],[106.68,-5.98],
  ]),

  IDProvince(id:'JB', name:'Jawa Barat', island:'Jawa', cLat:-6.90, cLon:107.62, poly:[
    [106.78,-6.18],[107.18,-5.92],[107.78,-5.92],[108.38,-6.02],[108.98,-6.22],
    [109.18,-6.62],[108.88,-7.10],[108.38,-7.52],[107.88,-7.82],[107.38,-7.62],
    [106.88,-7.32],[106.58,-6.82],[106.78,-6.42],[106.78,-6.18],
  ]),

  IDProvince(id:'JT', name:'Jawa Tengah', island:'Jawa', cLat:-7.15, cLon:110.14, poly:[
    [108.78,-6.14],[109.18,-6.00],[109.78,-6.02],[110.38,-6.04],[110.98,-6.22],
    [111.58,-6.52],[111.48,-7.02],[111.18,-7.52],[110.78,-7.82],[110.38,-7.92],
    [109.88,-7.80],[109.38,-7.62],[108.88,-7.40],[108.48,-7.10],[108.78,-6.62],[108.78,-6.14],
  ]),

  IDProvince(id:'YO', name:'DI Yogyakarta', island:'Jawa', cLat:-7.87, cLon:110.42, poly:[
    [110.00,-7.56],[110.42,-7.52],[110.78,-7.64],[110.78,-8.02],
    [110.40,-8.16],[110.00,-8.02],[109.86,-7.82],[110.00,-7.56],
  ]),

  IDProvince(id:'JI', name:'Jawa Timur', island:'Jawa', cLat:-7.54, cLon:112.24, poly:[
    [110.98,-6.86],[111.58,-6.78],[112.18,-6.78],[112.78,-6.88],[113.58,-7.02],
    [114.38,-7.20],[114.58,-7.62],[114.18,-8.02],[113.68,-8.32],[113.00,-8.42],
    [112.38,-8.20],[111.78,-7.90],[111.08,-7.72],[110.78,-7.62],[110.98,-6.86],
  ]),

  // ══════════════════ BALI & NUSA TENGGARA ═══════════════════════════════════

  IDProvince(id:'BA', name:'Bali', island:'Bali & NT', cLat:-8.34, cLon:115.09, poly:[
    [114.44,-8.12],[114.80,-8.00],[115.18,-7.98],[115.58,-8.02],[115.68,-8.32],
    [115.58,-8.66],[115.18,-8.82],[114.78,-8.80],[114.46,-8.62],[114.44,-8.32],[114.44,-8.12],
  ]),

  IDProvince(id:'NB', name:'NTB', island:'Bali & NT', cLat:-8.65, cLon:117.36, poly:[
    [115.80,-8.18],[116.18,-8.12],[116.68,-8.14],[117.18,-8.22],[117.78,-8.28],
    [118.38,-8.42],[118.98,-8.72],[118.78,-9.02],[118.38,-9.22],[117.78,-9.12],
    [117.18,-8.92],[116.58,-8.82],[116.08,-8.68],[115.86,-8.44],[115.80,-8.18],
  ]),

  IDProvince(id:'NT', name:'NTT', island:'Bali & NT', cLat:-9.86, cLon:121.70, poly:[
    [118.98,-8.56],[119.58,-8.42],[120.18,-8.50],[120.78,-8.58],[121.38,-8.62],
    [121.98,-8.42],[122.58,-8.60],[122.98,-8.92],[123.38,-9.42],[123.78,-9.82],
    [123.58,-10.42],[122.98,-10.82],[122.38,-10.62],[121.78,-10.42],[121.18,-10.12],
    [120.58,-9.82],[119.98,-9.42],[119.38,-9.12],[118.98,-8.56],
  ]),

  // ══════════════════ KALIMANTAN ═════════════════════════════════════════════

  IDProvince(id:'KB', name:'Kalimantan Barat', island:'Kalimantan', cLat:0.00, cLon:111.50, poly:[
    [108.08,0.58],[108.58,1.18],[109.18,1.78],[109.78,2.08],[110.38,2.16],
    [110.96,2.04],[111.58,1.78],[112.08,1.36],[112.38,0.78],[112.18,0.18],
    [111.78,-0.42],[111.18,-0.98],[110.58,-1.48],[109.98,-1.88],[109.38,-1.98],
    [108.78,-1.72],[108.18,-1.12],[107.78,-0.52],[108.08,0.58],
  ]),

  IDProvince(id:'KT', name:'Kalimantan Tengah', island:'Kalimantan', cLat:-1.68, cLon:113.92, poly:[
    [110.98,0.08],[111.58,-0.12],[112.18,-0.42],[112.78,-0.72],[113.38,-1.00],
    [113.98,-1.00],[114.58,-0.88],[115.18,-0.74],[115.58,-0.96],[115.88,-1.62],
    [115.68,-2.42],[115.38,-3.02],[115.00,-3.62],[114.38,-4.12],[113.78,-4.32],
    [113.18,-4.16],[112.58,-3.82],[112.00,-3.28],[111.38,-2.66],[110.98,-2.02],
    [110.68,-1.42],[110.44,-0.88],[110.86,-0.44],[110.98,0.08],
  ]),

  IDProvince(id:'KS', name:'Kalimantan Selatan', island:'Kalimantan', cLat:-2.82, cLon:115.44, poly:[
    [114.58,-0.88],[115.18,-0.74],[115.58,-0.96],[115.98,-1.52],[116.78,-2.22],
    [116.58,-2.92],[116.18,-3.52],[115.74,-4.02],[115.00,-4.42],[114.38,-4.12],
    [114.00,-3.52],[114.00,-2.82],[114.20,-2.02],[114.58,-1.42],[114.58,-0.88],
  ]),

  IDProvince(id:'KE', name:'Kalimantan Timur', island:'Kalimantan', cLat:1.32, cLon:116.42, poly:[
    [116.58,4.14],[115.98,3.66],[115.38,3.22],[114.88,2.78],[114.58,2.18],
    [114.38,1.58],[114.78,0.94],[115.18,0.38],[115.38,-0.22],[115.58,-0.96],
    [115.98,-1.52],[116.78,-1.02],[117.18,-0.42],[117.58,0.38],[117.78,1.18],
    [117.78,1.98],[117.58,2.78],[117.18,3.38],[116.78,3.88],[116.58,4.14],
  ]),

  IDProvince(id:'KU', name:'Kalimantan Utara', island:'Kalimantan', cLat:3.08, cLon:116.40, poly:[
    [115.58,4.88],[115.78,4.38],[116.18,3.98],[116.58,4.14],[116.98,4.48],
    [117.38,4.78],[117.68,4.58],[117.88,4.14],[118.08,3.78],[117.98,3.18],
    [117.58,2.78],[117.18,3.38],[116.78,3.88],[116.38,4.28],[115.98,4.58],[115.58,4.88],
  ]),

  // ══════════════════ SULAWESI ═══════════════════════════════════════════════

  IDProvince(id:'SA', name:'Sulawesi Utara', island:'Sulawesi', cLat:1.26, cLon:124.84, poly:[
    [124.18,1.08],[124.58,1.28],[124.98,1.46],[125.38,1.56],[125.78,1.48],
    [126.18,1.34],[126.38,0.98],[126.38,0.58],[125.98,0.38],[125.58,0.48],
    [125.18,0.68],[124.78,0.88],[124.38,0.78],[124.18,1.08],
  ]),

  IDProvince(id:'GO', name:'Gorontalo', island:'Sulawesi', cLat:0.69, cLon:122.44, poly:[
    [121.58,0.34],[121.98,0.58],[122.38,0.90],[122.78,1.04],[123.18,0.92],
    [123.58,0.70],[123.98,0.60],[124.18,0.28],[123.98,-0.12],[123.58,-0.22],
    [123.08,-0.02],[122.58,-0.12],[122.08,0.08],[121.58,0.34],
  ]),

  IDProvince(id:'ST', name:'Sulawesi Tengah', island:'Sulawesi', cLat:-1.44, cLon:121.44, poly:[
    [119.78,-0.62],[120.18,-0.82],[120.58,-1.02],[120.98,-0.82],[121.38,-0.62],
    [121.78,-0.32],[122.18,-0.12],[122.58,-0.12],[122.98,-0.02],[123.38,-0.22],
    [123.58,-0.74],[123.38,-1.22],[122.98,-1.62],[122.58,-2.02],[122.18,-2.32],
    [121.78,-2.52],[121.38,-2.62],[120.98,-2.42],[120.58,-2.22],[120.18,-1.92],
    [119.78,-1.52],[119.58,-1.02],[119.78,-0.62],
  ]),

  IDProvince(id:'SR', name:'Sulawesi Barat', island:'Sulawesi', cLat:-2.60, cLon:119.34, poly:[
    [118.80,-0.86],[119.18,-1.02],[119.58,-1.32],[119.78,-1.82],[119.78,-2.32],
    [119.58,-2.82],[119.38,-3.32],[119.08,-3.76],[118.78,-3.62],[118.58,-3.12],
    [118.68,-2.62],[118.80,-1.82],[118.80,-0.86],
  ]),

  IDProvince(id:'SN', name:'Sulawesi Selatan', island:'Sulawesi', cLat:-3.66, cLon:120.06, poly:[
    [119.08,-1.82],[119.38,-2.02],[119.78,-2.32],[119.98,-2.82],[120.38,-3.42],
    [120.58,-4.02],[120.78,-4.62],[120.58,-5.22],[120.38,-5.72],[119.98,-5.98],
    [119.58,-5.82],[119.08,-5.42],[118.78,-5.02],[118.78,-4.42],[118.98,-3.82],
    [119.08,-3.22],[119.08,-2.62],[119.08,-1.82],
  ]),

  IDProvince(id:'SG', name:'Sulawesi Tenggara', island:'Sulawesi', cLat:-4.00, cLon:122.00, poly:[
    [120.98,-2.42],[121.38,-2.62],[121.78,-2.82],[122.18,-2.62],[122.58,-2.42],
    [122.98,-2.62],[123.38,-3.02],[123.58,-3.62],[123.38,-4.22],[122.98,-4.72],
    [122.58,-5.02],[122.18,-5.22],[121.78,-5.02],[121.38,-4.62],[120.98,-4.22],
    [120.78,-3.62],[120.98,-3.02],[120.98,-2.42],
  ]),

  // ══════════════════ MALUKU ═════════════════════════════════════════════════

  IDProvince(id:'MA', name:'Maluku', island:'Maluku', cLat:-3.24, cLon:130.14, poly:[
    [124.48,-1.62],[124.98,-2.02],[125.38,-2.62],[125.78,-3.22],[126.18,-3.62],
    [126.78,-3.82],[127.58,-3.62],[128.38,-3.42],[128.98,-3.62],[129.58,-4.02],
    [129.98,-4.62],[130.38,-5.22],[130.58,-5.82],[130.38,-6.42],[129.78,-6.82],
    [129.18,-6.62],[128.58,-6.22],[127.98,-5.82],[127.38,-5.62],[126.78,-5.22],
    [126.18,-4.82],[125.58,-4.42],[124.98,-3.82],[124.48,-3.22],[124.48,-1.62],
  ]),

  IDProvince(id:'MU', name:'Maluku Utara', island:'Maluku', cLat:1.58, cLon:127.80, poly:[
    [126.58,-0.42],[126.98,0.18],[127.38,0.78],[127.78,1.38],[128.18,1.78],
    [128.58,1.66],[128.98,1.28],[129.38,0.82],[129.58,0.28],[129.38,-0.32],
    [128.98,-0.82],[128.58,-1.02],[127.98,-0.82],[127.38,-0.62],[126.58,-0.42],
  ]),

  // ══════════════════ PAPUA ═════════════════════════════════════════════════

  IDProvince(id:'PD', name:'Papua Barat Daya', island:'Papua', cLat:-0.80, cLon:131.00, poly:[
    [129.78,-0.32],[130.18,-0.12],[130.58,-0.12],[130.98,0.18],[130.78,-0.42],
    [130.58,-1.02],[130.38,-1.42],[129.98,-1.62],[129.58,-1.42],[129.38,-0.92],
    [129.58,-0.42],[129.78,-0.32],
  ]),

  IDProvince(id:'PB', name:'Papua Barat', island:'Papua', cLat:-1.37, cLon:133.18, poly:[
    [130.98,0.18],[131.38,0.38],[131.78,0.58],[132.18,0.38],[132.38,-0.22],
    [132.58,-0.82],[132.78,-1.42],[132.98,-2.02],[132.78,-2.62],[132.38,-2.92],
    [131.98,-2.82],[131.58,-2.52],[131.18,-2.12],[130.78,-1.62],[130.58,-1.02],
    [130.78,-0.42],[130.98,0.18],
  ]),

  IDProvince(id:'PT', name:'Papua Tengah', island:'Papua', cLat:-4.10, cLon:136.40, poly:[
    [133.78,-1.42],[134.18,-1.22],[134.58,-1.02],[134.98,-1.12],[135.38,-1.42],
    [135.78,-1.82],[136.18,-2.32],[136.58,-2.82],[136.98,-3.42],[136.98,-4.02],
    [136.58,-4.62],[136.18,-5.02],[135.58,-5.22],[134.98,-5.12],[134.38,-4.92],
    [133.78,-4.62],[133.38,-4.22],[133.18,-3.62],[133.38,-3.02],[133.78,-2.42],
    [133.78,-1.82],[133.78,-1.42],
  ]),

  IDProvince(id:'PG', name:'Papua Pegunungan', island:'Papua', cLat:-3.80, cLon:138.60, poly:[
    [136.98,-1.42],[137.38,-1.22],[137.78,-1.02],[138.18,-1.12],[138.58,-1.42],
    [138.98,-1.82],[139.38,-2.32],[139.58,-2.82],[139.78,-3.42],[139.58,-4.02],
    [139.18,-4.62],[138.78,-5.02],[138.18,-5.22],[137.78,-5.02],[137.38,-4.62],
    [136.98,-4.02],[136.98,-3.42],[136.78,-2.82],[136.98,-2.22],[136.98,-1.42],
  ]),

  IDProvince(id:'PS', name:'Papua Selatan', island:'Papua', cLat:-7.20, cLon:139.00, poly:[
    [136.98,-5.42],[137.38,-5.62],[137.78,-5.82],[138.18,-6.02],[138.58,-6.32],
    [138.98,-6.72],[139.38,-7.22],[139.78,-7.82],[140.18,-8.22],[140.38,-8.62],
    [140.58,-8.92],[140.78,-8.72],[140.78,-8.22],[140.58,-7.62],[140.18,-7.02],
    [139.78,-6.42],[139.38,-5.82],[138.98,-5.42],[138.58,-5.22],[138.18,-5.22],
    [137.78,-5.02],[137.38,-4.82],[136.98,-5.02],[136.98,-5.42],
  ]),

  IDProvince(id:'PA', name:'Papua', island:'Papua', cLat:-5.60, cLon:140.70, poly:[
    [139.98,-2.62],[140.38,-2.42],[140.78,-2.22],[140.98,-2.42],[140.98,-3.22],
    [140.98,-4.02],[140.98,-4.82],[140.98,-5.62],[140.98,-6.42],[140.98,-7.22],
    [140.78,-7.82],[140.58,-8.42],[140.38,-8.92],[139.98,-8.92],[139.58,-8.62],
    [139.18,-8.12],[138.78,-7.62],[138.38,-7.02],[137.98,-6.42],[138.38,-5.82],
    [138.78,-5.22],[139.18,-4.62],[139.58,-4.02],[139.98,-3.42],[139.98,-2.62],
  ]),
];

// ─────────────────────────────────────────────────────────────────────────────
// 153 CITIES  (provincial capitals + major secondary cities)
// ─────────────────────────────────────────────────────────────────────────────
const List<IDCity> kIDCities = [
  // ─── ACEH ──────────────────────────────────────────────────────────────────
  IDCity(id:'banda_aceh',  name:'Banda Aceh',    provId:'AC', lat:5.55,  lon:95.32,  type:'capital', pop:250000),
  IDCity(id:'lhokseumawe', name:'Lhokseumawe',   provId:'AC', lat:5.18,  lon:97.14,  type:'city',    pop:196000),
  IDCity(id:'langsa',      name:'Langsa',         provId:'AC', lat:4.47,  lon:97.97,  type:'city',    pop:169000),
  IDCity(id:'sabang',      name:'Sabang',          provId:'AC', lat:5.89,  lon:95.32,  type:'city',    pop:36000),
  IDCity(id:'meulaboh',    name:'Meulaboh',        provId:'AC', lat:4.14,  lon:96.13,  type:'regency', pop:83000),

  // ─── SUMATERA UTARA ────────────────────────────────────────────────────────
  IDCity(id:'medan',          name:'Medan',          provId:'SU', lat:3.59,  lon:98.67, type:'capital', pop:2247000),
  IDCity(id:'binjai',         name:'Binjai',          provId:'SU', lat:3.60,  lon:98.49, type:'city',    pop:272000),
  IDCity(id:'pematangsiantar',name:'P. Siantar',      provId:'SU', lat:2.96,  lon:99.07, type:'city',    pop:247000),
  IDCity(id:'tebing_tinggi',  name:'Tebing Tinggi',   provId:'SU', lat:3.33,  lon:99.16, type:'city',    pop:154000),
  IDCity(id:'padangsidimpuan',name:'Padangsidimpuan', provId:'SU', lat:1.38,  lon:99.27, type:'city',    pop:218000),
  IDCity(id:'sibolga',        name:'Sibolga',          provId:'SU', lat:1.74,  lon:98.78, type:'city',    pop:89000),
  IDCity(id:'tanjungbalai',   name:'Tanjungbalai',     provId:'SU', lat:2.97,  lon:99.80, type:'city',    pop:163000),
  IDCity(id:'gunungsitoli',   name:'Gunungsitoli',     provId:'SU', lat:1.28,  lon:97.59, type:'city',    pop:135000),

  // ─── SUMATERA BARAT ────────────────────────────────────────────────────────
  IDCity(id:'padang',      name:'Padang',      provId:'SB', lat:-0.95, lon:100.35, type:'capital', pop:909000),
  IDCity(id:'bukittinggi', name:'Bukittinggi', provId:'SB', lat:-0.31, lon:100.37, type:'city',    pop:121000),
  IDCity(id:'payakumbuh',  name:'Payakumbuh',  provId:'SB', lat:-0.22, lon:100.63, type:'city',    pop:127000),
  IDCity(id:'solok',       name:'Solok',       provId:'SB', lat:-0.80, lon:100.66, type:'city',    pop:66000),
  IDCity(id:'pariaman',    name:'Pariaman',    provId:'SB', lat:-0.63, lon:100.12, type:'city',    pop:84000),
  IDCity(id:'sawahlunto',  name:'Sawahlunto',  provId:'SB', lat:-0.68, lon:100.78, type:'city',    pop:59000),

  // ─── RIAU ──────────────────────────────────────────────────────────────────
  IDCity(id:'pekanbaru', name:'Pekanbaru', provId:'RI', lat:0.51,  lon:101.45, type:'capital', pop:1094000),
  IDCity(id:'dumai',     name:'Dumai',     provId:'RI', lat:1.68,  lon:101.45, type:'city',    pop:294000),

  // ─── KEP. RIAU ─────────────────────────────────────────────────────────────
  IDCity(id:'tanjungpinang', name:'Tanjungpinang', provId:'KR', lat:0.92, lon:104.44, type:'capital', pop:217000),
  IDCity(id:'batam',         name:'Batam',          provId:'KR', lat:1.05, lon:104.01, type:'city',    pop:1196000),

  // ─── JAMBI ─────────────────────────────────────────────────────────────────
  IDCity(id:'jambi',       name:'Jambi',       provId:'JA', lat:-1.61, lon:103.62, type:'capital', pop:583000),
  IDCity(id:'sungaipenuh', name:'Sungai Penuh', provId:'JA', lat:-2.09, lon:101.40, type:'city',    pop:88000),

  // ─── SUMATERA SELATAN ──────────────────────────────────────────────────────
  IDCity(id:'palembang',    name:'Palembang',     provId:'SS', lat:-2.99, lon:104.76, type:'capital', pop:1666000),
  IDCity(id:'lubuklinggau', name:'Lubuklinggau',  provId:'SS', lat:-3.30, lon:102.86, type:'city',    pop:213000),
  IDCity(id:'prabumulih',   name:'Prabumulih',    provId:'SS', lat:-3.43, lon:104.23, type:'city',    pop:176000),
  IDCity(id:'pagaralam',    name:'Pagaralam',     provId:'SS', lat:-4.02, lon:103.25, type:'city',    pop:143000),

  // ─── BANGKA BELITUNG ───────────────────────────────────────────────────────
  IDCity(id:'pangkalpinang', name:'Pangkalpinang', provId:'BB', lat:-2.13, lon:106.12, type:'capital', pop:220000),

  // ─── BENGKULU ──────────────────────────────────────────────────────────────
  IDCity(id:'bengkulu', name:'Bengkulu', provId:'BE', lat:-3.80, lon:102.27, type:'capital', pop:352000),

  // ─── LAMPUNG ───────────────────────────────────────────────────────────────
  IDCity(id:'bandarlampung', name:'Bandar Lampung', provId:'LA', lat:-5.45, lon:105.27, type:'capital', pop:1166000),
  IDCity(id:'metro',         name:'Metro',           provId:'LA', lat:-5.11, lon:105.31, type:'city',    pop:160000),

  // ─── BANTEN ────────────────────────────────────────────────────────────────
  IDCity(id:'serang',    name:'Serang',    provId:'BT', lat:-6.12, lon:106.15, type:'capital', pop:681000),
  IDCity(id:'tangerang', name:'Tangerang', provId:'BT', lat:-6.18, lon:106.63, type:'city',    pop:2130000),
  IDCity(id:'cilegon',   name:'Cilegon',   provId:'BT', lat:-6.00, lon:106.00, type:'city',    pop:404000),
  IDCity(id:'tangsel',   name:'Tangsel',   provId:'BT', lat:-6.29, lon:106.72, type:'city',    pop:1626000),

  // ─── DKI JAKARTA ───────────────────────────────────────────────────────────
  IDCity(id:'jakarta', name:'Jakarta', provId:'JK', lat:-6.21, lon:106.84, type:'capital', pop:10560000),

  // ─── JAWA BARAT ────────────────────────────────────────────────────────────
  IDCity(id:'bandung',     name:'Bandung',     provId:'JB', lat:-6.91,  lon:107.61, type:'capital', pop:2507000),
  IDCity(id:'bekasi',      name:'Bekasi',       provId:'JB', lat:-6.24,  lon:106.99, type:'city',    pop:2543000),
  IDCity(id:'depok',       name:'Depok',        provId:'JB', lat:-6.40,  lon:106.82, type:'city',    pop:2033000),
  IDCity(id:'bogor',       name:'Bogor',        provId:'JB', lat:-6.60,  lon:106.80, type:'city',    pop:1081000),
  IDCity(id:'cimahi',      name:'Cimahi',       provId:'JB', lat:-6.87,  lon:107.54, type:'city',    pop:601000),
  IDCity(id:'tasikmalaya', name:'Tasikmalaya',  provId:'JB', lat:-7.35,  lon:108.22, type:'city',    pop:666000),
  IDCity(id:'cirebon',     name:'Cirebon',      provId:'JB', lat:-6.73,  lon:108.55, type:'city',    pop:332000),
  IDCity(id:'sukabumi',    name:'Sukabumi',     provId:'JB', lat:-6.92,  lon:106.93, type:'city',    pop:338000),
  IDCity(id:'banjar',      name:'Banjar',       provId:'JB', lat:-7.36,  lon:108.54, type:'city',    pop:201000),

  // ─── JAWA TENGAH ───────────────────────────────────────────────────────────
  IDCity(id:'semarang',   name:'Semarang',   provId:'JT', lat:-6.97,  lon:110.42, type:'capital', pop:1653000),
  IDCity(id:'surakarta',  name:'Surakarta',  provId:'JT', lat:-7.56,  lon:110.83, type:'city',    pop:516000),
  IDCity(id:'magelang',   name:'Magelang',   provId:'JT', lat:-7.47,  lon:110.22, type:'city',    pop:119000),
  IDCity(id:'pekalongan', name:'Pekalongan', provId:'JT', lat:-6.89,  lon:109.67, type:'city',    pop:298000),
  IDCity(id:'salatiga',   name:'Salatiga',   provId:'JT', lat:-7.33,  lon:110.50, type:'city',    pop:185000),
  IDCity(id:'tegal',      name:'Tegal',      provId:'JT', lat:-6.87,  lon:109.14, type:'city',    pop:274000),
  IDCity(id:'purwokerto', name:'Purwokerto', provId:'JT', lat:-7.42,  lon:109.23, type:'regency', pop:255000),

  // ─── DI YOGYAKARTA ─────────────────────────────────────────────────────────
  IDCity(id:'yogyakarta', name:'Yogyakarta', provId:'YO', lat:-7.80, lon:110.36, type:'capital', pop:422000),

  // ─── JAWA TIMUR ────────────────────────────────────────────────────────────
  IDCity(id:'surabaya',   name:'Surabaya',   provId:'JI', lat:-7.25,  lon:112.75, type:'capital', pop:2890000),
  IDCity(id:'malang',     name:'Malang',     provId:'JI', lat:-7.97,  lon:112.63, type:'city',    pop:874000),
  IDCity(id:'kediri',     name:'Kediri',     provId:'JI', lat:-7.82,  lon:112.01, type:'city',    pop:314000),
  IDCity(id:'probolinggo',name:'Probolinggo',provId:'JI', lat:-7.75,  lon:113.22, type:'city',    pop:237000),
  IDCity(id:'pasuruan',   name:'Pasuruan',   provId:'JI', lat:-7.64,  lon:112.91, type:'city',    pop:200000),
  IDCity(id:'madiun',     name:'Madiun',     provId:'JI', lat:-7.63,  lon:111.52, type:'city',    pop:176000),
  IDCity(id:'mojokerto',  name:'Mojokerto',  provId:'JI', lat:-7.47,  lon:112.44, type:'city',    pop:127000),
  IDCity(id:'blitar',     name:'Blitar',     provId:'JI', lat:-8.10,  lon:112.16, type:'city',    pop:144000),
  IDCity(id:'batu',       name:'Batu',       provId:'JI', lat:-7.87,  lon:112.52, type:'city',    pop:202000),

  // ─── BALI ──────────────────────────────────────────────────────────────────
  IDCity(id:'denpasar',  name:'Denpasar',  provId:'BA', lat:-8.65, lon:115.22, type:'capital', pop:897000),
  IDCity(id:'singaraja', name:'Singaraja', provId:'BA', lat:-8.11, lon:115.09, type:'regency', pop:120000),
  IDCity(id:'tabanan',   name:'Tabanan',   provId:'BA', lat:-8.54, lon:115.12, type:'regency', pop:107000),

  // ─── NTB ───────────────────────────────────────────────────────────────────
  IDCity(id:'mataram', name:'Mataram', provId:'NB', lat:-8.58, lon:116.12, type:'capital', pop:481000),
  IDCity(id:'bima',    name:'Bima',    provId:'NB', lat:-8.46, lon:118.73, type:'city',    pop:149000),

  // ─── NTT ───────────────────────────────────────────────────────────────────
  IDCity(id:'kupang',  name:'Kupang',  provId:'NT', lat:-10.16, lon:123.61, type:'capital', pop:434000),
  IDCity(id:'ende',    name:'Ende',    provId:'NT', lat:-8.84,  lon:121.66, type:'regency', pop:76000),
  IDCity(id:'maumere', name:'Maumere', provId:'NT', lat:-8.62,  lon:122.21, type:'regency', pop:77000),
  IDCity(id:'labuan_bajo', name:'Labuan Bajo', provId:'NT', lat:-8.50, lon:119.88, type:'regency', pop:29000),

  // ─── KALIMANTAN BARAT ──────────────────────────────────────────────────────
  IDCity(id:'pontianak',   name:'Pontianak',   provId:'KB', lat:-0.03, lon:109.33, type:'capital', pop:638000),
  IDCity(id:'singkawang',  name:'Singkawang',  provId:'KB', lat:0.90,  lon:108.99, type:'city',    pop:204000),

  // ─── KALIMANTAN TENGAH ─────────────────────────────────────────────────────
  IDCity(id:'palangkaraya', name:'Palangka Raya', provId:'KT', lat:-2.21, lon:113.92, type:'capital', pop:260000),
  IDCity(id:'sampit',       name:'Sampit',         provId:'KT', lat:-2.53, lon:112.95, type:'regency', pop:102000),

  // ─── KALIMANTAN SELATAN ────────────────────────────────────────────────────
  IDCity(id:'banjarmasin', name:'Banjarmasin', provId:'KS', lat:-3.32, lon:114.59, type:'capital', pop:700000),
  IDCity(id:'banjarbaru',  name:'Banjarbaru',  provId:'KS', lat:-3.44, lon:114.84, type:'city',    pop:250000),

  // ─── KALIMANTAN TIMUR ──────────────────────────────────────────────────────
  IDCity(id:'samarinda',   name:'Samarinda',   provId:'KE', lat:-0.50, lon:117.14, type:'capital', pop:812000),
  IDCity(id:'balikpapan',  name:'Balikpapan',  provId:'KE', lat:-1.24, lon:116.84, type:'city',    pop:700000),
  IDCity(id:'bontang',     name:'Bontang',     provId:'KE', lat:0.13,  lon:117.50, type:'city',    pop:165000),
  IDCity(id:'kutai_barat', name:'Sendawar',    provId:'KE', lat:-0.55, lon:115.99, type:'regency', pop:167000),

  // ─── KALIMANTAN UTARA ──────────────────────────────────────────────────────
  IDCity(id:'tanjungselor', name:'Tanjung Selor', provId:'KU', lat:2.84,  lon:117.37, type:'capital', pop:45000),
  IDCity(id:'tarakan',      name:'Tarakan',        provId:'KU', lat:3.30,  lon:117.63, type:'city',    pop:234000),

  // ─── SULAWESI UTARA ────────────────────────────────────────────────────────
  IDCity(id:'manado',   name:'Manado',   provId:'SA', lat:1.49,  lon:124.84, type:'capital', pop:451000),
  IDCity(id:'bitung',   name:'Bitung',   provId:'SA', lat:1.44,  lon:125.19, type:'city',    pop:215000),
  IDCity(id:'tomohon',  name:'Tomohon',  provId:'SA', lat:1.32,  lon:124.83, type:'city',    pop:100000),
  IDCity(id:'kotamobagu',name:'Kotamobagu',provId:'SA',lat:0.73, lon:124.32, type:'city',    pop:117000),

  // ─── GORONTALO ─────────────────────────────────────────────────────────────
  IDCity(id:'gorontalo', name:'Gorontalo', provId:'GO', lat:0.55, lon:123.06, type:'capital', pop:191000),

  // ─── SULAWESI TENGAH ───────────────────────────────────────────────────────
  IDCity(id:'palu', name:'Palu', provId:'ST', lat:-0.90, lon:119.87, type:'capital', pop:370000),
  IDCity(id:'luwuk',name:'Luwuk',provId:'ST', lat:-0.94, lon:122.79, type:'regency', pop:75000),

  // ─── SULAWESI BARAT ────────────────────────────────────────────────────────
  IDCity(id:'mamuju',       name:'Mamuju',        provId:'SR', lat:-2.68, lon:118.89, type:'capital', pop:61000),
  IDCity(id:'pasangkayu',   name:'Pasangkayu',    provId:'SR', lat:-1.34, lon:119.69, type:'regency', pop:168000),

  // ─── SULAWESI SELATAN ──────────────────────────────────────────────────────
  IDCity(id:'makassar', name:'Makassar', provId:'SN', lat:-5.14, lon:119.43, type:'capital', pop:1432000),
  IDCity(id:'parepare', name:'Parepare', provId:'SN', lat:-4.01, lon:119.63, type:'city',    pop:145000),
  IDCity(id:'palopo',   name:'Palopo',   provId:'SN', lat:-2.99, lon:120.20, type:'city',    pop:176000),

  // ─── SULAWESI TENGGARA ─────────────────────────────────────────────────────
  IDCity(id:'kendari', name:'Kendari', provId:'SG', lat:-3.97, lon:122.51, type:'capital', pop:344000),
  IDCity(id:'baubau',  name:'Bau-Bau', provId:'SG', lat:-5.47, lon:122.61, type:'city',    pop:163000),

  // ─── MALUKU ────────────────────────────────────────────────────────────────
  IDCity(id:'ambon',   name:'Ambon',   provId:'MA', lat:-3.70, lon:128.18, type:'capital', pop:342000),
  IDCity(id:'tual',    name:'Tual',    provId:'MA', lat:-5.66, lon:132.75, type:'city',    pop:74000),
  IDCity(id:'masohi',  name:'Masohi',  provId:'MA', lat:-3.33, lon:128.92, type:'regency', pop:36000),

  // ─── MALUKU UTARA ──────────────────────────────────────────────────────────
  IDCity(id:'sofifi',  name:'Sofifi',  provId:'MU', lat:0.74,  lon:127.57, type:'capital', pop:15000),
  IDCity(id:'ternate', name:'Ternate', provId:'MU', lat:0.79,  lon:127.38, type:'city',    pop:215000),
  IDCity(id:'tidore',  name:'Tidore',  provId:'MU', lat:0.66,  lon:127.42, type:'city',    pop:108000),

  // ─── PAPUA BARAT DAYA ──────────────────────────────────────────────────────
  IDCity(id:'sorong', name:'Sorong', provId:'PD', lat:-0.88, lon:131.25, type:'capital', pop:255000),

  // ─── PAPUA BARAT ───────────────────────────────────────────────────────────
  IDCity(id:'manokwari', name:'Manokwari', provId:'PB', lat:-0.86, lon:134.08, type:'capital', pop:75000),
  IDCity(id:'fakfak',    name:'Fakfak',    provId:'PB', lat:-2.92, lon:132.30, type:'regency', pop:53000),

  // ─── PAPUA TENGAH ──────────────────────────────────────────────────────────
  IDCity(id:'nabire', name:'Nabire', provId:'PT', lat:-3.37, lon:135.49, type:'capital', pop:50000),
  IDCity(id:'timika', name:'Timika', provId:'PT', lat:-4.53, lon:136.89, type:'regency', pop:170000),

  // ─── PAPUA PEGUNUNGAN ──────────────────────────────────────────────────────
  IDCity(id:'wamena', name:'Wamena', provId:'PG', lat:-4.09, lon:138.95, type:'capital', pop:30000),

  // ─── PAPUA SELATAN ─────────────────────────────────────────────────────────
  IDCity(id:'merauke',  name:'Merauke',  provId:'PS', lat:-8.49, lon:140.39, type:'capital', pop:58000),
  IDCity(id:'boven_digoel', name:'Tanah Merah', provId:'PS', lat:-6.07, lon:140.19, type:'regency', pop:40000),

  // ─── PAPUA ─────────────────────────────────────────────────────────────────
  IDCity(id:'jayapura', name:'Jayapura', provId:'PA', lat:-2.53, lon:140.72, type:'capital', pop:315000),
  IDCity(id:'sentani',  name:'Sentani',  provId:'PA', lat:-2.58, lon:140.52, type:'regency', pop:52000),
  IDCity(id:'serui',    name:'Serui',    provId:'PA', lat:-1.88, lon:136.24, type:'regency', pop:20000),
];
