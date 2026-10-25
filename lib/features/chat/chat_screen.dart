import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/features/chat/chat_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.watch<ChatRepository>();
    final session = repository.currentSession;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.chatHistory,
                onPressed: () => _showSessions(repository),
                icon: const Icon(Icons.menu_rounded),
              ),
              const SizedBox(width: 4),
              const CircleAvatar(child: Icon(Icons.auto_awesome_rounded)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session?.title ?? l10n.bibleAi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      repository.aiConfigured
                          ? l10n.chatSecureStatus
                          : l10n.aiEndpointNotConfigured,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.newChat,
                onPressed: () async {
                  await repository.createNewSession();
                },
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
              session == null || session.messages.isEmpty
                  ? _Suggestions(onSelected: _send)
                  : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                    itemCount: session.messages.length,
                    itemBuilder: (context, index) {
                      final message = session.messages[index];
                      return _MessageBubble(
                        message: message,
                        onRetry:
                            message.isError &&
                                    index == session.messages.length - 1 &&
                                    !repository.isLoading
                                ? repository.retryLastFailedMessage
                                : null,
                      );
                    },
                  ),
        ),
        if (repository.isLoading) const LinearProgressIndicator(minHeight: 2),
        const Divider(height: 1),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(hintText: l10n.askBibleHint),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: l10n.send,
                  onPressed:
                      repository.isLoading
                          ? null
                          : () => _send(_controller.text),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await context.read<ChatRepository>().sendMessage(text);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _showSessions(ChatRepository repository) async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              children: [
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: Text(l10n.newChat),
                  onTap: () async {
                    await repository.createNewSession();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                for (final session in repository.sessions)
                  ListTile(
                    selected: repository.currentSession?.id == session.id,
                    title: Text(session.title),
                    subtitle:
                        session.messages.isEmpty
                            ? Text(l10n.noMessages)
                            : Text(
                              session.messages.last.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    onTap: () async {
                      await repository.setCurrentSession(session);
                      if (context.mounted) Navigator.pop(context);
                    },
                    trailing: IconButton(
                      tooltip: l10n.deleteChat,
                      onPressed: () => repository.deleteSession(session.id),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prompts = [
      l10n.suggestionPrayerFocus,
      l10n.suggestionJohnContext,
      l10n.suggestionAnxiety,
      l10n.suggestionDevotional,
    ];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 52),
            const SizedBox(height: 16),
            Text(
              l10n.bibleAi,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(l10n.chatPrivacyIntro, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final prompt in prompts)
                  ActionChip(
                    label: Text(prompt),
                    onPressed: () => onSelected(prompt),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onRetry});

  final ChatMessage message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background =
        message.isError
            ? colors.errorContainer
            : message.isUser
            ? colors.primary
            : colors.surfaceContainerHighest;
    final foreground =
        message.isError
            ? colors.onErrorContainer
            : message.isUser
            ? colors.onPrimary
            : colors.onSurfaceVariant;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.text,
              style: TextStyle(color: foreground, height: 1.45),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: onRetry,
                style: TextButton.styleFrom(foregroundColor: foreground),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
