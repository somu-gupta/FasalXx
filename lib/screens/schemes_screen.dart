import 'package:flutter/material.dart';

const _schemeGreen = Color(0xFF1B8A5A);
const _schemeBg = Color(0xFFF7FAF4);
const _schemeInk = Color(0xFF17251A);
const _centralOrange = Color(0xFFF59E0B);
const _stateBlue = Color(0xFF2563EB);

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  final List<SchemeInfo> _schemes = MockSchemesApi.fetchSchemes();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _schemeBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 176),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Government Schemes',
                    style: TextStyle(
                      color: _schemeInk,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Showing all available schemes.')),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Useful central and state schemes for your farm.',
              style: TextStyle(
                color: Color(0xFF667366),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            for (final scheme in _schemes) ...[
              _SchemeCard(
                scheme: scheme,
                onToggle: () {
                  setState(() => scheme.isExpanded = !scheme.isExpanded);
                },
                onAction: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        scheme.isEnrolled
                            ? 'Checking ${scheme.name} status...'
                            : 'Opening ${scheme.name} application...',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({
    required this.scheme,
    required this.onToggle,
    required this.onAction,
  });

  final SchemeInfo scheme;
  final VoidCallback onToggle;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final tagColor = scheme.isCentral ? _centralOrange : _stateBlue;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.isCentral ? const Color(0xFFFFE7BA) : const Color(0xFFD7E6FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SoftIcon(icon: scheme.icon, color: tagColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _TagPill(label: scheme.tag, color: tagColor),
                            _StatusPill(isEnrolled: scheme.isEnrolled),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          scheme.name,
                          style: const TextStyle(
                            color: _schemeInk,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggle,
                    icon: AnimatedRotation(
                      turns: scheme.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                scheme.description,
                style: const TextStyle(
                  color: Color(0xFF556255),
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _InfoRow(
                icon: Icons.volunteer_activism_outlined,
                label: 'Benefit',
                value: scheme.benefit,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.verified_user_outlined,
                label: 'Eligibility',
                value: scheme.eligibility,
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Required Documents',
                        style: TextStyle(fontWeight: FontWeight.w900, color: _schemeInk),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final document in scheme.documents)
                            Chip(
                              avatar: const Icon(Icons.description_outlined, size: 17, color: _schemeGreen),
                              label: Text(document),
                              backgroundColor: const Color(0xFFDFF5EC),
                              side: BorderSide.none,
                              labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.language_rounded,
                        label: 'Mode',
                        value: scheme.mode,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.event_available_outlined,
                        label: 'Last Date',
                        value: scheme.lastDate,
                      ),
                    ],
                  ),
                ),
                crossFadeState: scheme.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(scheme.isEnrolled ? Icons.fact_check_outlined : Icons.assignment_turned_in_outlined),
                  label: Text(scheme.isEnrolled ? 'Check Status' : 'Apply Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _schemeGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: color.withAlpha(26),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isEnrolled});

  final bool isEnrolled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isEnrolled ? const Color(0xFFDFF5EC) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEnrolled ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 15,
            color: isEnrolled ? _schemeGreen : const Color(0xFF64748B),
          ),
          const SizedBox(width: 5),
          Text(
            isEnrolled ? 'Enrolled Active' : 'Not Enrolled',
            style: TextStyle(
              color: isEnrolled ? _schemeGreen : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _schemeGreen, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF556255),
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(color: _schemeInk, fontWeight: FontWeight.w900),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MockSchemesApi {
  static List<SchemeInfo> fetchSchemes() {
    return [
      SchemeInfo(
        tag: 'Central Govt',
        name: 'PM-KISAN Samman Nidhi',
        description: 'Direct income support for eligible farmer families through bank transfer.',
        benefit: 'Rs 6,000 per year support in installments',
        eligibility: 'Small and marginal farmer families with valid land records',
        documents: const ['Aadhaar Card', 'Bank Passbook', 'Land Records'],
        mode: 'Online / CSC centers',
        lastDate: 'Open all year',
        icon: Icons.account_balance_rounded,
        isCentral: true,
        isEnrolled: true,
      ),
      SchemeInfo(
        tag: 'Central Govt',
        name: 'Pradhan Mantri Fasal Bima Yojana',
        description: 'Crop insurance support against weather, pest, and yield losses.',
        benefit: 'Affordable crop insurance and claim support',
        eligibility: 'Farmers growing notified crops in notified areas',
        documents: const ['Aadhaar Card', 'Bank Account', 'Crop Sowing Proof'],
        mode: 'Bank / Online / CSC centers',
        lastDate: 'Before crop season cutoff',
        icon: Icons.health_and_safety_outlined,
        isCentral: true,
        isEnrolled: false,
      ),
      SchemeInfo(
        tag: 'State Govt (MP)',
        name: 'Mukhyamantri Kisan Kalyan Yojana',
        description: 'Additional financial assistance for eligible farmers in Madhya Pradesh.',
        benefit: 'State income support for registered farmers',
        eligibility: 'MP farmers registered with PM-KISAN',
        documents: const ['Aadhaar Card', 'Samagra ID', 'Bank Passbook'],
        mode: 'Online / Local agriculture office',
        lastDate: 'Open as per state schedule',
        icon: Icons.savings_outlined,
        isCentral: false,
        isEnrolled: true,
      ),
      SchemeInfo(
        tag: 'State Govt (MP)',
        name: 'Subsidy on Farm Equipment',
        description: 'Subsidy support for buying useful agriculture machinery and tools.',
        benefit: 'Subsidy on selected farm equipment',
        eligibility: 'Registered farmers with land and equipment requirement',
        documents: const ['Land Records', 'Quotation', 'Bank Details'],
        mode: 'Online application / Department office',
        lastDate: '31 May 2026',
        icon: Icons.agriculture_outlined,
        isCentral: false,
        isEnrolled: false,
      ),
    ];
  }
}

class SchemeInfo {
  SchemeInfo({
    required this.tag,
    required this.name,
    required this.description,
    required this.benefit,
    required this.eligibility,
    required this.documents,
    required this.mode,
    required this.lastDate,
    required this.icon,
    required this.isCentral,
    required this.isEnrolled,
    this.isExpanded = false,
  });

  final String tag;
  final String name;
  final String description;
  final String benefit;
  final String eligibility;
  final List<String> documents;
  final String mode;
  final String lastDate;
  final IconData icon;
  final bool isCentral;
  final bool isEnrolled;
  bool isExpanded;
}
