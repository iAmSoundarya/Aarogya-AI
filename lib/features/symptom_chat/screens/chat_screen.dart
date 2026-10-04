import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/urgency_banner.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/streaming_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatStarted());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _focusNode.unfocus();
    context.read<ChatBloc>().add(ChatMessageSent(text: text));
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Symptom Guidance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text('aarogya AI',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
            onPressed: () =>
                context.read<ChatBloc>().add(ChatCleared()),
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is ChatInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatLoaded) {
            return Column(
              children: [
                // Urgency banner (shows when last message has urgency >= high)
                if (state.messages.isNotEmpty &&
                    (state.messages.last.urgencyLevel ?? 0) >= 3)
                  UrgencyBanner(level: state.messages.last.urgencyLevel!),

                // Messages list
                Expanded(
                  child: state.messages.isEmpty && !state.isGenerating
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: state.messages.length +
                              (state.isGenerating ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.messages.length &&
                                state.isGenerating) {
                              return StreamingBubble(
                                token: state.streamingToken,
                              );
                            }
                            return ChatBubble(
                              message: state.messages[index],
                            );
                          },
                        ),
                ),

                // Error snackbar
                if (state.error != null)
                  _ErrorBar(message: state.error!),

                // Input bar
                _InputBar(
                  controller: _textController,
                  focusNode: _focusNode,
                  isGenerating: state.isGenerating,
                  isRecording: state.isRecording,
                  onSend: _sendMessage,
                  onVoiceStart: () =>
                      context.read<ChatBloc>().add(ChatVoiceRecordStarted()),
                  onVoiceStop: () =>
                      context.read<ChatBloc>().add(ChatVoiceRecordStopped()),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services_outlined,
                  size: 36, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Describe your symptoms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Speak or type in Hindi, Bhojpuri, Bengali or English. '
              'AI will guide you — no internet needed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Quick prompt chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                'बुखार है',
                'सिर दर्द',
                'सांस लेने में तकलीफ',
                'पेट दर्द',
              ]
                  .map((hint) => ActionChip(
                        label: Text(hint),
                        onPressed: () {
                          _textController.text = hint;
                          _sendMessage();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Input Bar ───────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isGenerating,
    required this.isRecording,
    required this.onSend,
    required this.onVoiceStart,
    required this.onVoiceStop,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isGenerating;
  final bool isRecording;
  final VoidCallback onSend;
  final VoidCallback onVoiceStart;
  final VoidCallback onVoiceStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Voice button
          VoiceInputButton(
            isRecording: isRecording,
            isDisabled: isGenerating,
            onStart: onVoiceStart,
            onStop: onVoiceStop,
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !isGenerating && !isRecording,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: isRecording
                    ? 'Listening...'
                    : 'Type symptoms or tap mic...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: isGenerating
                ? const SizedBox(
                    width: 44,
                    height: 44,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton.filled(
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onSend,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBar extends StatelessWidget {
  const _ErrorBar({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
          fontSize: 13,
        ),
      ),
    );
  }
}
