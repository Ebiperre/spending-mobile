import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class TheGistScreen extends StatefulWidget {
  const TheGistScreen({super.key});

  @override
  State<TheGistScreen> createState() => _TheGistScreenState();
}

class _TheGistScreenState extends State<TheGistScreen> {
  // Mock data - replace with actual backend data
  final List<Map<String, dynamic>> _confessions = [
    {
      'id': '1',
      'text': 'I spend ₦15k on shawarma last week. My salary na ₦80k. God abeg! 😭',
      'reactions': 234,
      'comments': 45,
      'timeAgo': '2h ago',
      'category': '🍔 CHOP',
    },
    {
      'id': '2',
      'text': 'My babe birthday, I don blow ₦25k for gift. Now na garri I dey chop for house 😂',
      'reactions': 567,
      'comments': 89,
      'timeAgo': '5h ago',
      'category': '❤️ RELATIONSHIP',
    },
    {
      'id': '3',
      'text': 'Uber don collect all my transport money this month. I fit just dey walk? 🚶',
      'reactions': 189,
      'comments': 34,
      'timeAgo': '8h ago',
      'category': '🚗 MOVE',
    },
    {
      'id': '4',
      'text': 'I buy new phone on credit. Now BOILING don red like traffic light! 🔴',
      'reactions': 421,
      'comments': 67,
      'timeAgo': '12h ago',
      'category': '💰 FLEX',
    },
    {
      'id': '5',
      'text': 'Data finish again! MTN dey collect my money every week like clockwork ⏰',
      'reactions': 312,
      'comments': 52,
      'timeAgo': '1d ago',
      'category': '🏠 MUST PAY',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.white
                : AppColors.darkSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'The Gist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.white
                : AppColors.darkSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.white
                : AppColors.darkSurface,
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header banner
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🤫', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spill the tea!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Anonymous confessions from salary earners',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Confessions list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _confessions.length,
                itemBuilder: (context, index) {
                  final confession = _confessions[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    duration: const Duration(milliseconds: 400),
                    child: _buildConfessionCard(confession),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddConfessionDialog(),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Share Your Gist',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildConfessionCard(Map<String, dynamic> confession) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkElevated
              : AppColors.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              confession['category'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Confession text
          Text(
            confession['text'],
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.grey200
                  : AppColors.darkSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Footer with reactions and time
          Row(
            children: [
              // Reactions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkElevated
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '${confession['reactions']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.white
                            : AppColors.darkSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Comments
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkElevated
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.white
                          : AppColors.darkSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${confession['comments']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.white
                            : AppColors.darkSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Time ago
              Text(
                confession['timeAgo'],
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddConfessionDialog() {
    final confessionController = TextEditingController();
    String? selectedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Spill Your Gist',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.darkSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your identity dey safe. Wetin happen? 🤫',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: confessionController,
                maxLines: 5,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.darkSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'E.g., "I spend ₦20k on takeout this week..."',
                  hintStyle: TextStyle(
                    color: AppColors.grey400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkElevated
                      : AppColors.lightBackground,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Which category? (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.white
                        : AppColors.darkSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCategoryChip('🍔 CHOP', selectedCategory, (value) {
                    setModalState(() => selectedCategory = value);
                  }),
                  _buildCategoryChip('🚗 MOVE', selectedCategory, (value) {
                    setModalState(() => selectedCategory = value);
                  }),
                  _buildCategoryChip('💰 FLEX', selectedCategory, (value) {
                    setModalState(() => selectedCategory = value);
                  }),
                  _buildCategoryChip('❤️ RELATIONSHIP', selectedCategory, (value) {
                    setModalState(() => selectedCategory = value);
                  }),
                  _buildCategoryChip('🏠 MUST PAY', selectedCategory, (value) {
                    setModalState(() => selectedCategory = value);
                  }),
                  _buildCategoryChip('📱 OTHER', selectedCategory, (value) {
                    setModalState(() => selectedCategory = value);
                  }),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (confessionController.text.isNotEmpty) {
                      Navigator.pop(context);
                      _showSuccessSnackbar();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Post Anonymously',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, String? selectedCategory, Function(String?) onTap) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => onTap(isSelected ? null : category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkElevated
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : Theme.of(context).brightness == Brightness.dark
                ? AppColors.white
                : AppColors.darkSurface,
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your gist don post! Nobody go know say na you 😉',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🤫', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'About The Gist',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.darkSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This is a safe space where salary earners share their spending confessions anonymously.\n\nYour identity is completely protected. No one will know who posted what.\n\nLaugh, cry, and relate with others who are fighting the same battle to reach month-end!',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.grey700,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
