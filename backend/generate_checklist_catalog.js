const fs = require('fs');
const path = require('path');

const templates = [
  {
    id: 'CPL-HSEFEIC-01',
    docNo: 'CPL-HSEFEIC-01',
    title: 'Fire Extinguishers Inspection Checklist',
    titleUr: 'فائر ایکسٹنگوشر معائنہ چیک لسٹ',
    category: 'Fire Protection & Life Safety',
    categoryUr: 'آگ سے بچاؤ اور لائف سیفٹی',
    frequency: 'Monthly',
    frequencyUr: 'ماہانہ',
    targetZone: 'Boiler Area (Unit 1 & 2)',
    description: 'Monthly physical inspection of portable and trolley fire extinguishers (CO2 5kg/7kg/30kg/45kg, DCP 6kg/50kg, Foam 50L) across all plant sectors.',
    items: [
      {
        id: 1,
        en: 'Pressure Gauge: Needle in green zone, no glass crack or damage',
        ur: 'پریشر گیج: سوئی سبز زون میں، شیشہ درست اور کوئی نقصان نہیں',
        standard: 'Needle in operational green sector; undamaged dial glass',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Safety Pin & Tamper Seal: Pin intact, wire lead seal unbroken',
        ur: 'سیفٹی پن اور سیل: پن موجود، سیل بند اور درست حالت میں',
        standard: 'Lock pin and plastic/lead tamper seal in place and undamaged',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Discharge Hose & Horn/Nozzle: Free of cracks, rust, blockage or dry rot',
        ur: 'ڈسچارج ہوز اور نوزل: کوئی دراڑ، زنگ یا رکاوٹ موجود نہیں',
        standard: 'Clean rubber hose, flexible, discharge horn securely clamped',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Operating Handle & Lever: Smooth action, no rust, bending or deformation',
        ur: 'ہینڈل اور لیور: بغیر زنگ یا ٹیڑھے پن کے آسانی سے دبنے کے قابل',
        standard: 'Easy to grip, smooth actuation lever, anti-corrosion coating intact',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Cylinder Body & Shell: No dents, deep scratches, chemical corrosion or peeling',
        ur: 'سلنڈر کی باڈی: زنگ، ڈینٹ یا باڈی کو نقصان سے پاک',
        standard: 'Zero rust, red epoxy powder coat intact, hydro-test date within 5 yrs',
        status: 'pass'
      },
      {
        id: 6,
        en: 'Inspection Tag & QR Code: Monthly inspection card signed, punched and legible',
        ur: 'معائنہ ٹیگ: ماہانہ معائنہ کارڈ پر دستخط اور پنچ تاریخ موجود',
        standard: 'Tag visibly attached with cable tie, current month punch recorded',
        status: 'pass'
      },
      {
        id: 7,
        en: 'Mounting & Accessibility: Wall bracket secure (1.2m height), 1m clear radius',
        ur: 'تنصیب اور رسائی: 1.2 میٹر اونچائی پر مضبوط اور 1 میٹر کا راستہ صاف',
        standard: 'Unobstructed 360-degree approach; photoluminescent signage visible',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-FECC-01',
    docNo: 'CPL-FECC-01',
    title: 'Daily Fire Fighting Equipment Cleaning Checklist',
    titleUr: 'فائر فائٹنگ آلات کی روزانہ صفائی کی چیک لسٹ',
    category: 'Fire Protection & Life Safety',
    categoryUr: 'آگ سے بچاؤ اور لائف سیفٹی',
    frequency: 'Daily',
    frequencyUr: 'روزانہ',
    targetZone: 'Fuel & Bagasse Yard (BC-1 to BC-5 / JT)',
    description: 'Daily operational shift cleaning of fire equipment exposed to bagasse fibers, coal dust, and boiler ash.',
    items: [
      {
        id: 1,
        en: 'Fire Extinguishers Body Wipe: Dust, fly ash and bagasse fibers wiped clean',
        ur: 'فائر ایکسٹنگوشر باڈی کی صفائی: راکھ اور بگاس کے ریشے صاف کیے گئے',
        standard: 'Cylinders wiped down with clean cloth; operating instructions legible',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Fire Hose Cabinet (FHC) Glass & Box: Glass front polished, latch dust-free',
        ur: 'ہوز کیبنٹ شیشہ اور باکس: فرنٹ شیشہ صاف اور لاک بغیر مٹی کے',
        standard: 'Cabinet glass clear, door hinges lubricated, internal shelf clean',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Fire Hydrant Pillar & Valve Threads: Spindle cleared of fly ash, grease applied',
        ur: 'فائر ہائیڈرینٹ پلر اور چوڑی: مٹی صاف اور سپنڈل پر گریس لگی ہوئی ہے',
        standard: 'Clean hydrant barrel, spindle turns smoothly, coupling free of grit',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Landing Valves Handwheel & Bonnet: Clean handwheel, stem wipe down',
        ur: 'لینڈنگ والو ہینڈ وہیل: ہینڈ وہیل صاف اور سٹیم سے تیل/مٹی صاف',
        standard: 'Debris removed from valve seat area, handwheel turns freely',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Fire Monitor Turret & Barrel: Barrel and swivel joints freed from dirt/chaff',
        ur: 'فائر مانیٹر اور بیرل کی صفائی: روٹیشن جوڑ اور نوزل مٹی سے پاک',
        standard: 'Monitor exterior cleaned, horizontal/vertical joints free of grit',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-WFHCIC-01',
    docNo: 'CPL-WFHCIC-01',
    title: 'Weekly Fire Hose Cabinet Inventory Checklist',
    titleUr: 'ہوز کیبنٹ کی ہفتہ وار انوینٹری چیک لسٹ',
    category: 'Fire Protection & Life Safety',
    categoryUr: 'آگ سے بچاؤ اور لائف سیفٹی',
    frequency: 'Weekly',
    frequencyUr: 'ہفتہ وار',
    targetZone: 'TG Building (Steam Turbine Hall)',
    description: 'Weekly inventory and physical condition audit of internal and external fire hose cabinets.',
    items: [
      {
        id: 1,
        en: '63mm Canvas Delivery Hose: 30m length present, double jacket flaked properly',
        ur: '63 ملی میٹر کینوس ہوز پائپ: 30 میٹر مکمل لمبائی، درست طریقے سے رکھا ہوا',
        standard: 'No mold, dry rot, burns or tears; instantaneous couplings connected',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Branch Pipe & Spray Nozzle: Standard brass/gunmetal nozzle in place',
        ur: 'برانچ پائپ اور سپرے نوزل: گن میٹل نوزل موجود اور درست حالت میں',
        standard: 'Nozzle tip undamaged, coupling lugs spring back instantly',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Coupling Rubber Gaskets: Synthetic rubber washers intact on male/female ends',
        ur: 'کوپلنگ ربڑ واشر: مردانہ اور زنانہ سروں پر ربڑ واشر موجود اور لچکدار',
        standard: 'Gaskets pliable, not cracked or missing, leak-tight seal ensured',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Hydrant Spanner / Key: Heavy-duty universal hydrant wrench in holder',
        ur: 'ہائیڈرینٹ چابی / پانا: ہائیڈرینٹ کھولنے کی چابی کیبنٹ میں موجود',
        standard: 'Spanner mounted on dedicated hook inside cabinet',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Cabinet Door & Break-Glass Box: Door latch smooth, spare key in glass box',
        ur: 'کیبنٹ ڈور اور شیشہ باکس: دروازہ آسانی سے کھلتا ہے، ایمرجنسی چابی موجود',
        standard: 'Break-glass hammer and spare key intact, door swings 180 degrees',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-HSEFWDIC-01',
    docNo: 'CPL-HSEFWDIC-01',
    title: 'Fire Water Drums Inspection Checklist',
    titleUr: 'فائر واٹر ڈرمز معائنہ چیک لسٹ',
    category: 'Fire Protection & Life Safety',
    categoryUr: 'آگ سے بچاؤ اور لائف سیفٹی',
    frequency: 'Daily',
    frequencyUr: 'روزانہ',
    targetZone: 'Boiler Area (Unit 1 & 2)',
    description: 'Inspection of 200L red fire water drums and sand/water buckets on Unit-1 and Unit-2 boiler platforms (5M, 14M, 37M elevations).',
    items: [
      {
        id: 1,
        en: 'Water Level: Drum filled to 100% full capacity with clean water',
        ur: 'پانی کی سطح: ڈرم 100 فیصد صاف پانی سے بھرا ہوا ہے',
        standard: 'Water level within 50mm of rim; no stagnant smell or algal growth',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Fire Buckets Pair: 2 round-bottom galvanized steel buckets suspended on rack',
        ur: 'فائر بالٹیاں: 2 سرخ بالٹیاں ڈرم کے اوپر اسٹینڈ پر لٹکی ہوئی ہیں',
        standard: 'Buckets painted signal red with bold FIRE lettering, handles secure',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Drum Shell Integrity: No bottom rust perforation, seam leaks or bulging',
        ur: 'ڈرم باڈی: پیندے میں زنگ، لیکیج یا نقصان بالکل نہیں',
        standard: 'Intact painted steel or HDPE drum; zero floor pooling underneath',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Wire Mesh Mosquito Cover: Anti-mosquito insect mesh screen in place over drum',
        ur: 'مچھر جالی: مچھر اور کچرے سے بچاؤ کے لیے ڈرم پر جالی ڈھکی ہوئی ہے',
        standard: 'Fine stainless mesh screen covering rim prevents breeding/debris',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Elevated Platform Access: Clear access on boiler walkway, not blocked by tools',
        ur: 'پلیٹ فارم تک رسائی: بوائلر واک وے پر ڈرم تک رسائی کا راستہ کھلا ہے',
        standard: 'Minimum 900mm aisle clearance maintained around drum perimeter',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-FFEWIS-01',
    docNo: 'CPL-FFEWIS-01',
    title: 'Firefighting Equipment Weekly Inspection Schedule',
    titleUr: 'فائر فائٹنگ آلات کا ہفتہ وار جامع شیڈول معائنہ',
    category: 'Fire Protection & Life Safety',
    categoryUr: 'آگ سے بچاؤ اور لائف سیفٹی',
    frequency: 'Weekly',
    frequencyUr: 'ہفتہ وار',
    targetZone: '132kV Grid Switchyard',
    description: 'Master weekly preventative maintenance schedule verifying fire ring main pressure, deluge valves, and hydrant coverage across all sectors.',
    items: [
      {
        id: 1,
        en: 'Fire Ring Main Static Pressure: Pressure gauge reads ≥ 7.0 bar (100 psi)',
        ur: 'فائر رنگ مین پریشر: پریشر گیج 7.0 بار (100 پی ایس آئی) سے زیادہ ہے',
        standard: 'Jockey pump maintains 7.0 to 8.5 bar ring main static head',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Deluge Valve / Transformer Sprinklers: Control valve locked open, alarm gong operational',
        ur: 'ٹرانسفارمر ڈیلوز والو: والو کھلا اور لاک ہے، ہائیڈرولک الارم گونگ فعال',
        standard: 'Main riser valve chained & padlocked OPEN; pilot line charged',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Diesel Fire Pump Auto-Start: Controller in AUTO mode, battery voltage ≥ 24.8V',
        ur: 'ڈیزل فائر پمپ آٹو موڈ: کنٹرولر آٹو پوزیشن پر، بیٹری 24.8 وولٹ سے زیادہ',
        standard: 'Fuel day tank > 90% full, lube oil level correct, AUTO selector key locked',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Post Indicator Valves (PIV): Indicator plate reads OPEN, handwheel locked',
        ur: 'پوسٹ انڈیکیٹر والوز (PIV): انڈیکیٹر اوپن ظاہر کر رہا ہے اور پیڈلاک ہے',
        standard: 'Physical flag reads OPEN; target valve stem correctly positioned',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Weekly Flow Test & Sediment Flush: Clean stream flushed through end hydrants',
        ur: 'ہفتہ وار فلو ٹیسٹ: پائپ لائن سے مٹی نکالنے کے لیے پانی کا بہاؤ چیک کیا گیا',
        standard: 'Water runs clear after 30 seconds; no rust sediment or pipe scale',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-HSEFABI-01',
    docNo: 'CPL-HSEFABI-01',
    title: 'First Aid Box Inspection Checklist',
    titleUr: 'فرسٹ ایڈ باکس معائنہ چیک لسٹ',
    category: 'First Aid & Health Emergency',
    categoryUr: 'فرسٹ ایڈ اور ایمرجنسی ہیلتھ',
    frequency: 'Monthly',
    frequencyUr: 'ماہانہ',
    targetZone: 'Admin, Stores & Workshops (MMD / EMD / I&C)',
    description: 'Monthly medical supply inventory and sterility check of First Aid Stations (Time Office, Admin, Turbine Hall, Boiler, WTP).',
    items: [
      {
        id: 1,
        en: 'Pyodine Antiseptic Solution (100ml): Sealed bottle within unexpired shelf life',
        ur: 'پیوڈین جراثیم کش دوا: مہر بند بوتل اور ایکسپائری تاریخ کے اندر',
        standard: 'Minimum 1 sealed bottle 100ml; manufacturer expiry > 6 months remaining',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Sterile Gauze Bandages (3" & 4"): Minimum 5 packets each, sealed clean',
        ur: 'جراثیم سے پاک گوز پٹیاں: 5، 5 پیکٹ سیل بند موجود',
        standard: 'Sterile individual paper wrap intact without moisture staining',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Triangular & Elastic Crepe Bandages: 4 triangular slings and 2 crepe rolls',
        ur: 'تکونی اور کریپ پٹیاں: 4 تکونی اور 2 کریپ پٹیاں موجود',
        standard: 'Clean cotton slings for fracture immobilization and sprain support',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Burn Ointment / Silver Sulphadiazine: 50g tube available and sealed',
        ur: 'جلنے کا مرہم (سلور سلفا ڈائیزین): 50 گرام ٹیوب موجود اور سیل بند',
        standard: 'Unbroken aluminum tamper seal on tube; indicated for thermal burns',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Adhesive Dressing Strips (Band-Aids): Box of 20 assorted water-resistant strips',
        ur: 'چپکنے والی ڈریسنگ سٹرپس (سنی پلاسٹ): کم از کم 20 عدد موجود',
        standard: 'Clean sterile medical adhesive strips in dispenser box',
        status: 'pass'
      },
      {
        id: 6,
        en: 'Sterile Eye Wash Solution & Eye Cup: 500ml sterile normal saline with cup',
        ur: 'آنکھ دھونے کا محلول اور کپ: 500 ملی لیٹر نارمل سلائن اور آئی کپ موجود',
        standard: 'Bottle cap sealed; eye cup clean in protective plastic wrap',
        status: 'pass'
      },
      {
        id: 7,
        en: 'Medical Scissors & Stainless Forceps: Sharp, rust-free, sterilized in pouch',
        ur: 'میڈیکل قینچی اور چمٹی: تیز دھار، بغیر زنگ کے صاف پاؤچ میں',
        standard: 'Stainless steel blunt-tip scissors capable of cutting bandage cloth',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-HSEHIC-01',
    docNo: 'CPL-HSEHIC-01',
    title: 'Fire Hydrant Inspection Checklist',
    titleUr: 'فائر ہائیڈرینٹ معائنہ چیک لسٹ',
    category: 'Fire Protection & Life Safety',
    categoryUr: 'آگ سے بچاؤ اور لائف سیفٹی',
    frequency: 'Monthly',
    frequencyUr: 'ماہانہ',
    targetZone: 'Balance of Plant (BOP & Cooling Tower)',
    description: 'Comprehensive mechanical and flow inspection of pillar fire hydrants, spindle valves, and lug fittings.',
    items: [
      {
        id: 1,
        en: 'Valve Spindle Operation: Turns smoothly with valve key, full 5-6 revolutions',
        ur: 'والو سپنڈل کی حرکت: چابی کے ساتھ آسانی سے 5 تا 6 چکر مکمل گھومتا ہے',
        standard: 'No seizing, smooth opening/closing, stem gland does not leak under pressure',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Lug Outlets / Female Instantaneous Couplings: Spring lugs engage with click',
        ur: 'کوپلنگ آؤٹ لیٹس: دونوں سائیڈ کے لگز آسانی سے کِلک کے ساتھ لاک ہوتے ہیں',
        standard: 'Brass spring lugs depress and return instantly without sticking',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Blank Caps & Retaining Chains: Caps present with safety chains attached',
        ur: 'بلینک کیپس اور حفاظتی چین: ڈسٹ کیپس موجود اور زنجیر کے ساتھ بندھی ہیں',
        standard: 'Both outlets capped to prevent debris ingress; chains unbroken',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Automatic Frost Drainage Valve: Barrel drains completely when valve closed',
        ur: 'آٹومیٹک ڈرینج والو: ہائیڈرینٹ بند ہونے پر اندر کا پانی خودکار خارج ہوتا ہے',
        standard: 'Dry barrel frost valve discharges residual water within 60 seconds',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Post Paint & Demarcation Box: Signal red pillar, yellow/black curb markings clear',
        ur: 'ہائیڈرینٹ پینٹ اور مارکنگ: سرخ پینٹ چمکدار اور زمین پر زرد/سیاہ باکس واضح',
        standard: 'High-visibility paint, clearly legible Hydrant ID number stenciled',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-MLVAHCIC-01',
    docNo: 'CPL-MLVAHCIC-01',
    title: 'Monthly Landing Valve & Hose Cabinet Record',
    titleUr: 'لینڈنگ والو اور ہوز کیبنٹ کا ماہانہ معائنہ ریکارڈ',
    category: 'Fire Protection & Life Safety',
    categoryUr: 'آگ سے بچاؤ اور لائف سیفٹی',
    frequency: 'Monthly',
    frequencyUr: 'ماہانہ',
    targetZone: 'Boiler Area (Unit 1 & 2)',
    description: 'Monthly internal fire riser landing valve audit on boiler levels and turbine hall mezzanine.',
    items: [
      {
        id: 1,
        en: 'Handwheel Rigidity & Freedom: Firmly attached to valve stem, smooth rotation',
        ur: 'ہینڈ وہیل کی مضبوطی: والو سٹیم پر مضبوط اور آسانی سے گھومنے کے قابل',
        standard: 'Cast bronze/steel wheel firmly keyed; turns without excessive friction',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Valve Gland Packing & Seat: No water weeping or dripping under static head',
        ur: 'گلینڈ پیکنگ اور سیٹ: سٹینڈ پائپ پریشر میں پانی کا قطرہ بھی نہیں ٹپکتا',
        standard: 'Zero leakage around stuffing box gland; seat washers seal tight',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Instantaneous Female Coupling: Quick-release pull ears function cleanly',
        ur: 'کوپلنگ کان / ایئرز: پل ایئرز آسانی سے کھنچتے اور واپس بیٹھتے ہیں',
        standard: 'Internal spring mechanism oiled; female bore free of corrosion scale',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Blank Cap & Leather Strap: Blank cap fitted, leather/wire tether intact',
        ur: 'بلینک کیپ اور پٹہ: بلینک کیپ لگی ہوئی اور پٹے کے ساتھ محفوظ ہے',
        standard: 'Protective blank cap in position, keeps dirt out of riser valve',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Hose Flaking in Cradle: Perpendicular flaking for zero-snag pull out',
        ur: 'ہوز کیبنٹ میں ترتیب: ہوز اس طرح رکھی گئی ہے کہ کھینچنے پر الجھے نہیں',
        standard: 'Hose folded in Dutch roll or concertina flake for immediate deployment',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-WFMIC-01',
    docNo: 'CPL-WFMIC-01',
    title: 'Weekly Fire Fighting Monitors Inspection Checklist',
    titleUr: 'فائر مانیٹرز کا ہفتہ وار معائنہ چیک لسٹ',
    category: 'Fire Protection & Life Safety',
    categoryUr: 'آگ سے بچاؤ اور لائف سیفٹی',
    frequency: 'Weekly',
    frequencyUr: 'ہفتہ وار',
    targetZone: 'Fuel & Bagasse Yard (BC-1 to BC-5 / JT)',
    description: 'Weekly mechanical motion and pressure test of high-capacity water/foam monitors in Bagasse Yard, ESP, and Coal conveyor sectors.',
    items: [
      {
        id: 1,
        en: '360° Horizontal Turret Rotation: Swivels full circle without jamming',
        ur: '360 ڈگری افقی گردش: بغیر کسی رکاوٹ کے پورا دائرہ گھومتا ہے',
        standard: 'Turret worm gear properly greased, smooth 360-degree rotation',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Vertical Elevation Swivel: Smooth travel from -45° depressed to +90° vertical',
        ur: 'عمودی جھکاؤ اور بلندی: نیچے -45 سے لے کر اوپر +90 ڈگری تک درست حرکت',
        standard: 'Elevation gear holds position without drifting under water thrust',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Stream Control (Jet / Fog Pattern): Nozzle ring twists easily between straight stream and wide fog',
        ur: 'سٹریم کنٹرول (جیٹ تا فوگ): نوزل رنگ آسانی سے جیٹ اور دھند میں تبدیل ہوتا ہے',
        standard: 'Smooth pattern adjustment ring, effective throw distance ≥ 50 meters',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Swivel T-Bar Locks & Handwheel: Lock knobs clamp monitor firmly in position',
        ur: 'لاک ہینڈلز اور گرپ: لاک نوبز مانیٹر کو مطلوبہ زاویے پر مضبوطی سے جکڑتے ہیں',
        standard: 'Hand-operated locking screws hold monitor rigid against recoil',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Isolation Butterfly Valve: Valve padlocked OPEN, gear drive lubricated',
        ur: 'آئیسولیشن والو: والو کھلا اور تالے کے ساتھ بندھا ہوا ہے',
        standard: 'Upstream isolation valve locked in open position with tamper-evident chain',
        status: 'pass'
      }
    ]
  },
  {
    id: 'HSE-TAS-01',
    docNo: 'HSE-TAS-01',
    title: 'HSE Safety Induction Attendance & Verification',
    titleUr: 'حفاظتی انڈکشن حاضری اور تصدیق شیٹ',
    category: 'Safety Training & Contractor Induction',
    categoryUr: 'سیفٹی ٹریننگ اور کنٹریکٹر انڈکشن',
    frequency: 'Per Induction',
    frequencyUr: 'ہر انڈکشن پر',
    targetZone: 'Central Control Room (CCR)',
    description: 'Mandatory health, safety and environmental induction briefing and comprehension verification for new staff, visitors, and contractor crews.',
    items: [
      {
        id: 1,
        en: 'CPL 7 Golden Safety Rules: Briefed, understood, and signed agreement by attendee',
        ur: 'سیفٹی کے 7 سنہری اصول: بریفنگ دی گئی، سمجھی گئی اور شرکاء نے اقرار کیا',
        standard: 'Candidate demonstrates understanding of zero tolerance life-saving rules',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Mandatory PPE Verification: Safety helmet (EN397), steel-toe shoes (S3), high-vis vest inspected',
        ur: 'حفاظتی سامان (پی پی ای) کی جانچ: ہیلمٹ، سیفٹی جوتے اور جیکٹ درست معیار کی ہیں',
        standard: 'Full compliance with certified PPE prior to issuing plant entry gate pass',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Emergency Alarm Signals & Assembly Points: Familiarized with Continuous Siren (Evacuation)',
        ur: 'ایمرجنسی الارم اور اسمبلی پوائنٹس: مسلسل سائرن (انخلاء) اور محفوظ پوائنٹس سے آگاہی',
        standard: 'Candidate correctly identifies primary and secondary assembly areas',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Permit To Work (PTW) & LOTO Awareness: Lockout-tagout rules and permit requirements explained',
        ur: 'پرمٹ ٹو ورک اور لوٹو کے اصول: تالہ بندی اور اجازت نامے کے تقاضے سمجھائے گئے',
        standard: 'Candidate understands strict prohibition of working without valid PTW',
        status: 'pass'
      },
      {
        id: 5,
        en: 'National ID & Health Fit-for-Duty Check: Original CNIC verified, declared fit for industrial duty',
        ur: 'شناختی کارڈ اور میڈیکل فٹنس: اصل شناختی کارڈ تصدیق شدہ اور جسمانی فٹنس رپورٹ درست',
        standard: 'Valid CNIC logged, worker free of impairment, intoxicating substances or acute vertigo',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-WTIC-01',
    docNo: 'CPL-WTIC-01',
    title: 'Weekly Tractors & Mobile Equipment Inspection Checklist',
    titleUr: 'ٹریکٹرز اور موبائل مشینری کی ہفتہ وار چیک لسٹ',
    category: 'Heavy Vehicles & Mobile Plant',
    categoryUr: 'ہیوی گاڑیاں اور موبائل پلانٹ',
    frequency: 'Weekly',
    frequencyUr: 'ہفتہ وار',
    targetZone: 'Bagasse Piling & Shredder (BPL / RSML)',
    description: 'Weekly mechanical and fire safety inspection of CPL fleet (LET-1293, 1297, 1302, 1304, 1307, 1308, 1309) and contractor bagasse-handling tractors.',
    items: [
      {
        id: 1,
        en: 'Dual Service Foot Brake & Handbrake: Stops firmly within 3m at 15 km/h, handbrake holds 15° ramp',
        ur: 'فٹ بریک اور ہینڈ بریک: بریک فوراً لگتی ہے اور ہینڈ بریک ڈھلوان پر گاڑی روکتی ہے',
        standard: 'Equal braking force on left/right rear wheels without pull; parking brake locks',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Exhaust Spark Arrestor: Heavy-duty mesh spark arrestor securely fitted to vertical exhaust',
        ur: 'ایگزاسٹ سپارک اریسٹر: ایگزاسٹ پائپ پر سپارک اریسٹر مضبوطی سے لگا ہوا ہے',
        standard: 'Essential in Bagasse Yard: arrestor screen intact, zero incandescent carbon sparks',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Steering Play & Tie Rod Ends: Steering free play < 25mm, tie rods tight with cotter pins',
        ur: 'اسٹیئرنگ اور ٹائی راڈز: اسٹیئرنگ میں ڈھیلا پن نہیں اور کاٹر پن لگی ہوئی ہے',
        standard: 'Zero dangerous slack in drag link, orbitrol steering valve responsive',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Headlights, Rear Work Lamps & Indicators: Both beams working, yellow warning flasher on cab',
        ur: 'ہیڈ لائٹس، ورک لائٹس اور اشارے: سامنے اور پیچھے کی لائٹس اور پیلا فلیشر فعال',
        standard: 'High/low beam functioning, high-intensity LED work light illuminates blade/bucket',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Hydraulic Ram Cylinders & Hoses: Zero hydraulic oil weeping, lift arms hold load without drift',
        ur: 'ہائیڈرولک سلنڈر اور ہوز پائپ: تیل کا کوئی رساؤ نہیں اور لفٹ لوڈ روک سکتی ہے',
        standard: 'High-pressure hoses free of chafing; cylinder chrome rams unpitted',
        status: 'pass'
      },
      {
        id: 6,
        en: 'Tire Condition & Tread Depth: Minimum 15mm lug depth on ag tires, wheel lug nuts torqued',
        ur: 'ٹائروں کی حالت اور دباؤ: ٹائروں پر گہرے کٹ نہیں اور وہیل نٹ مکمل کسے ہوئے ہیں',
        standard: 'No severe sidewall gouges, correct inflation pressure (28 psi front, 20 psi rear)',
        status: 'pass'
      },
      {
        id: 7,
        en: 'Audible Reverse Alarm & Horn: Horn loud and clear; automatic beeper sounds in reverse gear',
        ur: 'ریورس ہارن اور عام ہارن: ریورس گیئر لگاتے ہی خودکار بیپ کی آواز آتی ہے',
        standard: 'Warning horn audible at 50m; reverse chime ≥ 87 dBA above diesel engine noise',
        status: 'pass'
      },
      {
        id: 8,
        en: 'Counterweight Traction Slabs: Concrete/cast steel counterweights firmly anchored to chassis',
        ur: 'کاؤنٹر ویٹ ٹریکشن سلیب: بھاری کاؤنٹر ویٹ چیسس کے ساتھ مضبوط بولٹ کے ذریعے فکس ہے',
        standard: 'Retention bolts torqued with lock washers; no shifting during bagasse shoving',
        status: 'pass'
      }
    ]
  },
  {
    id: 'CPL-WRWS-01',
    docNo: 'CPL-WRWS-01',
    title: 'Daily & Weekly Routine Work Checklist',
    titleUr: 'روزانہ اور ہفتہ وار معمول کے کاموں کی چیک لسٹ',
    category: 'Plant Operations & Maintenance',
    categoryUr: 'پلانٹ آپریشنز اور مینٹیننس',
    frequency: 'Daily',
    frequencyUr: 'روزانہ',
    targetZone: 'ESP & Ash Handling (SCC / Silo)',
    description: 'Daily and weekly housekeeping, conveyor emergency trip checks, safety showers, and earthing audits across operational plant units.',
    items: [
      {
        id: 1,
        en: 'Bagasse Conveyor (BC-1 to BC-5) Housekeeping: Walkways cleared of loose bagasse spillage',
        ur: 'بگاس کنویئر واک وے کی صفائی: کنویئر کے راستوں پر بگاس کا ملبہ اور کچرا صاف کیا گیا',
        standard: 'Zero combustible bagasse build-up around idler rollers and motors',
        status: 'pass'
      },
      {
        id: 2,
        en: 'Emergency Pull-Cord Switches: Pull wires tensioned along conveyors, trip switches test OK',
        ur: 'ایمرجنسی پل کارڈ سوئچز: ایمرجنسی تار میں مناسب کھنچاؤ اور ٹرپ سوئچز فعال',
        standard: 'Slack eliminated, flag switches reset smoothly, conveyor stops instantaneously',
        status: 'pass'
      },
      {
        id: 3,
        en: 'Emergency Eye Wash & Safety Showers: Tested, water runs clear, pressure adequate',
        ur: 'ایمرجنسی آئی واش اور سیفٹی شاورز: ٹیسٹ کیے گئے، پانی صاف اور مناسب دباؤ کے ساتھ آتا ہے',
        standard: 'Push plate actuates flow within 1 sec; stay-open valve remains hands-free',
        status: 'pass'
      },
      {
        id: 4,
        en: 'Scaffolding & Working Platforms: Scafftag inspected, green "SAFE TO USE" signed and dated',
        ur: 'اسکیفولڈنگ پلیٹ فارمز: اسکیف ٹیگ کا معائنہ، سبز سیف ٹیگ پر دستخط اور تاریخ موجود',
        standard: 'Proper toe boards, double handrails, base plates on sole pads, tagged within 7 days',
        status: 'pass'
      },
      {
        id: 5,
        en: 'Electrical MCC & Switchgear Earthing: Panel ground straps tight, dielectric rubber mats in place',
        ur: 'الیکٹریکل پینل ارتھنگ اور ربڑ میٹس: ارتھنگ وائر ٹائٹ اور 11 کے وی کے میٹس موجود',
        standard: 'Low-impedance copper busbar bonding verified; Class-2 rubber mats dry and clean',
        status: 'pass'
      }
    ]
  }
];

const outputPath = path.join(__dirname, 'src', 'data', 'checklist_catalog.json');
fs.writeFileSync(outputPath, JSON.stringify(templates, null, 2));
console.log(`Successfully generated ${templates.length} CPL checklist templates at ${outputPath}`);
