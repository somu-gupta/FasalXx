import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/image_input_service.dart';
import '../theme/app_theme.dart';

class FloatingAiChatbot extends StatefulWidget {
  const FloatingAiChatbot({super.key});

  @override
  State<FloatingAiChatbot> createState() => _FloatingAiChatbotState();
}

class _FloatingAiChatbotState extends State<FloatingAiChatbot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      right: 22,
      bottom: 118 + bottomPadding,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _idleController,
          builder: (context, child) {
            final wave = math.sin(_idleController.value * math.pi * 2);
            final floatOffset = wave * 2.2;
            final idleScale = 1 + (wave * 0.012);

            return Transform.translate(
              offset: Offset(0, floatOffset),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                scale: (_isPressed ? 0.93 : 1) * idleScale,
                child: child,
              ),
            );
          },
          child: _AssistantFab(
            onTap: () => _openChat(context),
            onTapDown: () => setState(() => _isPressed = true),
            onTapCancel: () => setState(() => _isPressed = false),
            onTapUp: () => setState(() => _isPressed = false),
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x59000000),
      builder: (context) => const _ChatSheet(),
    );
  }
}

class _AssistantFab extends StatelessWidget {
  const _AssistantFab({
    required this.onTap,
    required this.onTapDown,
    required this.onTapCancel,
    required this.onTapUp,
  });

  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapCancel;
  final VoidCallback onTapUp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fx = context.fx;

    return Semantics(
      button: true,
      label: 'Open FasalX AI assistant',
      child: GestureDetector(
        onTapDown: (_) => onTapDown(),
        onTapCancel: onTapCancel,
        onTapUp: (_) => onTapUp(),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(64),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: fx.success.withAlpha(38),
                blurRadius: 34,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [fx.success, colorScheme.primaryContainer],
                ),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: const Color(0x33FFFFFF),
                highlightColor: const Color(0x22FFFFFF),
                onTap: onTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    Positioned(
                      top: 9,
                      right: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: fx.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: fx.surface, width: 1.7),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: const Color(0x33FFFFFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatSheet extends StatefulWidget {
  const _ChatSheet();

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  SelectedImage? _pendingImage;
  bool _isVoiceListening = false;
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Namaste! Main FasalX AI hoon. Aap fasal, mausam ya dawa ke baare mein pooch sakte hain.',
      isUser: false,
    ),
    const _ChatMessage(
      text: 'Example: Gehu mein peele patte kyu aa rahe hain?',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    final image = _pendingImage;
    if (text.isEmpty && image == null) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, image: image, isUser: true));
      _messages.add(
        const _ChatMessage(
          text:
              'Photo/detail mil gayi. Kripya crop name, location, aur symptoms bhi bhejein. Main simple next steps bataunga.',
          isUser: false,
        ),
      );
      _pendingImage = null;
    });
    _controller.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    final image = await pickChatImage();
    if (!mounted) {
      return;
    }

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image select nahi hui. Chrome par photo attach kar sakte hain.',
          ),
        ),
      );
      return;
    }

    setState(() => _pendingImage = image);
  }

  void _handleMic() {
    setState(() => _isVoiceListening = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listening indicator on. Voice input coming soon.'),
      ),
    );

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() => _isVoiceListening = false);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final isWide = size.width > 700;
    final sheetHeight = size.height * (isWide ? 0.78 : 0.86);
    final fx = context.fx;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboard),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 620 : double.infinity,
            maxHeight: sheetHeight,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fx.surfaceAlt,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 30,
                  offset: Offset(0, -12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Column(
                children: [
                  const _ChatHeader(),
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                      itemCount: _messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _MessageBubble(message: _messages[index]);
                      },
                    ),
                  ),
                  _Composer(
                    controller: _controller,
                    image: _pendingImage,
                    isVoiceListening: _isVoiceListening,
                    onSend: _sendMessage,
                    onImage: _pickImage,
                    onRemoveImage: () => setState(() => _pendingImage = null),
                    onMic: _handleMic,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 10, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.primary],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x24FFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: onPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FasalX AI Sahayak',
                  style: TextStyle(
                    color: onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hindi + English farming help',
                  style: TextStyle(color: onPrimary, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            icon: Icon(Icons.close_rounded, color: onPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final fx = context.fx;
    final bubbleColor = message.isUser
        ? Theme.of(context).colorScheme.primary
        : fx.surface;
    final textColor = message.isUser
        ? Theme.of(context).colorScheme.onPrimary
        : fx.textStrong;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(message.isUser ? 18 : 6),
      bottomRight: Radius.circular(message.isUser ? 6 : 18),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: radius,
            border: message.isUser ? null : Border.all(color: fx.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.image != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      message.image!.bytes,
                      width: 240,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined, size: 16, color: textColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          message.image!.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (message.text.isNotEmpty) const SizedBox(height: 10),
                ],
                if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      height: 1.35,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.image,
    required this.isVoiceListening,
    required this.onSend,
    required this.onImage,
    required this.onRemoveImage,
    required this.onMic,
  });

  final TextEditingController controller;
  final SelectedImage? image;
  final bool isVoiceListening;
  final VoidCallback onSend;
  final VoidCallback onImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: fx.surface,
        border: Border(top: BorderSide(color: fx.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null) ...[
            _ImagePreview(image: image!, onRemove: onRemoveImage),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton.filledTonal(
                  tooltip: 'Add image',
                  onPressed: onImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                height: 48,
                child: _VoiceInputButton(
                  isListening: isVoiceListening,
                  onTap: onMic,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Sawaal ya photo detail...',
                    filled: true,
                    fillColor: fx.fieldFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 52,
                child: IconButton.filled(
                  tooltip: 'Send',
                  onPressed: onSend,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onRemove});

  final SelectedImage image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: fx.fieldFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: fx.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              image.bytes,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo attached',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: fx.textStrong,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  image.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fx.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove image',
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _VoiceInputButton extends StatelessWidget {
  const _VoiceInputButton({required this.isListening, required this.onTap});

  final bool isListening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          scale: isListening ? 1.12 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: isListening ? 48 : 40,
            height: isListening ? 48 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening ? fx.selectedFill : Colors.transparent,
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: isListening ? 'Listening' : 'Voice input',
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: isListening ? fx.selectedFill : fx.fieldFill,
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isListening ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
              key: ValueKey(isListening),
            ),
          ),
        ),
        if (isListening)
          Positioned(
            top: 6,
            right: 7,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: fx.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser, this.image});

  final String text;
  final bool isUser;
  final SelectedImage? image;
}
