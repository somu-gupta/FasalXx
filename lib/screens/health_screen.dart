import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../core/network/api_failure.dart';
import '../services/backend_repositories.dart';
import '../services/image_input_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fasalx_header.dart';

const _primary = Color(0xFF1B8A5A);
const _secondary = Color(0xFFDFF5EC);
const _yellow = Color(0xFFFFF4CC);
const _blue = Color(0xFFE8F1FF);
const _bg = Color(0xFFF7FAF4);

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const FasalXHeader(),
      body: AnimatedBuilder(
        animation: MockHealthApi.instance,
        builder: (context, _) {
          final scans = MockHealthApi.scanHistory;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 176),
            children: [
              Text(
                'Crop Health',
                style: TextStyle(
                  color: fx.textStrong,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _HeroScannerCard(
                onCamera: () => _openScan(context, ScanSource.camera),
                onGallery: () => _openScan(context, ScanSource.gallery),
              ),
              const SizedBox(height: 14),
              const _ScanningTipsCard(),
              const SizedBox(height: 14),
              const _ExpertAssistanceCard(),
              const SizedBox(height: 18),
              _RecentScansSection(scans: scans),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openScan(BuildContext context, ScanSource source) async {
    if (source == ScanSource.camera) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ScanScreen(source: ScanSource.camera),
        ),
      );
      return;
    }

    SelectedImage? image;

    try {
      image = await pickDeviceImage();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gallery could not be opened. Please try again.'),
        ),
      );
      return;
    }

    if (!context.mounted) return;

    if (image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No gallery image selected.')));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanScreen(source: source, initialImage: image),
      ),
    );
  }
}

class _RecentScansSection extends StatelessWidget {
  const _RecentScansSection({required this.scans});

  final List<ScanReport> scans;

  @override
  Widget build(BuildContext context) {
    final recent = scans.take(3).toList();
    final fx = context.fx;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Past Alerts / Scan History',
          action: 'History',
          onAction: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ScanHistoryScreen())),
        ),
        const SizedBox(height: 10),
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _IconBubble(
                    icon: Icons.history_rounded,
                    color: _primary,
                    bg: _secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent crop scans',
                          style: TextStyle(
                            color: fx.textStrong,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${scans.length} reports saved for field follow-up',
                          style: TextStyle(
                            color: fx.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ScanHistoryScreen(),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('History'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (recent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Text('No scans yet. Capture a crop image to begin.'),
                  ),
                )
              else
                for (final scan in recent) ...[
                  _ScanHistoryTile(scan: scan),
                  if (scan != recent.last) const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final _search = TextEditingController();
  _HistoryRange _range = _HistoryRange.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ScanReport> get _filteredScans {
    final query = _search.text.trim().toLowerCase();
    return MockHealthApi.scanHistory.where((scan) {
      final matchesSearch =
          query.isEmpty ||
          scan.crop.toLowerCase().contains(query) ||
          scan.disease.toLowerCase().contains(query) ||
          scan.symptoms.toLowerCase().contains(query);
      final matchesRange = _range.includes(scan.scannedAt);
      return matchesSearch && matchesRange;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: MockHealthApi.instance,
        builder: (context, _) {
          final scans = _filteredScans;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan reports',
                      style: TextStyle(
                        color: fx.textStrong,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Review disease alerts, treatments, and field advice from previous scans.',
                      style: TextStyle(
                        color: fx.textMuted,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                        context,
                        'Search crop, disease, symptom...',
                      ).copyWith(prefixIcon: const Icon(Icons.search_rounded)),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final range in _HistoryRange.values) ...[
                            ChoiceChip(
                              label: Text(range.label),
                              selected: _range == range,
                              selectedColor: fx.selectedFill,
                              labelStyle: TextStyle(
                                color: _range == range
                                    ? Theme.of(context).colorScheme.primary
                                    : fx.textMuted,
                                fontWeight: FontWeight.w900,
                              ),
                              side: BorderSide(
                                color: _range == range
                                    ? Theme.of(context).colorScheme.primary
                                    : fx.border,
                              ),
                              onSelected: (_) => setState(() => _range = range),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (scans.isEmpty)
                _GlassCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.manage_search_rounded,
                        color: fx.textMuted,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No scans found',
                        style: TextStyle(
                          color: fx.textStrong,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try changing the search or date range.',
                        style: TextStyle(color: fx.textMuted),
                      ),
                    ],
                  ),
                )
              else
                for (final scan in scans) ...[
                  _ScanHistoryTile(scan: scan, expanded: true),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

enum _HistoryRange { all, today, week, month }

extension _HistoryRangeLabel on _HistoryRange {
  String get label {
    switch (this) {
      case _HistoryRange.all:
        return 'All';
      case _HistoryRange.today:
        return 'Today';
      case _HistoryRange.week:
        return '7 days';
      case _HistoryRange.month:
        return '30 days';
    }
  }

  bool includes(DateTime date) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    switch (this) {
      case _HistoryRange.all:
        return true;
      case _HistoryRange.today:
        return date.isAfter(startOfToday) ||
            date.isAtSameMomentAs(startOfToday);
      case _HistoryRange.week:
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case _HistoryRange.month:
        return date.isAfter(now.subtract(const Duration(days: 30)));
    }
  }
}

class _HeroScannerCard extends StatefulWidget {
  const _HeroScannerCard({required this.onCamera, required this.onGallery});

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  State<_HeroScannerCard> createState() => _HeroScannerCardState();
}

class _HeroScannerCardState extends State<_HeroScannerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B8A5A), Color(0xFF0F5D3E)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331B8A5A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  return Container(
                    width: 62 + (_pulse.value * 8),
                    height: 62 + (_pulse.value * 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(28),
                    ),
                    child: child,
                  );
                },
                child: const CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.document_scanner_outlined,
                    color: _primary,
                    size: 31,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withAlpha(60)),
                ),
                child: const Text(
                  '95% Accuracy | AI Powered',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Scan Crop for Disease',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Detect plant diseases instantly using AI',
            style: TextStyle(
              color: Color(0xE6FFFFFF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.onCamera,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text(
                    'Camera',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onGallery,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text(
                    'Gallery',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanningTipsCard extends StatefulWidget {
  const _ScanningTipsCard();

  @override
  State<_ScanningTipsCard> createState() => _ScanningTipsCardState();
}

class _ScanningTipsCardState extends State<_ScanningTipsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _GlassCard(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                const _IconBubble(
                  icon: Icons.lightbulb_outline,
                  color: Color(0xFFC28A00),
                  bg: _yellow,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI Scanning Tips',
                    style: TextStyle(
                      color: fx.textStrong,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Column(
                children: [
                  _TipLine(
                    icon: Icons.photo_camera_outlined,
                    text: 'Keep image sharp',
                  ),
                  _TipLine(
                    icon: Icons.eco_outlined,
                    text: 'Use plain background',
                  ),
                  _TipLine(
                    icon: Icons.wb_sunny_outlined,
                    text: 'Ensure good lighting',
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

class _ExpertAssistanceCard extends StatelessWidget {
  const _ExpertAssistanceCard();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kisan Helpline',
                      style: TextStyle(
                        color: fx.textStrong,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Connect with verified agronomists',
                      style: TextStyle(color: fx.textMuted),
                    ),
                  ],
                ),
              ),
              const _AvatarPreview(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.circle,
                color: Theme.of(context).colorScheme.primary,
                size: 10,
              ),
              const SizedBox(width: 6),
              Text(
                'Online Experts',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Avg response: 2 min',
                style: TextStyle(
                  color: fx.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HelpButton(
                  icon: Icons.call_outlined,
                  label: 'Call',
                  onTap: () => _showDemoAction(
                    context,
                    'Demo call request sent to Kisan Helpline.',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HelpButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ExpertChatScreen(
                        prefilledQuery: 'Need help with crop disease symptoms.',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HelpButton(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  onTap: () => _showDemoAction(
                    context,
                    'Demo video slot booked for the next expert.',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _showDemoAction(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: _secondary,
                child: Icon(Icons.person_outline, color: _primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${post.name} - ${post.location}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              _Tag(label: post.tag, color: _primary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.question,
            style: const TextStyle(height: 1.35, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.forum_outlined, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('${post.replies} replies'),
              const SizedBox(width: 12),
              Icon(
                post.liked
                    ? Icons.thumb_up_alt_rounded
                    : Icons.thumb_up_alt_outlined,
                size: 18,
                color: post.liked ? _primary : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text('${post.likes} likes'),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CommunityDiscussionScreen(postId: post.id),
                  ),
                ),
                child: const Text('Join Discussion'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanHistoryTile extends StatelessWidget {
  const _ScanHistoryTile({required this.scan, this.expanded = false});

  final ScanReport scan;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: fx.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailedReportScreen(report: scan)),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scan.riskColor.withAlpha(isDark ? 96 : 42),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 48 : 13),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scan.riskColor.withAlpha(isDark ? 48 : 24),
                child: Icon(Icons.eco_outlined, color: scan.riskColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${scan.crop} - ${scan.disease}',
                            style: TextStyle(
                              color: fx.textStrong,
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        _Tag(
                          label: '${scan.severityLabel} Risk',
                          color: scan.riskColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      scan.symptoms,
                      maxLines: expanded ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fx.textMuted,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: fx.textMuted,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          scan.dateLabel,
                          style: TextStyle(
                            color: fx.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.source, this.initialImage});

  final ScanSource source;
  final SelectedImage? initialImage;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;
  SelectedImage? _selectedImage;
  CameraController? _cameraController;
  Future<void>? _cameraFuture;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
    if (widget.source == ScanSource.camera && _selectedImage == null) {
      _cameraFuture = _initCamera();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        setState(() => _cameraError = 'No camera found on this device.');
        return;
      }

      CameraDescription selectedCamera = cameras.first;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() => _cameraController = controller);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _cameraError = 'Camera is not available. Use gallery instead.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.source == ScanSource.camera ? 'Camera Scan' : 'Gallery Scan',
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.72,
                child: Container(
                  margin: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10251B),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(child: _buildPreview()),
                      if (_selectedImage != null)
                        Positioned(
                          top: 18,
                          left: 18,
                          right: 18,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(120),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _selectedImage!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      Container(
                        width: 230,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: _primary, width: 3),
                        ),
                      ),
                      Positioned(
                        bottom: 28,
                        child: Text(
                          _selectedImage == null
                              ? 'Place leaf inside frame'
                              : 'Ready to scan crop image',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (_isScanning) const _ScanOverlay(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo flash toggled for crop scan.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flash_on_outlined),
                ),
                IconButton.filledTonal(
                  onPressed: _isScanning
                      ? null
                      : () =>
                            _pickImage(fromCamera: false, scanAfterPick: false),
                  icon: const Icon(Icons.image_outlined),
                ),
                SizedBox(
                  width: 82,
                  height: 82,
                  child: FilledButton(
                    onPressed: _isScanning ? null : _capture,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: _primary,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 34),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _isScanning ? null : _retakeCamera,
                  icon: const Icon(Icons.cameraswitch_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.memory(
          _selectedImage!.bytes,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: CameraPreview(controller),
      );
    }

    return FutureBuilder<void>(
      future: _cameraFuture,
      builder: (context, snapshot) {
        if (_cameraError != null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.no_photography_outlined,
                  color: Colors.white38,
                  size: 78,
                ),
                const SizedBox(height: 14),
                Text(
                  _cameraError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () =>
                      _pickImage(fromCamera: false, scanAfterPick: false),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Choose from Gallery'),
                ),
              ],
            ),
          );
        }

        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 16),
            Text(
              'Opening camera...',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _capture() async {
    if (_selectedImage == null) {
      final controller = _cameraController;
      if (controller != null && controller.value.isInitialized) {
        try {
          final picture = await controller.takePicture();
          final bytes = await picture.readAsBytes();
          if (!mounted) return;
          setState(
            () => _selectedImage = SelectedImage(
              name: picture.name,
              bytes: bytes,
            ),
          );
        } catch (_) {
          final picked = await _pickImage(
            fromCamera: true,
            scanAfterPick: false,
          );
          if (!picked) return;
        }
      } else {
        final picked = await _pickImage(
          fromCamera: widget.source == ScanSource.camera,
          scanAfterPick: false,
        );
        if (!picked) return;
      }
    }

    setState(() => _isScanning = true);
    final image = _selectedImage;
    final report = image == null
        ? await MockHealthApi.scanCrop()
        : await MockHealthApi.scanCrop(
            cropName: _cropNameFrom(image.name),
            imageBytes: image.bytes,
            imageName: image.name,
          );
    if (!mounted) return;
    setState(() => _isScanning = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ScanResultScreen(report: report)),
    );
  }

  Future<bool> _pickImage({
    required bool fromCamera,
    required bool scanAfterPick,
  }) async {
    SelectedImage? image;

    try {
      image = await pickDeviceImage(fromCamera: fromCamera);
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fromCamera
                ? 'Camera is not available on this device. Please use gallery.'
                : 'Gallery could not be opened. Please try again.',
          ),
        ),
      );
      return false;
    }

    if (!mounted) return false;

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fromCamera
                ? 'No camera photo selected.'
                : 'No gallery image selected.',
          ),
        ),
      );
      return false;
    }

    setState(() => _selectedImage = image);
    if (scanAfterPick) {
      await _capture();
    }
    return true;
  }

  Future<void> _retakeCamera() async {
    setState(() => _selectedImage = null);
    if (_cameraController == null && widget.source == ScanSource.camera) {
      _cameraFuture = _initCamera();
    }
  }

  String _cropNameFrom(String imageName) {
    final lower = imageName.toLowerCase();
    for (final crop in ['tomato', 'wheat', 'rice', 'maize', 'chilli', 'cotton']) {
      if (lower.contains(crop)) return crop;
    }
    return 'unknown';
  }
}

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key, required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Scan Result'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _MockImageCard(crop: report.crop),
          const SizedBox(height: 14),
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disease Detected',
                  style: TextStyle(
                    color: fx.textStrong,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report.disease,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confidence: ${report.confidence}%',
                  style: TextStyle(
                    color: fx.textStrong,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report.symptoms,
                  style: TextStyle(
                    color: fx.textMuted,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _Tag(
                  label: '${report.severityLabel} Severity',
                  color: report.riskColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ReportBlock(
            title: 'Symptoms',
            icon: Icons.visibility_outlined,
            text: report.symptoms,
          ),
          _ReportBlock(
            title: 'Cause',
            icon: Icons.biotech_outlined,
            text: report.causes,
          ),
          _TreatmentCard(report: report),
          _ReportBlock(
            title: 'Preventive Measures',
            icon: Icons.shield_outlined,
            text: report.preventiveMeasures,
          ),
          _ProfessionalTipsCard(report: report),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExpertChatScreen(
                        prefilledQuery:
                            'My ${report.crop} has ${report.disease}. What should I do?',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.support_agent_rounded),
                  label: const Text('Talk to Expert'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Scan saved in history.')),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailedReportScreen(report: report),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Full Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailedReportScreen extends StatelessWidget {
  const DetailedReportScreen({super.key, required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detailed Report'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.disease,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report.description,
                  style: TextStyle(
                    color: fx.textMuted,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ReportBlock(
            title: 'Symptoms',
            icon: Icons.visibility_outlined,
            text: report.symptoms,
          ),
          _ReportBlock(
            title: 'Causes',
            icon: Icons.biotech_outlined,
            text: report.causes,
          ),
          _ReportBlock(
            title: 'Treatment',
            icon: Icons.medical_services_outlined,
            text: report.treatment,
          ),
          _ReportBlock(
            title: 'Preventive Measures',
            icon: Icons.shield_outlined,
            text: report.preventiveMeasures,
          ),
          _ReportBlock(
            title: 'Weather Correlation',
            icon: Icons.cloud_outlined,
            text: report.weatherCorrelation,
          ),
          _ProfessionalTipsCard(report: report),
        ],
      ),
    );
  }
}

class ExpertChatScreen extends StatefulWidget {
  const ExpertChatScreen({super.key, required this.prefilledQuery});

  final String prefilledQuery;

  @override
  State<ExpertChatScreen> createState() => _ExpertChatScreenState();
}

class _ExpertChatScreenState extends State<ExpertChatScreen> {
  late final List<ChatMessage> _messages = [
    ChatMessage(widget.prefilledQuery, true),
    const ChatMessage(
      'Namaste. Please share crop age and field photo if possible.',
      false,
    ),
  ];
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Expert Chat'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, index) => _ChatBubble(message: _messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo image attachment added to chat.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.image_outlined),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      filled: true,
                      fillColor: _bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text, true));
      _messages.add(
        const ChatMessage(
          'Thanks. Expert will review and reply shortly.',
          false,
        ),
      );
    });
    _controller.clear();
  }
}

class CommunityDiscussionScreen extends StatefulWidget {
  const CommunityDiscussionScreen({super.key, required this.postId});

  final String postId;

  @override
  State<CommunityDiscussionScreen> createState() =>
      _CommunityDiscussionScreenState();
}

class _CommunityDiscussionScreenState extends State<CommunityDiscussionScreen> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backend = DemoCommunityBackend.instance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Discussion'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedBuilder(
        animation: backend,
        builder: (context, _) {
          final post = backend.postById(widget.postId);
          if (post == null) {
            return const Center(child: Text('Question not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Tag(label: post.tag, color: _primary),
                    const SizedBox(height: 10),
                    Text(
                      post.question,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.35,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${post.name} from ${post.location} | ${post.crop}',
                      style: const TextStyle(
                        color: Color(0xFF667366),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => backend.toggleLike(post.id),
                          icon: Icon(
                            post.liked
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_alt_outlined,
                          ),
                          label: Text('${post.likes}'),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _showReplySheet(context, backend, post),
                          icon: const Icon(Icons.reply_outlined),
                          label: const Text('Reply'),
                        ),
                        TextButton.icon(
                          onPressed: () => _sharePost(context, post),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _InstantAdviceCard(post: post),
              const SizedBox(height: 12),
              for (final reply in post.replyItems)
                _ReplyTile(name: reply.name, text: reply.text),
            ],
          );
        },
      ),
    );
  }

  void _sharePost(BuildContext context, CommunityPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demo share ready: ${post.tag} discussion copied.'),
      ),
    );
  }

  Future<void> _showReplySheet(
    BuildContext context,
    DemoCommunityBackend backend,
    CommunityPost post,
  ) {
    final fx = context.fx;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: fx.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add helpful reply',
                style: TextStyle(
                  color: fx.textStrong,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _replyController,
                minLines: 3,
                maxLines: 5,
                decoration: _inputDecoration(
                  context,
                  'Write simple advice farmers can follow...',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  final text = _replyController.text.trim();
                  if (text.isEmpty) return;
                  backend.addReply(post.id, text);
                  _replyController.clear();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Post Reply'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InstantAdviceCard extends StatelessWidget {
  const _InstantAdviceCard({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      color: const Color(0xFFFFFCF2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_outlined, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text(
                'Demo expert guidance',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.demoAdvice,
            style: const TextStyle(height: 1.4, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class AllCommunitiesScreen extends StatefulWidget {
  const AllCommunitiesScreen({super.key, this.initialFilter = 'Wheat'});

  final String initialFilter;

  @override
  State<AllCommunitiesScreen> createState() => _AllCommunitiesScreenState();
}

class _AllCommunitiesScreenState extends State<AllCommunitiesScreen> {
  final _search = TextEditingController();
  late String _filter;

  static const _filters = [
    'Wheat',
    'Rice',
    'Vegetables',
    'Fruits',
    'Organic Farming',
    'Pest Control',
  ];

  @override
  void initState() {
    super.initState();
    _filter = _filters.contains(widget.initialFilter)
        ? widget.initialFilter
        : 'Wheat';
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<FarmerCommunity> get _visibleCommunities {
    final query = _search.text.toLowerCase();
    return DemoCommunityBackend.instance.communities.where((community) {
      final matchesFilter = community.topics.contains(_filter);
      final matchesSearch =
          query.isEmpty ||
          community.title.toLowerCase().contains(query) ||
          community.topics.join(' ').toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Farmer Communities',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              _search.clear();
              setState(() {});
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AskQuestionScreen(
              communities: DemoCommunityBackend.instance.communities
                  .map((item) => item.title)
                  .toList(),
            ),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ask Question'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(
              context,
              'Search crops, diseases, topics...',
            ).copyWith(prefixIcon: const Icon(Icons.search_rounded)),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in _filters) ...[
                  ChoiceChip(
                    label: Text(filter),
                    selected: _filter == filter,
                    selectedColor: context.fx.selectedFill,
                    labelStyle: TextStyle(
                      color: _filter == filter
                          ? Theme.of(context).colorScheme.primary
                          : context.fx.textMuted,
                      fontWeight: FontWeight.w900,
                    ),
                    side: BorderSide(
                      color: _filter == filter
                          ? Theme.of(context).colorScheme.primary
                          : context.fx.border,
                    ),
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: DemoCommunityBackend.instance,
            builder: (context, _) {
              final visible = _visibleCommunities;

              return Column(
                children: [
                  for (final community in visible) ...[
                    _CommunityListCard(
                      community: community,
                      onJoin: () => DemoCommunityBackend.instance.toggleJoin(
                        community.title,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CommunityDetailScreen(
                            communityTitle: community.title,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (visible.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No communities found')),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({super.key, required this.communityTitle});

  final String communityTitle;

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final backend = DemoCommunityBackend.instance;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.communityTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          bottom: const TabBar(
            labelColor: _primary,
            indicatorColor: _primary,
            tabs: [
              Tab(text: 'Posts'),
              Tab(text: 'Discussions'),
              Tab(text: 'Media'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  AskQuestionScreen(communities: [widget.communityTitle]),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Ask Question'),
        ),
        body: AnimatedBuilder(
          animation: backend,
          builder: (context, _) {
            final community = backend.communityByTitle(widget.communityTitle);
            if (community == null) {
              return const Center(child: Text('Community not found'));
            }

            return Column(
              children: [
                _CommunityDetailHeader(
                  community: community,
                  onJoin: () => backend.toggleJoin(community.title),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _CommunityPostsList(community: community),
                      _CommunityPostsList(community: community),
                      _CommunityMediaTab(community: community),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CommunityListCard extends StatelessWidget {
  const _CommunityListCard({
    required this.community,
    required this.onJoin,
    required this.onTap,
  });

  final FarmerCommunity community;
  final VoidCallback onJoin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: community.color.withAlpha(28),
              child: Icon(community.icon, color: community.color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${community.members} farmers',
                    style: const TextStyle(
                      color: Color(0xFF667366),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${community.activeToday} active today',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onJoin,
              style: FilledButton.styleFrom(
                backgroundColor: community.joined ? _secondary : _primary,
                foregroundColor: community.joined ? _primary : Colors.white,
              ),
              child: Text(community.joined ? 'Joined' : 'Join'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityDetailHeader extends StatelessWidget {
  const _CommunityDetailHeader({required this.community, required this.onJoin});

  final FarmerCommunity community;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _GlassCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: community.color.withAlpha(28),
              child: Icon(community.icon, color: community.color, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${community.members} farmers - ${community.activeToday} active today',
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onJoin,
              child: Text(community.joined ? 'Joined' : 'Join'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostsList extends StatelessWidget {
  const _CommunityPostsList({required this.community});

  final FarmerCommunity community;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        for (final post in community.posts) ...[
          _CommunityPostCard(post: post),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CommunityMediaTab extends StatelessWidget {
  const _CommunityMediaTab({required this.community});

  final FarmerCommunity community;

  @override
  Widget build(BuildContext context) {
    final postsWithImages = community.posts
        .where((post) => post.hasImage)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        if (postsWithImages.isEmpty)
          _GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: Colors.grey.shade500,
                  size: 42,
                ),
                const SizedBox(height: 10),
                const Text(
                  'No field photos yet',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ask a question and attach a photo to help others identify symptoms.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF667366)),
                ),
              ],
            ),
          )
        else
          for (final post in postsWithImages) ...[
            _GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: _secondary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: _primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      post.question,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({
    super.key,
    this.communities = const ['Wheat Disease Support', 'Organic Farming India'],
  });

  final List<String> communities;

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  String _crop = 'Wheat';
  late String _community;
  final _question = TextEditingController();
  final _location = TextEditingController(text: 'Bhopal');
  bool _hasImage = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _community = widget.communities.first;
  }

  @override
  void dispose() {
    _question.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ask Question'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _crop,
            decoration: _inputDecoration(context, 'Select crop type'),
            items:
                const [
                      'Wheat',
                      'Rice',
                      'Soyabean',
                      'Tomato',
                      'Vegetables',
                      'Fruits',
                    ]
                    .map(
                      (crop) =>
                          DropdownMenuItem(value: crop, child: Text(crop)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _crop = value ?? _crop),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _community,
            decoration: _inputDecoration(context, 'Select community'),
            items: widget.communities
                .map(
                  (community) => DropdownMenuItem(
                    value: community,
                    child: Text(community),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => _community = value ?? _community),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _question,
            minLines: 5,
            maxLines: 8,
            decoration: _inputDecoration(
              context,
              'Describe your crop problem...',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _location,
            decoration: _inputDecoration(
              context,
              'Village / District',
            ).copyWith(prefixIcon: const Icon(Icons.place_outlined)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() => _hasImage = !_hasImage),
            icon: Icon(
              _hasImage ? Icons.check_circle_rounded : Icons.image_outlined,
            ),
            label: Text(_hasImage ? 'Field photo attached' : 'Add Field Photo'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _submitting ? null : _submitQuestion,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_submitting ? 'Sending...' : 'Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuestion() async {
    final question = _question.text.trim();
    if (question.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe the crop problem in a little more detail.',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    await DemoCommunityBackend.instance.submitQuestion(
      communityTitle: _community,
      crop: _crop,
      question: question,
      location: _location.text.trim().isEmpty
          ? 'Nearby village'
          : _location.text.trim(),
      hasImage: _hasImage,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question posted. Demo expert guidance added.'),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Treatment',
            style: TextStyle(
              color: fx.textStrong,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _TipLine(
            icon: Icons.medical_services_outlined,
            text: report.treatment,
          ),
          _TipLine(
            icon: Icons.eco_outlined,
            text: 'Organic: ${report.organicTreatment}',
          ),
          _TipLine(
            icon: Icons.science_outlined,
            text: 'Chemical: ${report.chemicalTreatment}',
          ),
        ],
      ),
    );
  }
}

class _ProfessionalTipsCard extends StatelessWidget {
  const _ProfessionalTipsCard({required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _GlassCard(
      color: fx.warningContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.agriculture_outlined, color: fx.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Professional farming tips',
                  style: TextStyle(
                    color: fx.textStrong,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final tip in report.professionalTips)
            _TipLine(icon: Icons.check_circle_outline_rounded, text: tip),
        ],
      ),
    );
  }
}

class MockHealthApi extends ChangeNotifier {
  MockHealthApi._()
    : _scanHistory = [
        ScanReport.tomato(),
        ScanReport.wheat(),
        ScanReport.chilli(),
      ];

  static final MockHealthApi instance = MockHealthApi._();

  final List<ScanReport> _scanHistory;
  int _nextScanIndex = 0;

  static List<ScanReport> get scanHistory =>
      List.unmodifiable(instance._scanHistory);

  static Future<ScanReport> scanCrop({
    String cropName = 'unknown',
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    return instance._scanCrop(
      cropName: cropName,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }

  Future<ScanReport> _scanCrop({
    required String cropName,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (imageBytes != null) {
      try {
        final prediction = await const DiseaseRepository().predict(
          cropName: cropName,
          imageBytes: imageBytes,
          imageName: imageName,
        );
        final report = ScanReport.fromPrediction(
          prediction,
          crop: cropName == 'unknown' ? 'Crop' : cropName,
        );
        _scanHistory.insert(0, report);
        notifyListeners();
        return report;
      } on ApiFailure {
        // Keep the scan flow usable if the backend is temporarily unavailable.
      } catch (_) {
        // Fall through to the bundled demo reports.
      }
    }

    await Future<void>.delayed(const Duration(seconds: 2));
    final templates = [
      ScanReport.tomato(),
      ScanReport.wheat(),
      ScanReport.chilli(),
    ];
    final report = templates[_nextScanIndex % templates.length].copyWith(
      scanId: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      scannedAt: DateTime.now(),
      dateLabel: 'Today',
    );
    _nextScanIndex += 1;
    _scanHistory.insert(0, report);
    notifyListeners();
    return report;
  }
}

class DemoCommunityBackend extends ChangeNotifier {
  DemoCommunityBackend._() : _communities = MockCommunityApi.seedCommunities();

  static final DemoCommunityBackend instance = DemoCommunityBackend._();

  final List<FarmerCommunity> _communities;
  int _nextPostId = 100;

  List<FarmerCommunity> get communities => List.unmodifiable(_communities);
  List<String> get quickTopics => const [
    'Wheat',
    'Pest Control',
    'Organic Farming',
  ];
  int get onlineExperts => 8;
  int get totalPosts =>
      _communities.fold(0, (sum, item) => sum + item.posts.length);

  List<CommunityPost> get featuredPosts {
    final posts = [for (final community in _communities) ...community.posts];
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  FarmerCommunity? communityByTitle(String title) {
    for (final community in _communities) {
      if (community.title == title) return community;
    }
    return null;
  }

  CommunityPost? postById(String id) {
    for (final community in _communities) {
      for (final post in community.posts) {
        if (post.id == id) return post;
      }
    }
    return null;
  }

  void toggleJoin(String communityTitle) {
    final community = communityByTitle(communityTitle);
    if (community == null) return;
    community.joined = !community.joined;
    notifyListeners();
  }

  void toggleLike(String postId) {
    final post = postById(postId);
    if (post == null) return;
    post.liked = !post.liked;
    post.likes += post.liked ? 1 : -1;
    notifyListeners();
  }

  void addReply(String postId, String text) {
    final post = postById(postId);
    if (post == null) return;
    post.replyItems.insert(0, CommunityReply(name: 'You', text: text));
    post.replies += 1;
    notifyListeners();
  }

  Future<CommunityPost> submitQuestion({
    required String communityTitle,
    required String crop,
    required String question,
    required String location,
    required bool hasImage,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final community = communityByTitle(communityTitle) ?? _communities.first;
    final post = CommunityPost(
      id: 'demo-${_nextPostId++}',
      name: 'You',
      location: location,
      crop: crop,
      tag: _tagForCrop(crop, question),
      question: question,
      replies: 1,
      likes: 0,
      hasImage: hasImage,
      replyItems: [
        CommunityReply(name: 'Demo Agronomist', text: _adviceForCrop(crop)),
      ],
    );
    community.posts.insert(0, post);
    community.joined = true;
    notifyListeners();
    return post;
  }

  String _tagForCrop(String crop, String question) {
    final lower = question.toLowerCase();
    if (lower.contains('yellow')) {
      return '$crop yellowing'.toUpperCase();
    }
    if (lower.contains('pest') || lower.contains('insect')) {
      return '$crop pest'.toUpperCase();
    }
    if (lower.contains('spot')) {
      return '$crop spots'.toUpperCase();
    }
    return '$crop help'.toUpperCase();
  }

  String _adviceForCrop(String crop) {
    switch (crop) {
      case 'Rice':
        return 'Check water level, leaf spots, and blast symptoms. Share close leaf photo before spraying.';
      case 'Tomato':
      case 'Vegetables':
        return 'Inspect underside of leaves for sucking pests. Use yellow sticky traps and avoid heavy spray in noon heat.';
      case 'Fruits':
        return 'Check fruit drop pattern, irrigation gap, and visible pest marks before applying nutrients.';
      default:
        return 'Check lower leaves, soil moisture, and recent fertilizer dose. Add one clear photo for better guidance.';
    }
  }
}

class MockCommunityApi {
  static List<FarmerCommunity> seedCommunities() {
    return communities.map((item) => item.copy()).toList();
  }

  static final communities = [
    FarmerCommunity(
      title: 'Wheat Disease Support',
      members: '12.5k',
      activeToday: '320',
      icon: Icons.grass_rounded,
      color: _primary,
      topics: ['Wheat', 'Pest Control'],
      joined: true,
      posts: [
        CommunityPost(
          id: 'wheat-yellowing',
          name: 'Suresh',
          location: 'Vidisha',
          crop: 'Wheat',
          tag: 'WHEAT YELLOWING',
          question:
              'Wheat leaves are turning yellow after irrigation. What should I check first?',
          replies: 12,
          likes: 34,
          hasImage: true,
          replyItems: [
            CommunityReply(
              name: 'Agronomist Kavita',
              text:
                  'Check nitrogen deficiency first. Share a close photo of lower leaves.',
            ),
            CommunityReply(
              name: 'Farmer Manoj',
              text: 'I used soil test advice and yellowing reduced in 10 days.',
            ),
          ],
        ),
        CommunityPost(
          id: 'yellow-rust',
          name: 'Ravi',
          location: 'Bhopal',
          crop: 'Wheat',
          tag: 'YELLOW RUST',
          question: 'Can yellow rust spread after foggy mornings?',
          replies: 18,
          likes: 42,
          replyItems: [
            CommunityReply(
              name: 'Expert Neha',
              text:
                  'Yes. Cool, moist mornings can increase spread. Inspect nearby fields too.',
            ),
          ],
        ),
      ],
    ),
    FarmerCommunity(
      title: 'Organic Farming India',
      members: '28k',
      activeToday: '540',
      icon: Icons.eco_outlined,
      color: const Color(0xFF65A30D),
      topics: ['Organic Farming', 'Vegetables', 'Fruits'],
      joined: false,
      posts: [
        CommunityPost(
          id: 'organic-pesticides',
          name: 'Meena',
          location: 'Sehore',
          crop: 'Vegetables',
          tag: 'ORGANIC PESTICIDES',
          question:
              'Which organic spray works for sucking pests in vegetables?',
          replies: 8,
          likes: 21,
          hasImage: true,
          replyItems: [
            CommunityReply(
              name: 'Organic Grower Anil',
              text:
                  'Neem-based spray works better when used early morning or evening.',
            ),
          ],
        ),
      ],
    ),
    FarmerCommunity(
      title: 'Rice & Paddy Care',
      members: '9.8k',
      activeToday: '210',
      icon: Icons.water_drop_outlined,
      color: const Color(0xFF2563EB),
      topics: ['Rice', 'Pest Control'],
      joined: false,
      posts: [
        CommunityPost(
          id: 'paddy-blast',
          name: 'Arjun',
          location: 'Balaghat',
          crop: 'Rice',
          tag: 'PADDY BLAST',
          question: 'Brown spots are appearing after rain. Is it blast?',
          replies: 15,
          likes: 27,
          replyItems: [
            CommunityReply(
              name: 'Agronomist Kavita',
              text:
                  'Share a close leaf photo. Avoid excess nitrogen if blast is suspected.',
            ),
          ],
        ),
      ],
    ),
    FarmerCommunity(
      title: 'Fruit Growers Circle',
      members: '7.2k',
      activeToday: '150',
      icon: Icons.local_florist_outlined,
      color: const Color(0xFFF59E0B),
      topics: ['Fruits', 'Organic Farming'],
      joined: false,
      posts: [
        CommunityPost(
          id: 'fruit-drop',
          name: 'Kavita',
          location: 'Indore',
          crop: 'Fruits',
          tag: 'FRUIT DROP',
          question:
              'Guava fruit drop is increasing. What nutrient should I check?',
          replies: 7,
          likes: 18,
          replyItems: [
            CommunityReply(
              name: 'Horticulture Expert',
              text:
                  'Check irrigation stress first, then review boron and calcium schedule.',
            ),
          ],
        ),
      ],
    ),
  ];
}

class FarmerCommunity {
  FarmerCommunity({
    required this.title,
    required this.members,
    required this.activeToday,
    required this.icon,
    required this.color,
    required this.topics,
    required this.joined,
    required this.posts,
  });

  final String title;
  final String members;
  final String activeToday;
  final IconData icon;
  final Color color;
  final List<String> topics;
  bool joined;
  final List<CommunityPost> posts;

  FarmerCommunity copy() {
    return FarmerCommunity(
      title: title,
      members: members,
      activeToday: activeToday,
      icon: icon,
      color: color,
      topics: List.of(topics),
      joined: joined,
      posts: posts.map((post) => post.copy()).toList(),
    );
  }
}

class CommunityPost {
  CommunityPost({
    required this.id,
    required this.name,
    required this.location,
    required this.crop,
    required this.tag,
    required this.question,
    required this.replies,
    required this.likes,
    this.liked = false,
    this.hasImage = false,
    DateTime? createdAt,
    List<CommunityReply>? replyItems,
  }) : createdAt = createdAt ?? DateTime.now(),
       replyItems = replyItems ?? [];

  final String id;
  final String name;
  final String location;
  final String crop;
  final String tag;
  final String question;
  int replies;
  int likes;
  bool liked;
  final bool hasImage;
  final DateTime createdAt;
  final List<CommunityReply> replyItems;

  CommunityPost copy() {
    return CommunityPost(
      id: id,
      name: name,
      location: location,
      crop: crop,
      tag: tag,
      question: question,
      replies: replies,
      likes: likes,
      liked: liked,
      hasImage: hasImage,
      createdAt: createdAt,
      replyItems: List.of(replyItems),
    );
  }

  String get demoAdvice {
    final lower = question.toLowerCase();
    if (lower.contains('yellow')) {
      return 'First check nitrogen deficiency, water logging, and lower leaves. If yellow stripes appear, ask expert before spraying.';
    }
    if (lower.contains('pest') || lower.contains('spray')) {
      return 'Look under leaves in the morning. Start with sticky traps or neem-based spray, then escalate only if pest count is high.';
    }
    if (lower.contains('spot') || lower.contains('blast')) {
      return 'Avoid overhead irrigation, improve airflow, and share a clear photo before choosing fungicide.';
    }
    return 'Share crop age, recent irrigation, fertilizer dose, and one clear leaf photo for practical guidance.';
  }
}

class CommunityReply {
  const CommunityReply({required this.name, required this.text});

  final String name;
  final String text;
}

class ScanReport {
  const ScanReport({
    required this.scanId,
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.risk,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatment,
    required this.preventiveMeasures,
    required this.localizedTreatment,
    required this.weatherCorrelation,
    required this.organicTreatment,
    required this.chemicalTreatment,
    required this.professionalTips,
    required this.scannedAt,
    required this.dateLabel,
  });

  factory ScanReport.tomato() => ScanReport(
    scanId: 'seed-tomato',
    crop: 'Tomato Leaf',
    disease: 'Early Blight',
    confidence: 92,
    risk: RiskLevel.high,
    description: 'A fungal disease that creates dark spots and leaf yellowing.',
    symptoms:
        'Dark concentric spots on older leaves, yellowing around lesions, lower leaf drying, and gradual defoliation if unmanaged.',
    causes: 'High humidity, infected residue, and poor airflow.',
    treatment:
        'Remove badly affected leaves, keep foliage dry, and spray a recommended fungicide in the morning after confirming label dose.',
    preventiveMeasures:
        'Remove infected leaves, rotate crops, use clean staking, and avoid overhead irrigation.',
    localizedTreatment:
        'Sankramit patte hataen aur subah ke samay safe fungicide spray karein.',
    weatherCorrelation:
        'Risk increases when humidity is above 70% with warm temperature.',
    organicTreatment: 'Neem oil spray and remove affected leaves.',
    chemicalTreatment: 'Use recommended fungicide after expert confirmation.',
    professionalTips: const [
      'Scout lower leaves every 3-4 days during humid weather.',
      'Keep plants pruned lightly so air moves through the canopy.',
      'Apply nutrients through soil test advice; stressed plants catch blight faster.',
    ],
    scannedAt: DateTime(2026, 5, 9, 9, 30),
    dateLabel: 'Today',
  );

  factory ScanReport.wheat() => ScanReport(
    scanId: 'seed-wheat',
    crop: 'Wheat',
    disease: 'Yellow Rust',
    confidence: 87,
    risk: RiskLevel.medium,
    description: 'Yellow stripes on wheat leaves that reduce crop vigor.',
    symptoms:
        'Narrow yellow-orange stripes, powdery spores on leaves, patchy yellowing, and faster spread in cool moist mornings.',
    causes: 'Cool and humid conditions with infected spores.',
    treatment:
        'Mark affected patches, avoid unnecessary irrigation, and use a triazole fungicide only after local expert confirmation.',
    preventiveMeasures:
        'Use resistant variety, monitor early symptoms, and avoid dense sowing in rust-prone fields.',
    localizedTreatment:
        'Peeli dhariyan dikhen to krishi expert se salah lekar spray karein.',
    weatherCorrelation: 'Cool mornings and high moisture can increase spread.',
    organicTreatment: 'Improve field airflow and remove infected patches.',
    chemicalTreatment: 'Use triazole fungicide as advised.',
    professionalTips: const [
      'Inspect nearby fields because rust spores travel with wind.',
      'Prioritize spray on active patches instead of blanket treatment when infection is early.',
      'Record variety and sowing date to improve next season disease planning.',
    ],
    scannedAt: DateTime(2026, 5, 8, 11, 10),
    dateLabel: 'Yesterday',
  );

  factory ScanReport.chilli() => ScanReport(
    scanId: 'seed-chilli',
    crop: 'Chilli',
    disease: 'Leaf Curl',
    confidence: 81,
    risk: RiskLevel.low,
    description: 'Leaf curling often linked with sucking pests.',
    symptoms:
        'Upward leaf curling, smaller new leaves, mild stunting, and sticky residue or whitefly activity under leaves.',
    causes: 'Whitefly and viral infection pressure.',
    treatment:
        'Install yellow sticky traps, remove severely curled plants, and control whitefly early before symptoms spread.',
    preventiveMeasures:
        'Use yellow sticky traps, inspect weekly, manage weeds, and avoid bringing infected seedlings.',
    localizedTreatment:
        'Safed makkhi control ke liye yellow sticky traps lagayen.',
    weatherCorrelation: 'Dry warm weather can increase whitefly activity.',
    organicTreatment: 'Neem-based spray and sticky traps.',
    chemicalTreatment:
        'Use pest-specific pesticide only if threshold is crossed.',
    professionalTips: const [
      'Check underside of leaves early morning when whiteflies are less active.',
      'Keep the field edge weed-free because pests often build up there.',
      'Use mixed pest management first; repeated chemical spray can trigger resistance.',
    ],
    scannedAt: DateTime(2026, 5, 7, 16, 20),
    dateLabel: '2 days ago',
  );

  factory ScanReport.fromPrediction(
    DiseasePrediction prediction, {
    required String crop,
  }) {
    final confidence = prediction.confidence.round().clamp(0, 100);
    final risk = confidence >= 80
        ? RiskLevel.high
        : confidence >= 55
        ? RiskLevel.medium
        : RiskLevel.low;
    return ScanReport(
      scanId: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      crop: crop,
      disease: prediction.disease,
      confidence: confidence,
      risk: risk,
      description: 'Backend disease analysis from ${prediction.source}.',
      symptoms:
          prediction.raw['detail']?.toString() ??
          'Review visible symptoms and field conditions before treatment.',
      causes:
          prediction.raw['cause']?.toString() ??
          'Cause depends on crop stage, weather, and field history.',
      treatment:
          prediction.raw['treatment']?.toString() ??
          'Remove heavily affected leaves and consult local guidance before spraying.',
      preventiveMeasures:
          prediction.raw['preventive_measures']?.toString() ??
          'Improve airflow, avoid overhead irrigation, and monitor the crop regularly.',
      localizedTreatment:
          prediction.raw['localized_treatment']?.toString() ??
          'Krishi expert se salah lekar hi spray karein.',
      weatherCorrelation:
          prediction.raw['weather_correlation']?.toString() ??
          'Humidity and recent rainfall can increase disease pressure.',
      organicTreatment:
          prediction.raw['organic_treatment']?.toString() ??
          'Remove infected material and use approved organic controls where suitable.',
      chemicalTreatment:
          prediction.raw['chemical_treatment']?.toString() ??
          'Use crop-specific chemical treatment only after expert confirmation.',
      professionalTips: const [
        'Take another clear photo after 3-4 days to compare spread.',
        'Record irrigation and fertilizer history with the scan.',
        'Avoid blanket spraying until the disease is confirmed locally.',
      ],
      scannedAt: DateTime.now(),
      dateLabel: 'Today',
    );
  }

  final String scanId;
  final String crop;
  final String disease;
  final int confidence;
  final RiskLevel risk;
  final String description;
  final String symptoms;
  final String causes;
  final String treatment;
  final String preventiveMeasures;
  final String localizedTreatment;
  final String weatherCorrelation;
  final String organicTreatment;
  final String chemicalTreatment;
  final List<String> professionalTips;
  final DateTime scannedAt;
  final String dateLabel;

  ScanReport copyWith({
    String? scanId,
    DateTime? scannedAt,
    String? dateLabel,
  }) {
    return ScanReport(
      scanId: scanId ?? this.scanId,
      crop: crop,
      disease: disease,
      confidence: confidence,
      risk: risk,
      description: description,
      symptoms: symptoms,
      causes: causes,
      treatment: treatment,
      preventiveMeasures: preventiveMeasures,
      localizedTreatment: localizedTreatment,
      weatherCorrelation: weatherCorrelation,
      organicTreatment: organicTreatment,
      chemicalTreatment: chemicalTreatment,
      professionalTips: professionalTips,
      scannedAt: scannedAt ?? this.scannedAt,
      dateLabel: dateLabel ?? this.dateLabel,
    );
  }

  String get severityLabel {
    switch (risk) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }

  Color get riskColor {
    switch (risk) {
      case RiskLevel.low:
        return _primary;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }
}

enum RiskLevel { low, medium, high }

enum ScanSource { camera, gallery }

class ChatMessage {
  const ChatMessage(this.text, this.isUser);

  final String text;
  final bool isUser;
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.color = Colors.white});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = isDark
        ? (color == Colors.white ? fx.surface : color.withAlpha(56))
        : color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveColor.withAlpha(isDark ? 255 : 236),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: fx.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 70 : 18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: fx.textStrong,
            ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class _TipLine extends StatelessWidget {
  const _TipLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fx.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final alpha = Theme.of(context).brightness == Brightness.dark ? 56 : 255;
    return CircleAvatar(
      backgroundColor: bg.withAlpha(alpha),
      child: Icon(icon, color: color),
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final alpha = Theme.of(context).brightness == Brightness.dark ? 48 : 24;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(alpha),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Stack(
        children: const [
          CircleAvatar(
            radius: 19,
            backgroundColor: _secondary,
            child: Icon(Icons.person, color: _primary),
          ),
          Positioned(
            left: 24,
            child: CircleAvatar(
              radius: 19,
              backgroundColor: _blue,
              child: Icon(Icons.person, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 14),
            Text(
              'AI scanning...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockImageCard extends StatelessWidget {
  const _MockImageCard({required this.crop});

  final String crop;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [fx.selectedFill, fx.fieldFill]),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 70,
            ),
            const SizedBox(height: 8),
            Text(
              crop,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportBlock extends StatelessWidget {
  const _ReportBlock({
    required this.title,
    required this.icon,
    required this.text,
  });

  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: fx.textStrong,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: fx.textMuted,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: const BoxConstraints(maxWidth: 310),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : fx.surface,
          borderRadius: BorderRadius.circular(18),
          border: message.isUser ? null : Border.all(color: fx.border),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Theme.of(context).colorScheme.onPrimary
                : fx.textStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({required this.name, required this.text});

  final String name;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _GlassCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: context.fx.selectedFill,
            child: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(text),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(BuildContext context, String hint) {
  final fx = context.fx;
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: fx.fieldFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: fx.border),
    ),
  );
}
