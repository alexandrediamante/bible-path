import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/services/storage_service.dart';
import 'features/chat/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSessions = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = context.watch<ChatRepository>();
    final storage = context.watch<StorageService>();
    final isDark = storage.userPreferences?.isDarkMode ?? false;
    final session = chatRepo.currentSession;

    return Row(
      children: [
        // Sessions Sidebar (optional)
        if (_showSessions)
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                ),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => chatRepo.createNewSession(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: chatRepo.sessions.length,
                    itemBuilder: (context, index) {
                      final s = chatRepo.sessions[index];
                      final isCurrent = chatRepo.currentSession?.id == s.id;
                      return ListTile(
                        title: Text(
                          s.title,
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          s.messages.isNotEmpty
                              ? s.messages.last.text
                              : 'No messages',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: isCurrent,
                        onTap: () => chatRepo.setCurrentSession(s),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_rounded, size: 18),
                          onPressed: () => chatRepo.deleteSession(s.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        // Main Chat Area
        Expanded(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(_showSessions ? Icons.chevron_left_rounded : Icons.menu_rounded),
                      onPressed: () => setState(() => _showSessions = !_showSessions),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isDark ? AppTheme.primaryLight.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 20,
                        color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bible AI',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            chatRepo.canSendMessage ? 'Ready to help' : 'Daily limit reached',
                            style: TextStyle(
                              fontSize: 12,
                              color: chatRepo.canSendMessage
                                  ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                                  : (isDark ? Colors.red.shade300 : Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () => chatRepo.createNewSession(),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: session == null
                    ? _EmptyChatState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: session.messages.length,
                        itemBuilder: (context, index) {
                          final message = session.messages[index];
                          return _ChatMessageTile(message: message);
                        },
                      ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ask a question...',
                          filled: true,
                          fillColor: isDark ? Colors.white10 : Colors.black12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        onTap: _sendMessage,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.send_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final chatRepo = context.read<ChatRepository>();
    chatRepo.addMessage(text, isUser: true);
    _controller.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate AI response
    chatRepo.simulateAIResponse(text);
  }
}

class _EmptyChatState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatRepo = context.read<ChatRepository>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.primaryLight.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 64,
                color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Bible AI!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me anything about the Bible, faith, or life. I\'m here to help you grow closer to God.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  label: 'How can I pray better?',
                  onTap: () => chatRepo.addMessage('How can I pray better?', isUser: true),
                ),
                _SuggestionChip(
                  label: 'Explain John 3:16',
                  onTap: () => chatRepo.addMessage('Explain John 3:16', isUser: true),
                ),
                _SuggestionChip(
                  label: 'Help with anxiety',
                  onTap: () => chatRepo.addMessage('Help with anxiety', isUser: true),
                ),
                _SuggestionChip(
                  label: 'Daily devotional',
                  onTap: () => chatRepo.addMessage('Give me a daily devotional', isUser: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: isDark ? Colors.white10 : Colors.black12,
      side: BorderSide(
        color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
      ),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? AppTheme.primaryLight.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? (isDark ? AppTheme.primaryLight : AppTheme.primaryColor)
                    : (isDark ? Colors.white10 : Colors.black12),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: message.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  if (message.verseReference != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Colors.white.withOpacity(0.2)
                            : (isDark ? Colors.white24 : Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message.verseReference!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: message.isUser ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? Colors.white24 : Colors.black12,
              child: Icon(
                Icons.person_rounded,
                size: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}