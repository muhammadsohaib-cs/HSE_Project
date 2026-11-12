import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/risk_calculator.dart';

class RiskMatrixWidget extends StatelessWidget {
  final int selectedProbability;
  final int selectedSeverity;
  final Function(int probability, int severity)? onCellSelected;
  final bool isInteractive;

  const RiskMatrixWidget({
    super.key,
    required this.selectedProbability,
    required this.selectedSeverity,
    this.onCellSelected,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentScore = RiskCalculator.calculateScore(selectedProbability, selectedSeverity);
    final currentBand = RiskCalculator.getRiskBand(currentScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Summary Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: currentBand.color.withAlpha((0.15 * 255).round()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: currentBand.color, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: currentBand.color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Score: $currentScore / 25',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentBand.label.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: currentBand.color,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      currentBand.actionProtocol,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 5x5 Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = ((constraints.maxWidth - 50) / 5).clamp(24.0, 52.0);

            return Column(
              children: [
                // Top Row: Severity Header (1 to 5)
                Row(
                  children: [
                    const SizedBox(width: 44, child: Text('P \\ S', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                    for (int s = 1; s <= 5; s++)
                      SizedBox(
                        width: cellSize,
                        child: Center(
                          child: Text(
                            'S$s',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Probability Rows (5 down to 1)
                for (int p = 5; p >= 1; p--)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(
                            'P$p',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        for (int s = 1; s <= 5; s++)
                          _buildGridCell(p, s, cellSize),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGridCell(int p, int s, double size) {
    final cellScore = p * s;
    final band = RiskCalculator.getRiskBand(cellScore);
    final isSelected = p == selectedProbability && s == selectedSeverity;

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: isInteractive ? () => onCellSelected?.call(p, s) : null,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: size - 4,
          height: size - 4,
          decoration: BoxDecoration(
            color: band.color.withAlpha((isSelected ? 0.95 : 0.65 * 255).round()),
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2.5)
                : Border.all(color: Colors.black26, width: 0.5),
            boxShadow: isSelected
                ? [BoxShadow(color: band.color.withAlpha((0.6 * 255).round()), blurRadius: 6, spreadRadius: 1)]
                : null,
          ),
          child: Center(
            child: Text(
              '$cellScore',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

