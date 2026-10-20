import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/storage_service.dart';
import 'features/prayer/prayer_repository.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'All';
  bool _showAddPrayer = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerRepo = context.watch<PrayerRepository>();
    final storage = context.watch<StorageService>();
    final isDark = storage.userPreferences?.isDarkMode ?? false;
    final categories = ['All', 'Guidance', 'Healing', 'Forgiveness', 'Comfort', 'Gratitude', 'Strength'];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prayer Wall',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showAddPrayer = true),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Share Prayer'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Category Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                        selectedColor: isDark ? AppTheme.primaryLight.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.1),
                        checkmarkColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Add Prayer Form
        if (_showAddPrayer)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share Your Prayer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(() => _showAddPrayer = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your prayer request...',
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.black12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() => _showAddPrayer = false);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _controller.text.trim().isEmpty ? null : () {
                          prayerRepo.addPrayer(_controller.text.trim());
                          _controller.clear();
                          setState(() => _showAddPrayer = false);
                        },
                        child: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Prayer Wall
        Expanded(
          child: _PrayerWallList(
            prayers: prayerRepo.prayerWall,
            selectedCategory: _selectedCategory,
          ),
        ),
      ],
    );
  }
}

class _PrayerWallList extends StatelessWidget {
  final List<Prayer> prayers;
  final String selectedCategory;

  const _PrayerWallList({
    required this.prayers,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredPrayers = selectedCategory == 'All'
        ? prayers
        : prayers.where((p) => p.category == selectedCategory).toList();

    if (filteredPrayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selectedCategory == 'All' ? Icons.favorite_border_rounded : Icons.filter_list_off_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              selectedCategory == 'All' ? 'No prayers yet' : 'No prayers in this category',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedCategory == 'All'
                  ? 'Be the first to share a prayer!'
                  : 'Try selecting a different category.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPrayers.length,
      itemBuilder: (context, index) {
        final prayer = filteredPrayers[index];
        return _PrayerCard(prayer: prayer);
      },
    );
  }
}

class _PrayerCard extends StatefulWidget {
  final Prayer prayer;

  const _PrayerCard({required this.prayer});

  @override
  State<_PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<_PrayerCard> {
  bool _hasAmened = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerRepo = context.read<PrayerRepository>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDark ? AppTheme.primaryLight.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  widget.prayer.authorName[0],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.prayer.authorName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      _formatTime(widget.prayer.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.prayer.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.prayer.category!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Prayer Text
          Text(
            '"${widget.prayer.text}"',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Amen Button
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (!_hasAmened) {
                    await prayerRepo.amenPrayer(widget.prayer.id);
                    setState(() => _hasAmened = true);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _hasAmened
                        ? Colors.red.withOpacity(0.1)
                        : (isDark ? Colors.white10 : Colors.black12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _hasAmened
                          ? Colors.red.withOpacity(0.5)
                          : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _hasAmened ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: _hasAmened ? Colors.red : (isDark ? Colors.white60 : Colors.black45),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Amen ${widget.prayer.amenCount + (_hasAmened ? 1 : 0)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _hasAmened ? Colors.red : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (widget.prayer.isOwn)
                Text(
                  'Your prayer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}