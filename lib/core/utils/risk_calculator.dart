import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum RiskBand {
  low('Low Risk', AppColors.riskLow, 'Routine maintenance & standard operating precautions.'),
  medium('Medium Risk', AppColors.riskMedium, 'Specific monitoring required. Remediate within 7 days.'),
  high('High Risk', AppColors.riskHigh, 'Urgent corrective action required within 24-48 hours.'),
  critical('Critical / Extreme Risk', AppColors.riskCritical, 'STOP WORK immediately. Mandatory HSE Manager notification.');

  final String label;
  final Color color;
  final String actionProtocol;

  const RiskBand(this.label, this.color, this.actionProtocol);
}

class RiskProbability {
  final int value;
  final String label;
  final String description;

  const RiskProbability(this.value, this.label, this.description);

  static const List<RiskProbability> values = [
    RiskProbability(1, 'Rare', 'Practically impossible under normal operations'),
    RiskProbability(2, 'Unlikely', 'Not expected to occur, but conceivable'),
    RiskProbability(3, 'Possible', 'Could occur at some time in plant lifecycle'),
    RiskProbability(4, 'Likely', 'Will probably occur in most operating conditions'),
    RiskProbability(5, 'Almost Certain', 'Expected to occur regularly or recurrent hazard'),
  ];
}

class RiskSeverity {
  final int value;
  final String label;
  final String description;

  const RiskSeverity(this.value, this.label, this.description);

  static const List<RiskSeverity> values = [
    RiskSeverity(1, 'Insignificant', 'First aid case, negligible equipment impact'),
    RiskSeverity(2, 'Minor', 'Medical treatment, minor asset damage < \$5,000'),
    RiskSeverity(3, 'Moderate', 'Lost-time injury, reversible environmental impact'),
    RiskSeverity(4, 'Major', 'Permanent disability, severe equipment stoppage'),
    RiskSeverity(5, 'Catastrophic', 'Fatality, multiple severe casualties, major plant explosion/fire'),
  ];
}

class RiskCalculator {
  /// Computes quantitative 5x5 risk score (1-25)
  static int calculateScore(int probability, int severity) {
    assert(probability >= 1 && probability <= 5, 'Probability must be 1 to 5');
    assert(severity >= 1 && severity <= 5, 'Severity must be 1 to 5');
    return probability * severity;
  }

  /// Determines Risk Band from score
  static RiskBand getRiskBand(int score) {
    if (score <= 4) return RiskBand.low;
    if (score <= 9) return RiskBand.medium;
    if (score <= 14) return RiskBand.high;
    return RiskBand.critical;
  }

  /// 5x5 Matrix Grid item model
  static RiskBand getCellRiskBand(int probability, int severity) {
    return getRiskBand(calculateScore(probability, severity));
  }
}

