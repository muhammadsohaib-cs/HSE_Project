/// Industrial plant zones for Chiniot Power Generation Plant
class PlantZones {
  static const String boilerSection = 'Boiler Section';
  static const String turbineHall = 'Turbine Hall';
  static const String switchyard = '132kV Switchyard';
  static const String coalHandling = 'Coal Handling & Conveyor Area';
  static const String waterTreatment = 'Water Treatment Plant (WTP)';
  static const String coolingTowers = 'Cooling Towers';
  static const String controlRoom = 'Main Control Room (MCR)';
  static const String ashYard = 'Ash Handling Yard';
  static const String fuelStorage = 'Fuel & Lubricant Storage';
  static const String chemicalStorage = 'Chemical & Acid Storage Area';
  static const String adminBlock = 'Administration & Workshop';

  static const List<String> allZones = [
    boilerSection,
    turbineHall,
    switchyard,
    coalHandling,
    waterTreatment,
    coolingTowers,
    controlRoom,
    ashYard,
    fuelStorage,
    chemicalStorage,
    adminBlock,
  ];

  /// Predefined plant reference coordinates (Chiniot Power Complex)
  static const Map<String, (double lat, double lng)> zoneCoordinates = {
    boilerSection: (31.7205, 72.9780),
    turbineHall: (31.7210, 72.9785),
    switchyard: (31.7225, 72.9800),
    coalHandling: (31.7190, 72.9765),
    waterTreatment: (31.7215, 72.9770),
    coolingTowers: (31.7230, 72.9760),
    controlRoom: (31.7208, 72.9788),
    ashYard: (31.7180, 72.9750),
    fuelStorage: (31.7195, 72.9795),
    chemicalStorage: (31.7212, 72.9768),
    adminBlock: (31.7200, 72.9810),
  };
}

/// Operational shift types at the plant
enum ShiftType {
  morning('Morning Shift (06:00 - 14:00)'),
  evening('Evening Shift (14:00 - 22:00)'),
  night('Night Shift (22:00 - 06:00)');

  final String label;
  const ShiftType(this.label);
}

