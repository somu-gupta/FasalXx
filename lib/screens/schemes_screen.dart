import 'package:flutter/material.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  static const _schemes = [
    _SchemeData(
      tag: 'Central Govt',
      tagColor: Color(0xFFF59E0B),
      name: 'PM-KISAN Samman Nidhi',
      description: 'Direct income support for eligible farmer families.',
      benefits: 'Rs 6000/year support in 3 installments',
      eligibility: 'Small and marginal farmers with valid land records',
      documents: 'Aadhaar, bank account, land record',
      mode: 'Online / CSC center',
      lastDate: 'Open all year',
      isEnrolled: true,
    ),
    _SchemeData(
      tag: 'Central Govt',
      tagColor: Color(0xFFF59E0B),
      name: 'PM Fasal Bima Yojana',
      description: 'Crop insurance support against weather, pest, and crop loss.',
      benefits: 'Low premium crop insurance and claim support',
      eligibility: 'Farmers growing notified crops in notified areas',
      documents: 'Aadhaar, bank passbook, sowing certificate',
      mode: 'Bank / Online / CSC center',
      lastDate: 'Before crop season cutoff',
      isEnrolled: false,
    ),
    _SchemeData(
      tag: 'State Govt (MP)',
      tagColor: Color(0xFF2563EB),
      name: 'Mukhyamantri Kisan Kalyan Yojana',
      description: 'Additional financial help for eligible MP farmers.',
      benefits: 'State income support with PM-KISAN linked records',
      eligibility: 'MP farmers registered under PM-KISAN',
      documents: 'Aadhaar, Samagra ID, bank account',
      mode: 'Online / Patwari / CSC center',
      lastDate: 'Open as per state window',
      isEnrolled: true,
    ),
    _SchemeData(
      tag: 'State Govt (MP)',
      tagColor: Color(0xFF2563EB),
      name: 'Krishi Yantra Subsidy',
      description: 'Subsidy support for farm tools and machinery purchase.',
      benefits: 'Subsidy on selected agricultural equipment',
      eligibility: 'Farmers with valid land and category documents',
      documents: 'Aadhaar, land record, quotation, bank details',
      mode: 'Online portal / Department office',
      lastDate: 'Depends on application cycle',
      isEnrolled: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF4),
      appBar: AppBar(
        title: const Text(
          'Government Schemes',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFFF7FAF4),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'View All',
              style: TextStyle(
                color: Color(0xFF16823A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 176),
        itemCount: _schemes.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _SchemesIntroCard();
          }

          return _SchemeCard(scheme: _schemes[index - 1]);
        },
      ),
    );
  }
}

class _SchemesIntroCard extends StatelessWidget {
  const _SchemesIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD6EED2)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.verified_outlined, color: Color(0xFF16823A)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Schemes are prioritized for Madhya Pradesh farmers. Check eligibility before applying.',
              style: TextStyle(
                color: Color(0xFF27402C),
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({required this.scheme});

  final _SchemeData scheme;

  @override
  Widget build(BuildContext context) {
    final statusColor = scheme.isEnrolled ? const Color(0xFF16823A) : const Color(0xFF6B7280);
    final actionLabel = scheme.isEnrolled ? 'Check Status' : 'Apply Now';
    final actionIcon = scheme.isEnrolled ? Icons.fact_check_outlined : Icons.open_in_new_rounded;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
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
                  _SchemeTag(label: scheme.tag, color: scheme.tagColor),
                  const Spacer(),
                  _StatusPill(
                    label: scheme.isEnrolled ? 'Enrolled Active' : 'Not Enrolled',
                    color: statusColor,
                    icon: scheme.isEnrolled ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                scheme.name,
                style: const TextStyle(
                  color: Color(0xFF17251A),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                scheme.description,
                style: const TextStyle(
                  color: Color(0xFF5D6B5E),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              _InfoLine(
                icon: Icons.card_giftcard_rounded,
                label: 'Key Benefit',
                value: scheme.benefits,
                iconColor: const Color(0xFF16823A),
              ),
              _InfoLine(
                icon: Icons.person_search_outlined,
                label: 'Eligibility',
                value: scheme.eligibility,
                iconColor: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 10),
              _DetailsStrip(scheme: scheme),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.isEnrolled ? const Color(0xFFEAF7E8) : const Color(0xFF14532D),
                    foregroundColor: scheme.isEnrolled ? const Color(0xFF14532D) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {},
                  icon: Icon(actionIcon),
                  label: Text(
                    actionLabel,
                    style: const TextStyle(fontWeight: FontWeight.w900),
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

class _SchemeTag extends StatelessWidget {
  const _SchemeTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF17251A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF657264),
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsStrip extends StatelessWidget {
  const _DetailsStrip({required this.scheme});

  final _SchemeData scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _MiniDetail(icon: Icons.badge_outlined, label: 'Documents', value: scheme.documents),
          const SizedBox(height: 8),
          _MiniDetail(icon: Icons.language_rounded, label: 'Mode', value: scheme.mode),
          const SizedBox(height: 8),
          _MiniDetail(icon: Icons.event_available_outlined, label: 'Last Date', value: scheme.lastDate),
        ],
      ),
    );
  }
}

class _MiniDetail extends StatelessWidget {
  const _MiniDetail({
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
        Icon(icon, color: const Color(0xFF16823A), size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF435246),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF657264),
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _SchemeData {
  const _SchemeData({
    required this.tag,
    required this.tagColor,
    required this.name,
    required this.description,
    required this.benefits,
    required this.eligibility,
    required this.documents,
    required this.mode,
    required this.lastDate,
    required this.isEnrolled,
  });

  final String tag;
  final Color tagColor;
  final String name;
  final String description;
  final String benefits;
  final String eligibility;
  final String documents;
  final String mode;
  final String lastDate;
  final bool isEnrolled;
}
