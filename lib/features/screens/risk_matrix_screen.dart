import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class RiskMatrixScreen extends StatelessWidget {
  const RiskMatrixScreen({super.key});

  Color _getScoreColor(int score) {
    if (score >= 16) return CplColors.red600;
    if (score >= 10) return CplColors.safety500;
    if (score >= 5) return CplColors.amber500;
    return CplColors.emerald500;
  }

  String _getCategoryText(int score, bool isUr) {
    if (score >= 16) return isUr ? 'انتہائی خطرناک (CRITICAL)' : 'CRITICAL PRIORITY';
    if (score >= 10) return isUr ? 'زیادہ خطرہ (HIGH)' : 'HIGH RISK';
    if (score >= 5) return isUr ? 'درمیانہ خطرہ (MODERATE)' : 'MODERATE RISK';
    return isUr ? 'معمولی خطرہ (LOW)' : 'LOW RISK';
  }

  String _getGuidanceText(int score, bool isUr) {
    if (score >= 16) {
      return isUr
          ? 'کام فوری طور پر بند کریں۔ پلانٹ مینیجر اور چیف ایگزیکٹو کی تحریری منظوری تک سرگرمی معطل رہے گی۔'
          : 'Work MUST cease immediately. Escalated to Plant Head and HSE Director. LOTO lock required.';
    }
    if (score >= 10) {
      return isUr
          ? 'کام شروع کرنے سے پہلے سینئر انجینئر کا وزٹ اور ہاٹ ورک / ایل او ٹی او پرمٹ لازمی ہے۔'
          : 'Detailed Job Safety Analysis (JSA) required. Senior shift supervisor sign-off needed before start.';
    }
    if (score >= 5) {
      return isUr
          ? 'معیاری ایس او پی (SOP) اور پی پی ای (PPE) کا معائنہ یقینی بنائیں۔'
          : 'Execute work under standard plant operating procedures. Regular shift supervisor monitoring.';
    }
    return isUr
        ? 'بنیادی حفاظتی تدابیر کے ساتھ کام جاری رکھا جا سکتا ہے۔'
        : 'Acceptable risk level. Continue routine vigilance and use personal protective gear.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final selectedL = state.selectedLikelihood;
        final selectedS = state.selectedSeverity;
        final score = state.riskScore;
        final scoreColor = _getScoreColor(score);

        return Scaffold(
          backgroundColor: CplColors.slate50,
          appBar: AppBar(
            backgroundColor: CplColors.slate900,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.read<CplSystemCubit>().setScreenIndex(1),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUr ? '5×5 رسک میٹرکس اور CAPA' : '5×5 Risk Matrix & CAPA',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ISO 45001 • CPL Co-Gen Plant Risk Engine',
                  style: CplTypography.caption(context).copyWith(color: CplColors.slate400),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                onPressed: () => context.read<CplSystemCubit>().toggleLanguage(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Risk Calculator Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CplColors.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUr ? 'حالیہ رسک اسکور' : 'Dynamic Risk Score',
                                style: CplTypography.caption(context).copyWith(
                                  color: CplColors.slate600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '$score',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: scoreColor,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Text(
                                    ' / 25',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: CplColors.slate600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: scoreColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: scoreColor),
                            ),
                            child: Text(
                              _getCategoryText(score, isUr),
                              style: TextStyle(
                                color: scoreColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CplColors.slate50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: CplColors.slate200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 18, color: scoreColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getGuidanceText(score, isUr),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: CplColors.slate800,
                                  height: isUr ? 1.8 : 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Interactive 5x5 Matrix Grid
                Text(
                  isUr ? 'میٹرکس پر کلک کر کے اسکور تبدیل کریں (L × S)' : 'Tap Cell to Calculate (Likelihood × Severity)',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isUr
                      ? 'افقی محور = امکان (1-5) • عمودی محور = شدت (1-5)'
                      : 'Horizontal: Likelihood (1 Rare → 5 Expected) • Vertical: Severity (1 Minor → 5 Catastrophic)',
                  style: CplTypography.caption(context).copyWith(color: CplColors.slate600),
                ),
                const SizedBox(height: 12),

                // The 5x5 Grid Table
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Column(
                    children: [
                      // Header Row (Likelihoods 1 to 5)
                      Row(
                        children: [
                          Container(
                            width: 38,
                            alignment: Alignment.center,
                            child: const Text('S \\ L', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          ...List.generate(5, (lIndex) {
                            final lVal = lIndex + 1;
                            return Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                alignment: Alignment.center,
                                child: Text('L$lVal', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }),
                        ],
                      ),
                      const Divider(height: 8),
                      // 5 Severity Rows (from 5 down to 1)
                      ...List.generate(5, (sIndex) {
                        final sVal = 5 - sIndex; // 5, 4, 3, 2, 1
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                alignment: Alignment.center,
                                child: Text('S$sVal', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              ...List.generate(5, (lIndex) {
                                final lVal = lIndex + 1;
                                final cellScore = sVal * lVal;
                                final isSelected = selectedL == lVal && selectedS == sVal;
                                final cellColor = _getScoreColor(cellScore);

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<CplSystemCubit>().selectRiskCell(lVal, sVal);
                                    },
                                    child: Container(
                                      height: 36,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected ? cellColor : cellColor.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected ? Colors.black : cellColor,
                                          width: isSelected ? 2.5 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [BoxShadow(color: cellColor.withOpacity(0.6), blurRadius: 6)]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$cellScore',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : cellColor.withOpacity(0.95),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // CAPA Action Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUr ? 'فعال اصلاحی اقدامات (CAPA لسٹ)' : 'Active CAPA Tracker',
                      style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CplColors.slate900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${state.capas.where((c) => !c.signedOff).length} Open',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // CAPA Items List
                ...state.capas.map((capa) {
                  final itemColor = _getScoreColor(capa.score);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: capa.signedOff ? CplColors.emerald500.withOpacity(0.5) : CplColors.slate200,
                        width: capa.signedOff ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: itemColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${capa.id} • Score: ${capa.score}',
                                style: TextStyle(
                                  color: itemColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: capa.signedOff
                                    ? CplColors.emerald500.withOpacity(0.12)
                                    : CplColors.amber500.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                capa.signedOff ? (isUr ? 'منظور شدہ ✓' : 'SIGNED OFF ✓') : (isUr ? 'زیر التوا' : 'OPEN'),
                                style: TextStyle(
                                  color: capa.signedOff ? CplColors.emerald500 : CplColors.amber500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          capa.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: capa.signedOff ? CplColors.slate600 : CplColors.slate900,
                            decoration: capa.signedOff ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: CplColors.slate600),
                            const SizedBox(width: 4),
                            Text(capa.zone, style: const TextStyle(fontSize: 12, color: CplColors.slate600)),
                            const Spacer(),
                            const Icon(Icons.person, size: 14, color: CplColors.slate600),
                            const SizedBox(width: 4),
                            Text(capa.owner, style: const TextStyle(fontSize: 12, color: CplColors.slate600)),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: CplColors.safety500),
                                const SizedBox(width: 4),
                                Text(
                                  'Due: ${capa.due}',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: CplColors.safety600),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: state.canSignOffCapa
                                  ? () {
                                      context.read<CplSystemCubit>().toggleCapaSignOff(capa.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            capa.signedOff
                                                ? 'Re-opened ${capa.id}'
                                                : 'Supervisor Signed Off ${capa.id} (${state.currentUser.name})',
                                          ),
                                          backgroundColor: capa.signedOff ? CplColors.slate900 : CplColors.emerald500,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  : () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('RBAC Restricted: Only Safety Officers/Managers can sign off CAPA.'),
                                          backgroundColor: CplColors.red600,
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.canSignOffCapa
                                    ? (capa.signedOff ? CplColors.slate200 : CplColors.slate900)
                                    : CplColors.slate300,
                                foregroundColor: state.canSignOffCapa
                                    ? (capa.signedOff ? CplColors.slate800 : Colors.white)
                                    : CplColors.slate500,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                capa.signedOff
                                    ? (isUr ? 'دوبارہ کھولیں' : 'Re-open')
                                    : (isUr ? 'دستخط اور کلوز (Sign Off)' : 'Sign Off Action'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
