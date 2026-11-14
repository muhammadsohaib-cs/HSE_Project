/// Real operational plant zones & shift schedules for Chiniot Power Limited (62.4 MW Co-Gen Plant)
/// Sourced from Attendance Nov-2026.xlsx & Monthly Working Hours Report Oct-26.xlsx
class PlantZones {
  static const String boilerArea = 'Boiler Area (Unit 1 & 2)';
  static const String tgBuilding = 'TG Building (Steam Turbine Hall)';
  static const String ccr = 'Central Control Room (CCR)';
  static const String fuelBagasseYard = 'Fuel & Bagasse Yard (BC-1 to BC-5 / JT)';
  static const String switchyard = '132kV Grid Switchyard';
  static const String wtp = 'Water Treatment Plant (WTP)';
  static const String bopCoolingTower = 'Balance of Plant (BOP & Cooling Tower)';
  static const String espAshHandling = 'ESP & Ash Handling (SCC / Silo)';
  static const String bagassePilingShredder = 'Bagasse Piling & Shredder (BPL / RSML)';
  static const String adminStoresWorkshops = 'Admin, Stores & Workshops (MMD / EMD / I&C)';

  // Legacy aliases for backward compatibility with older domain modules
  static const String boilerSection = boilerArea;
  static const String turbineHall = tgBuilding;
  static const String coalHandling = fuelBagasseYard;
  static const String waterTreatment = wtp;
  static const String coolingTowers = bopCoolingTower;
  static const String controlRoom = ccr;
  static const String ashYard = espAshHandling;
  static const String fuelStorage = bagassePilingShredder;
  static const String chemicalStorage = wtp;
  static const String adminBlock = adminStoresWorkshops;

  static const List<String> allZones = [
    boilerArea,
    tgBuilding,
    ccr,
    fuelBagasseYard,
    switchyard,
    wtp,
    bopCoolingTower,
    espAshHandling,
    bagassePilingShredder,
    adminStoresWorkshops,
  ];

  /// Predefined plant reference coordinates (Chiniot Power Complex)
  static const Map<String, (double lat, double lng)> zoneCoordinates = {
    boilerArea: (31.7204, 72.9791),
    tgBuilding: (31.7201, 72.9788),
    ccr: (31.7208, 72.9788),
    fuelBagasseYard: (31.7195, 72.9802),
    switchyard: (31.7208, 72.9780),
    wtp: (31.7198, 72.9784),
    bopCoolingTower: (31.7192, 72.9795),
    espAshHandling: (31.7185, 72.9760),
    bagassePilingShredder: (31.7190, 72.9798),
    adminStoresWorkshops: (31.7200, 72.9810),
  };
}

/// Real CPL Operational Shift Types (12-Hour Rotating A/B/C/D + General Shift)
enum ShiftType {
  general('General Shift (08:00 - 17:00)'),
  shiftA('Shift A (07:00 - 19:00 / 19:00 - 07:00)'),
  shiftB('Shift B (07:00 - 19:00 / 19:00 - 07:00)'),
  shiftC('Shift C (07:00 - 19:00 / 19:00 - 07:00)'),
  shiftD('Shift D (07:00 - 19:00 / 19:00 - 07:00)'),
  // Legacy enum constants kept for backward compatibility
  morning('Shift A (07:00 - 19:00 / 19:00 - 07:00)'),
  evening('Shift B (07:00 - 19:00 / 19:00 - 07:00)'),
  night('Shift C (07:00 - 19:00 / 19:00 - 07:00)');

  final String label;
  const ShiftType(this.label);
}
