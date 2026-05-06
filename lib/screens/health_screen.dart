import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/image_input_service.dart';

const _primary = Color(0xFF1B8A5A);
const _secondary = Color(0xFFDFF5EC);
const _yellow = Color(0xFFFFF4CC);
const _blue = Color(0xFFE8F1FF);
const _bg = Color(0xFFF7FAF4);
const _ink = Color(0xFF17251A);

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scans = MockHealthApi.scanHistory;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Crop Health', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 176),
        children: [
          _HeroScannerCard(
            onCamera: () => _openScan(context, ScanSource.camera),
            onGallery: () => _openScan(context, ScanSource.gallery),
          ),
          const SizedBox(height: 14),
          const _ScanningTipsCard(),
          const SizedBox(height: 14),
          const _ExpertAssistanceCard(),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Community Guidance',
            action: 'Ask Question',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AskQuestionScreen()),
            ),
          ),
          const SizedBox(height: 10),
          const _CommunityPostCard(
            name: 'Suresh',
            location: 'Vidisha',
            tag: 'WHEAT YELLOWING',
            question: 'Wheat leaves are turning yellow after irrigation. What should I check first?',
            replies: 12,
            likes: 34,
          ),
          const SizedBox(height: 10),
          const _CommunityPostCard(
            name: 'Meena',
            location: 'Sehore',
            tag: 'ORGANIC PESTICIDES',
            question: 'Which organic spray works for sucking pests in vegetables?',
            replies: 8,
            likes: 21,
          ),
          const SizedBox(height: 12),
          const _ExploreCommunitiesButton(),
          const SizedBox(height: 18),
          const _SectionHeader(title: 'Past Alerts / Scan History'),
          const SizedBox(height: 10),
          for (final scan in scans.take(3)) ...[
            _ScanHistoryTile(scan: scan),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Future<void> _openScan(BuildContext context, ScanSource source) async {
    if (source == ScanSource.camera) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScanScreen(source: ScanSource.camera)),
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
          content: Text(
            'Gallery could not be opened. Please try again.',
          ),
        ),
      );
      return;
    }

    if (!context.mounted) return;

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No gallery image selected.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScanScreen(source: source, initialImage: image)),
    );
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
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))
      ..repeat(reverse: true);
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
          BoxShadow(color: Color(0x331B8A5A), blurRadius: 24, offset: Offset(0, 12)),
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
                  child: Icon(Icons.document_scanner_outlined, color: _primary, size: 31),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withAlpha(60)),
                ),
                child: const Text(
                  '95% Accuracy | AI Powered',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Scan Crop for Disease',
            style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Detect plant diseases instantly using AI',
            style: TextStyle(color: Color(0xE6FFFFFF), fontWeight: FontWeight.w700),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Camera', style: TextStyle(fontWeight: FontWeight.w900)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.w900)),
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
    return _GlassCard(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                const _IconBubble(icon: Icons.lightbulb_outline, color: Color(0xFFC28A00), bg: _yellow),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('AI Scanning Tips', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                ),
                Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Column(
                children: [
                  _TipLine(icon: Icons.photo_camera_outlined, text: 'Keep image sharp'),
                  _TipLine(icon: Icons.eco_outlined, text: 'Use plain background'),
                  _TipLine(icon: Icons.wb_sunny_outlined, text: 'Ensure good lighting'),
                ],
              ),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kisan Helpline', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    SizedBox(height: 5),
                    Text('Connect with verified agronomists', style: TextStyle(color: Color(0xFF667366))),
                  ],
                ),
              ),
              const _AvatarPreview(),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.circle, color: _primary, size: 10),
              SizedBox(width: 6),
              Text('Online Experts', style: TextStyle(fontWeight: FontWeight.w900, color: _primary)),
              Spacer(),
              Text('Avg response: 2 min', style: TextStyle(color: Color(0xFF667366), fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _HelpButton(icon: Icons.call_outlined, label: 'Call', onTap: () {})),
              const SizedBox(width: 10),
              Expanded(
                child: _HelpButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExpertChatScreen(prefilledQuery: 'Need help with crop disease symptoms.')),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _HelpButton(icon: Icons.videocam_outlined, label: 'Video', onTap: () {})),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.name,
    required this.location,
    required this.tag,
    required this.question,
    required this.replies,
    required this.likes,
  });

  final String name;
  final String location;
  final String tag;
  final String question;
  final int replies;
  final int likes;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: _secondary, child: Icon(Icons.person_outline, color: _primary)),
              const SizedBox(width: 10),
              Expanded(child: Text('$name - $location', style: const TextStyle(fontWeight: FontWeight.w900))),
              _Tag(label: tag, color: _primary),
            ],
          ),
          const SizedBox(height: 10),
          Text(question, style: const TextStyle(height: 1.35, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.forum_outlined, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('$replies replies'),
              const SizedBox(width: 12),
              Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('$likes likes'),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CommunityDiscussionScreen(question: question, tag: tag)),
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

class _ExploreCommunitiesButton extends StatefulWidget {
  const _ExploreCommunitiesButton();

  @override
  State<_ExploreCommunitiesButton> createState() => _ExploreCommunitiesButtonState();
}

class _ExploreCommunitiesButtonState extends State<_ExploreCommunitiesButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : 1,
      child: Material(
        color: const Color(0xFFF0F7F2),
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AllCommunitiesScreen()),
          ),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 8)),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.groups_2_outlined, color: _primary, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Explore All Communities',
                    style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: _primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanHistoryTile extends StatelessWidget {
  const _ScanHistoryTile({required this.scan});

  final ScanReport scan;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailedReportScreen(report: scan))),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      leading: CircleAvatar(
        backgroundColor: scan.risk == RiskLevel.high ? const Color(0xFFFFE4E6) : _secondary,
        child: Icon(Icons.eco_outlined, color: scan.risk == RiskLevel.high ? Colors.red : _primary),
      ),
      title: Text('${scan.crop} - ${scan.disease}', style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text('${scan.severityLabel} Risk - ${scan.dateLabel}'),
      trailing: const Icon(Icons.chevron_right_rounded),
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
      setState(() => _cameraError = 'Camera is not available. Use gallery instead.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.source == ScanSource.camera ? 'Camera Scan' : 'Gallery Scan'),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(120),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _selectedImage!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
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
                          _selectedImage == null ? 'Place leaf inside frame' : 'Ready to scan crop image',
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
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
                IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.flash_on_outlined)),
                IconButton.filledTonal(
                  onPressed: _isScanning ? null : () => _pickImage(fromCamera: false, scanAfterPick: false),
                  icon: const Icon(Icons.image_outlined),
                ),
                SizedBox(
                  width: 82,
                  height: 82,
                  child: FilledButton(
                    onPressed: _isScanning ? null : _capture,
                    style: FilledButton.styleFrom(shape: const CircleBorder(), backgroundColor: _primary),
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
                const Icon(Icons.no_photography_outlined, color: Colors.white38, size: 78),
                const SizedBox(height: 14),
                Text(
                  _cameraError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(fromCamera: false, scanAfterPick: false),
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
            Text('Opening camera...', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
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
          setState(() => _selectedImage = SelectedImage(name: picture.name, bytes: bytes));
        } catch (_) {
          final picked = await _pickImage(fromCamera: true, scanAfterPick: false);
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
    final report = await MockHealthApi.scanCrop();
    if (!mounted) return;
    setState(() => _isScanning = false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ScanResultScreen(report: report)));
  }

  Future<bool> _pickImage({required bool fromCamera, required bool scanAfterPick}) async {
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
        SnackBar(content: Text(fromCamera ? 'No camera photo selected.' : 'No gallery image selected.')),
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
}

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key, required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(title: const Text('Scan Result'), backgroundColor: _bg, surfaceTintColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _MockImageCard(crop: report.crop),
          const SizedBox(height: 14),
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Disease Detected', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 8),
                Text(report.disease, style: const TextStyle(color: _primary, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Confidence: ${report.confidence}%', style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _Tag(label: '${report.severityLabel} Severity', color: report.riskColor),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _TreatmentCard(report: report),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ExpertChatScreen(prefilledQuery: 'My ${report.crop} has ${report.disease}. What should I do?')),
                  ),
                  icon: const Icon(Icons.support_agent_rounded),
                  label: const Text('Talk to Expert'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailedReportScreen(report: report))),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Report'),
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
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(title: const Text('Detailed Report'), backgroundColor: _bg, surfaceTintColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.disease, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _primary)),
                const SizedBox(height: 8),
                Text(report.description, style: const TextStyle(height: 1.4, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ReportBlock(title: 'Causes', icon: Icons.biotech_outlined, text: report.causes),
          _ReportBlock(title: 'Preventive Measures', icon: Icons.shield_outlined, text: report.prevention),
          _ReportBlock(title: 'Ilaj / Treatment', icon: Icons.medical_services_outlined, text: report.localizedTreatment),
          _ReportBlock(title: 'Weather Correlation', icon: Icons.cloud_outlined, text: report.weatherCorrelation),
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
    const ChatMessage('Namaste. Please share crop age and field photo if possible.', false),
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
      backgroundColor: _bg,
      appBar: AppBar(title: const Text('Expert Chat'), backgroundColor: _bg, surfaceTintColor: Colors.transparent),
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
                IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.image_outlined)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      filled: true,
                      fillColor: _bg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _send, icon: const Icon(Icons.send_rounded)),
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
      _messages.add(const ChatMessage('Thanks. Expert will review and reply shortly.', false));
    });
    _controller.clear();
  }
}

class CommunityDiscussionScreen extends StatelessWidget {
  const CommunityDiscussionScreen({super.key, required this.question, required this.tag});

  final String question;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(title: const Text('Discussion'), backgroundColor: _bg, surfaceTintColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Tag(label: tag, color: _primary),
                const SizedBox(height: 10),
                Text(question, style: const TextStyle(fontSize: 18, height: 1.35, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.thumb_up_alt_outlined), label: const Text('Like')),
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.reply_outlined), label: const Text('Reply')),
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined), label: const Text('Share')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _ReplyTile(name: 'Agronomist Kavita', text: 'Check nitrogen deficiency first. Share a close photo of lower leaves.'),
          const _ReplyTile(name: 'Farmer Manoj', text: 'I used soil test advice and yellowing reduced in 10 days.'),
        ],
      ),
    );
  }
}

class AllCommunitiesScreen extends StatefulWidget {
  const AllCommunitiesScreen({super.key});

  @override
  State<AllCommunitiesScreen> createState() => _AllCommunitiesScreenState();
}

class _AllCommunitiesScreenState extends State<AllCommunitiesScreen> {
  final _search = TextEditingController();
  String _filter = 'Wheat';
  late List<FarmerCommunity> _communities;

  static const _filters = ['Wheat', 'Rice', 'Vegetables', 'Fruits', 'Organic Farming', 'Pest Control'];

  @override
  void initState() {
    super.initState();
    _communities = MockCommunityApi.communities.map((item) => item.copy()).toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<FarmerCommunity> get _visibleCommunities {
    final query = _search.text.toLowerCase();
    return _communities.where((community) {
      final matchesFilter = community.topics.contains(_filter);
      final matchesSearch = query.isEmpty ||
          community.title.toLowerCase().contains(query) ||
          community.topics.join(' ').toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleCommunities;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Farmer Communities', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AskQuestionScreen(
              communities: _communities.map((item) => item.title).toList(),
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
            decoration: _inputDecoration('Search crops, diseases, topics...').copyWith(
              prefixIcon: const Icon(Icons.search_rounded),
            ),
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
                    selectedColor: _secondary,
                    labelStyle: TextStyle(
                      color: _filter == filter ? _primary : const Color(0xFF667366),
                      fontWeight: FontWeight.w900,
                    ),
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final community in visible) ...[
            _CommunityListCard(
              community: community,
              onJoin: () => setState(() => community.joined = !community.joined),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CommunityDetailScreen(community: community),
                  ),
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
          ],
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No communities found')),
            ),
        ],
      ),
    );
  }
}

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({super.key, required this.community});

  final FarmerCommunity community;

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          title: Text(widget.community.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: _bg,
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
              builder: (_) => AskQuestionScreen(communities: [widget.community.title]),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Ask Question'),
        ),
        body: Column(
          children: [
            _CommunityDetailHeader(
              community: widget.community,
              onJoin: () => setState(() => widget.community.joined = !widget.community.joined),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CommunityPostsList(community: widget.community),
                  _CommunityPostsList(community: widget.community),
                  const Center(child: Text('Media gallery coming soon')),
                ],
              ),
            ),
          ],
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
                  Text(community.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('${community.members} farmers', style: const TextStyle(color: Color(0xFF667366), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${community.activeToday} active today', style: const TextStyle(color: _primary, fontWeight: FontWeight.w800)),
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
                  Text(community.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('${community.members} farmers - ${community.activeToday} active today'),
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
          _CommunityPostCard(
            name: post.name,
            location: post.location,
            tag: post.tag,
            question: post.question,
            replies: post.replies,
            likes: post.likes,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key, this.communities = const ['Wheat Disease Support', 'Organic Farming India']});

  final List<String> communities;

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  String _crop = 'Wheat';
  late String _community;
  final _question = TextEditingController();

  @override
  void initState() {
    super.initState();
    _community = widget.communities.first;
  }

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(title: const Text('Ask Question'), backgroundColor: _bg, surfaceTintColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _crop,
            decoration: _inputDecoration('Select crop type'),
            items: const ['Wheat', 'Rice', 'Soyabean', 'Tomato']
                .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                .toList(),
            onChanged: (value) => setState(() => _crop = value ?? _crop),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _community,
            decoration: _inputDecoration('Select community'),
            items: widget.communities
                .map((community) => DropdownMenuItem(value: community, child: Text(community)))
                .toList(),
            onChanged: (value) => setState(() => _community = value ?? _community),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _question,
            minLines: 5,
            maxLines: 8,
            decoration: _inputDecoration('Describe your crop problem...'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.image_outlined), label: const Text('Add Image')),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question submitted to community.')));
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Suggested Treatment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _TipLine(icon: Icons.eco_outlined, text: 'Organic: ${report.organicTreatment}'),
          _TipLine(icon: Icons.science_outlined, text: 'Chemical: ${report.chemicalTreatment}'),
        ],
      ),
    );
  }
}

class MockHealthApi {
  static final scanHistory = [
    ScanReport.tomato(),
    ScanReport.wheat(),
    ScanReport.chilli(),
  ];

  static Future<ScanReport> scanCrop() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return ScanReport.tomato();
  }
}

class MockCommunityApi {
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
          name: 'Suresh',
          location: 'Vidisha',
          tag: 'WHEAT YELLOWING',
          question: 'Wheat leaves are turning yellow after irrigation. What should I check first?',
          replies: 12,
          likes: 34,
        ),
        CommunityPost(
          name: 'Ravi',
          location: 'Bhopal',
          tag: 'YELLOW RUST',
          question: 'Can yellow rust spread after foggy mornings?',
          replies: 18,
          likes: 42,
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
          name: 'Meena',
          location: 'Sehore',
          tag: 'ORGANIC PESTICIDES',
          question: 'Which organic spray works for sucking pests in vegetables?',
          replies: 8,
          likes: 21,
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
          name: 'Arjun',
          location: 'Balaghat',
          tag: 'PADDY BLAST',
          question: 'Brown spots are appearing after rain. Is it blast?',
          replies: 15,
          likes: 27,
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
          name: 'Kavita',
          location: 'Indore',
          tag: 'FRUIT DROP',
          question: 'Guava fruit drop is increasing. What nutrient should I check?',
          replies: 7,
          likes: 18,
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
      posts: List.of(posts),
    );
  }
}

class CommunityPost {
  const CommunityPost({
    required this.name,
    required this.location,
    required this.tag,
    required this.question,
    required this.replies,
    required this.likes,
  });

  final String name;
  final String location;
  final String tag;
  final String question;
  final int replies;
  final int likes;
}

class ScanReport {
  const ScanReport({
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.risk,
    required this.description,
    required this.causes,
    required this.prevention,
    required this.localizedTreatment,
    required this.weatherCorrelation,
    required this.organicTreatment,
    required this.chemicalTreatment,
    required this.dateLabel,
  });

  factory ScanReport.tomato() => const ScanReport(
        crop: 'Tomato Leaf',
        disease: 'Early Blight',
        confidence: 92,
        risk: RiskLevel.high,
        description: 'A fungal disease that creates dark spots and leaf yellowing.',
        causes: 'High humidity, infected residue, and poor airflow.',
        prevention: 'Remove infected leaves, rotate crops, and avoid overhead irrigation.',
        localizedTreatment: 'Sankramit patte hataen aur subah ke samay safe fungicide spray karein.',
        weatherCorrelation: 'Risk increases when humidity is above 70% with warm temperature.',
        organicTreatment: 'Neem oil spray and remove affected leaves.',
        chemicalTreatment: 'Use recommended fungicide after expert confirmation.',
        dateLabel: 'Today',
      );

  factory ScanReport.wheat() => const ScanReport(
        crop: 'Wheat',
        disease: 'Yellow Rust',
        confidence: 87,
        risk: RiskLevel.medium,
        description: 'Yellow stripes on wheat leaves that reduce crop vigor.',
        causes: 'Cool and humid conditions with infected spores.',
        prevention: 'Use resistant variety and monitor early symptoms.',
        localizedTreatment: 'Peeli dhariyan dikhen to krishi expert se salah lekar spray karein.',
        weatherCorrelation: 'Cool mornings and high moisture can increase spread.',
        organicTreatment: 'Improve field airflow and remove infected patches.',
        chemicalTreatment: 'Use triazole fungicide as advised.',
        dateLabel: 'Yesterday',
      );

  factory ScanReport.chilli() => const ScanReport(
        crop: 'Chilli',
        disease: 'Leaf Curl',
        confidence: 81,
        risk: RiskLevel.low,
        description: 'Leaf curling often linked with sucking pests.',
        causes: 'Whitefly and viral infection pressure.',
        prevention: 'Use yellow sticky traps and inspect weekly.',
        localizedTreatment: 'Safed makkhi control ke liye yellow sticky traps lagayen.',
        weatherCorrelation: 'Dry warm weather can increase whitefly activity.',
        organicTreatment: 'Neem-based spray and sticky traps.',
        chemicalTreatment: 'Use pest-specific pesticide only if threshold is crossed.',
        dateLabel: '2 days ago',
      );

  final String crop;
  final String disease;
  final int confidence;
  final RiskLevel risk;
  final String description;
  final String causes;
  final String prevention;
  final String localizedTreatment;
  final String weatherCorrelation;
  final String organicTreatment;
  final String chemicalTreatment;
  final String dateLabel;

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(236),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(180)),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 24, offset: Offset(0, 10)),
          BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 10, offset: Offset(-3, -3)),
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
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _ink))),
        if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: _primary, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.color, required this.bg});

  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(backgroundColor: bg, child: Icon(icon, color: color));
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.icon, required this.label, required this.onTap});

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
        foregroundColor: _primary,
        side: const BorderSide(color: _primary),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: color.withAlpha(24), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
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
          CircleAvatar(radius: 19, backgroundColor: _secondary, child: Icon(Icons.person, color: _primary)),
          Positioned(left: 24, child: CircleAvatar(radius: 19, backgroundColor: _blue, child: Icon(Icons.person, color: Colors.blue))),
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
            Text('AI scanning...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [_secondary, Color(0xFFBDEACF)]),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco_outlined, color: _primary, size: 70),
            const SizedBox(height: 8),
            Text(crop, style: const TextStyle(color: _primary, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _ReportBlock extends StatelessWidget {
  const _ReportBlock({required this.title, required this.icon, required this.text});

  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: _primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w900))]),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(height: 1.4, fontWeight: FontWeight.w700)),
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
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: const BoxConstraints(maxWidth: 310),
        decoration: BoxDecoration(
          color: message.isUser ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : _ink, fontWeight: FontWeight.w700)),
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
          leading: const CircleAvatar(backgroundColor: _secondary, child: Icon(Icons.person_outline, color: _primary)),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(text),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: _secondary)),
  );
}
