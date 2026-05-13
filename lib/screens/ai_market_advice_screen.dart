import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/fasalx_header.dart';

class AiMarketAdviceScreen extends StatefulWidget {
  const AiMarketAdviceScreen({
    super.key,
    this.onBack,
    this.bottomNavigationInset,
  });

  final VoidCallback? onBack;
  final double? bottomNavigationInset;

  @override
  State<AiMarketAdviceScreen> createState() => _AiMarketAdviceScreenState();
}

class _AiMarketAdviceScreenState extends State<AiMarketAdviceScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isVoiceListening = false;
  bool _isThinking = false;

  final List<_MarketMessage> _messages = [
    const _MarketMessage(
      text:
          'Namaste! I can help you decide when to sell, compare nearby mandi prices, and understand tomorrow price movement.',
      isUser: false,
    ),
    const _MarketMessage(
      text: 'Try asking: Should I sell wheat today or wait for tomorrow?',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _back() {
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = (overrideText ?? _controller.text).trim();
    if (text.isEmpty || _isThinking) return;

    setState(() {
      _messages.add(_MarketMessage(text: text, isUser: true));
      _isThinking = true;
    });
    _controller.clear();
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;

    setState(() {
      _messages.add(_MarketMessage(text: _buildReply(text), isUser: false));
      _isThinking = false;
    });
    _scrollToBottom();
  }

  void _handleMic() {
    if (_isVoiceListening || _isThinking) return;
    setState(() => _isVoiceListening = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listening for market question...')),
    );

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isVoiceListening = false);
      _sendMessage('Which mandi is best for selling wheat today?');
    });
  }

  String _buildReply(String question) {
    final text = question.toLowerCase();
    if (text.contains('wheat') || text.contains('gehu')) {
      return 'Wheat is strongest at Bhopal Mandi today. Modal price is Rs 2,340/quintal, up 3.8%. If transport is available, selling 40-60% stock today is a good option.';
    }
    if (text.contains('tomato') || text.contains('vegetable')) {
      return 'Tomato prices are volatile. Indore shows better demand, but wait 1 day if your produce can stay fresh. Set an alert above Rs 1,850/quintal.';
    }
    if (text.contains('soybean')) {
      return 'Soybean has positive movement this week. Nearby mandis show 2-4% upside, so holding for 24 hours may improve the selling price.';
    }
    if (text.contains('best') || text.contains('mandi')) {
      return 'Best nearby option is Bhopal Mandi based on current modal price, distance, and arrival quantity. Compare Sehore if you have larger quantity above 25 quintals.';
    }
    return 'Based on current mandi movement, sell crops with rising demand today and hold crops with low arrivals for 24 hours. Share crop name, quantity, and location for exact advice.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final bottomNavigationInset =
        widget.bottomNavigationInset ?? (82 + bottomPadding);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const FasalXHeader(),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomNavigationInset),
        child: Column(
          children: [
            _MarketAdviceTopBar(onBack: _back),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                itemCount: _chatItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _chatItems[index];
                  return switch (item) {
                    _MarketInsightItem() => const _MarketInsightCard(),
                    _MarketThinkingItem() => _ThinkingBubble(),
                    _MarketMessageItem(:final message) => _MarketMessageBubble(
                      message: message,
                    ),
                  };
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                color: fx.surface,
                border: Border(top: BorderSide(color: fx.border)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 18,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: _MarketComposer(
                controller: _controller,
                isVoiceListening: _isVoiceListening,
                isSending: _isThinking,
                onMic: _handleMic,
                onSend: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MarketChatItem> get _chatItems {
    return [
      if (_isThinking) const _MarketThinkingItem(),
      for (final message in _messages.reversed) _MarketMessageItem(message),
      const _MarketInsightItem(),
    ];
  }
}

sealed class _MarketChatItem {
  const _MarketChatItem();
}

class _MarketInsightItem extends _MarketChatItem {
  const _MarketInsightItem();
}

class _MarketThinkingItem extends _MarketChatItem {
  const _MarketThinkingItem();
}

class _MarketMessageItem extends _MarketChatItem {
  const _MarketMessageItem(this.message);

  final _MarketMessage message;
}

class _MarketAdviceTopBar extends StatelessWidget {
  const _MarketAdviceTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      decoration: BoxDecoration(
        color: fx.surfaceAlt,
        border: Border(bottom: BorderSide(color: fx.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: IconButton.filledTonal(
              tooltip: 'Back',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Market Advice',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: fx.textStrong,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.online_prediction_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Live mandi guidance with voice support',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fx.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketInsightCard extends StatelessWidget {
  const _MarketInsightCard();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [fx.selectedFill, fx.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withAlpha(35)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withAlpha(24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today market signal',
                      style: TextStyle(
                        color: fx.textStrong,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Wheat and soybean demand is improving.',
                      style: TextStyle(
                        color: fx.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _AdviceChip(
                icon: Icons.trending_up_rounded,
                label: 'Sell timing',
              ),
              _AdviceChip(
                icon: Icons.compare_arrows_rounded,
                label: 'Compare mandi',
              ),
              _AdviceChip(
                icon: Icons.notifications_active_outlined,
                label: 'Price alerts',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdviceChip extends StatelessWidget {
  const _AdviceChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fx.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fx.textStrong,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketMessageBubble extends StatelessWidget {
  const _MarketMessageBubble({required this.message});

  final _MarketMessage message;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final userColor = Theme.of(context).colorScheme.primary;
    final alignment = message.isUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final bubbleColor = message.isUser ? userColor : fx.surface;
    final textColor = message.isUser
        ? Theme.of(context).colorScheme.onPrimary
        : fx.textStrong;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(message.isUser ? 20 : 7),
              bottomRight: Radius.circular(message.isUser ? 7 : 20),
            ),
            border: message.isUser ? null : Border.all(color: fx.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Text(
              message.text,
              style: TextStyle(
                color: textColor,
                height: 1.35,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: fx.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: fx.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Checking market signals...',
              style: TextStyle(
                color: fx.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketComposer extends StatelessWidget {
  const _MarketComposer({
    required this.controller,
    required this.isVoiceListening,
    required this.isSending,
    required this.onMic,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isVoiceListening;
  final bool isSending;
  final VoidCallback onMic;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Row(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: _MarketVoiceButton(
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
              hintText: 'Ask about crop prices, best mandi...',
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
            onPressed: isSending ? null : onSend,
            icon: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
          ),
        ),
      ],
    );
  }
}

class _MarketVoiceButton extends StatelessWidget {
  const _MarketVoiceButton({required this.isListening, required this.onTap});

  final bool isListening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final primary = Theme.of(context).colorScheme.primary;
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          scale: isListening ? 1.14 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: isListening ? 50 : 42,
            height: isListening ? 50 : 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening ? primary.withAlpha(24) : Colors.transparent,
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: isListening ? 'Listening' : 'Voice input',
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: isListening ? fx.selectedFill : fx.fieldFill,
            foregroundColor: primary,
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
            top: 7,
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

class _MarketMessage {
  const _MarketMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}
