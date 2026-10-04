import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/chat_message.dart';

// ─── ChatBubble ───────────────────────────────────────────────────────────────

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessage message;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showReasoning = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Urgency badge for assistant messages
              if (!isUser && widget.message.urgencyLevel != null)
                _UrgencyBadge(level: widget.message.urgencyLevel!),

              // Main bubble
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Voice indicator
                    if (isUser && widget.message.isVoice)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic_rounded,
                                size: 13,
                                color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text('Voice',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.7))),
                          ],
                        ),
                      ),

                    Text(
                      widget.message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Reasoning toggle (explainable AI)
              if (!isUser &&
                  widget.message.reasoning != null &&
                  widget.message.reasoning!.isNotEmpty) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showReasoning = !_showReasoning),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showReasoning
                            ? Icons.expand_less
                            : Icons.info_outline_rounded,
                        size: 14,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showReasoning ? 'Hide reasoning' : 'Why this?',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showReasoning)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Text(
                      widget.message.reasoning!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54, height: 1.5),
                    ),
                  ),
              ],

              // Timestamp
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                child: Text(
                  _formatTime(widget.message.createdAt),
                  style:
                      TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── StreamingBubble ─────────────────────────────────────────────────────────

class StreamingBubble extends StatelessWidget {
  const StreamingBubble({super.key, required this.token});
  final String token;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: token.isEmpty
            ? const _TypingIndicator()
            : Text(token,
                style: const TextStyle(
                    fontSize: 15, height: 1.5, color: Colors.black87)),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final opacity = ((_ctrl.value + i / 3) % 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Opacity(
              opacity: opacity.clamp(0.2, 1.0),
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── UrgencyBanner ───────────────────────────────────────────────────────────

class UrgencyBanner extends StatelessWidget {
  const UrgencyBanner({super.key, required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (level) {
      4 => (Colors.red.shade700, '🚨 CRITICAL — Seek emergency care NOW', Icons.emergency_rounded),
      3 => (Colors.orange.shade700, '⚠️ HIGH — See a doctor today', Icons.warning_rounded),
      _ => (Colors.amber.shade700, 'ℹ️ Monitor symptoms closely', Icons.info_rounded),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withOpacity(0.12),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ]),
    );
  }
}

// ─── UrgencyBadge ────────────────────────────────────────────────────────────

class _UrgencyBadge extends StatelessWidget {
  const _UrgencyBadge({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AarogyaColors>()!;
    final color = colors.forLevel(level);
    final label = switch (level) {
      1 => 'Low urgency',
      2 => 'Medium urgency',
      3 => 'High urgency',
      _ => 'Critical',
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ─── VoiceInputButton ────────────────────────────────────────────────────────

class VoiceInputButton extends StatelessWidget {
  const VoiceInputButton({
    super.key,
    required this.isRecording,
    required this.isDisabled,
    required this.onStart,
    required this.onStop,
  });

  final bool isRecording;
  final bool isDisabled;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: isDisabled ? null : (_) => onStart(),
      onLongPressEnd: (_) => onStop(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording
              ? Colors.red.shade600
              : isDisabled
                  ? Colors.grey.shade300
                  : AppTheme.primaryGreen.withOpacity(0.15),
        ),
        child: Icon(
          isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
          color: isRecording
              ? Colors.white
              : isDisabled
                  ? Colors.grey
                  : AppTheme.primaryGreen,
          size: 22,
        ),
      ),
    );
  }
}
