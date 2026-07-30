/// STEM Academy — Universal Offline STEM Knowledge Platform Main Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/formula_model.dart';
import '../../models/subject_model.dart';
import '../../providers/academy_user_provider.dart';
import '../../repositories/formula_repository.dart';
import '../../repositories/subject_repository.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/stitch_card.dart';
import 'academy_topic_screen.dart';
import 'formula_lesson_screen.dart';

class StemAcademyScreen extends StatefulWidget {
  const StemAcademyScreen({super.key});

  @override
  State<StemAcademyScreen> createState() => _StemAcademyScreenState();
}

class _StemAcademyScreenState extends State<StemAcademyScreen> {
  List<SubjectModel> _subjects = [];
  List<FormulaCategoryModel> _mathCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final subjects = await SubjectRepository.instance.loadSubjects();
    final categories = await FormulaRepository.instance.loadCategories(subjectId: 1);
    if (mounted) {
      setState(() {
        _subjects = subjects;
        _mathCategories = categories;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userProv = context.watch<AcademyUserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('STEM Academy'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── 1. HEADER HERO ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '100% Offline Platform',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '📚 STEM Academy',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Explore comprehensive lessons, formulas, and concepts.',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 2. PROMINENT USER LEARNING HERO CARDS (BOOKMARKS & RECENT) ─
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _openBookmarksList(context, userProv),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                      const Color(0xFFD97706).withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('⭐', style: TextStyle(fontSize: 20)),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${userProv.bookmarkedIds.length}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFD97706),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Bookmarks',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Saved Lessons',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _openRecentlyViewedList(context, userProv),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF4F8CFF).withValues(alpha: 0.15),
                                      const Color(0xFF2563EB).withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF4F8CFF).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('🕒', style: TextStyle(fontSize: 20)),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4F8CFF).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${userProv.recentlyViewedIds.length}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF4F8CFF),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Recently Viewed',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Recent History',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 3. MATHEMATICS CATEGORIES SECTION ───────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Text(
                        '📐 Mathematics Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final cat = _mathCategories[index];
                          return StitchCard(
                            padding: EdgeInsets.zero,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AcademyTopicScreen(category: cat),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                                        const Spacer(),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 14,
                                          color: colorScheme.outline,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          cat.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          cat.description,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _mathCategories.length,
                      ),
                    ),
                  ),

                  // ── 4. COMING SOON STEM SUBJECTS SECTION ──────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                      child: Text(
                        'Upcoming STEM Subjects',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final subject = _subjects.where((s) => !s.isAvailable).toList()[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: StitchCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Text(subject.icon, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Comprehensive offline lessons coming soon',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Coming Soon',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: _subjects.where((s) => !s.isAvailable).length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 36)),
                ],
              ),
      ),
    );
  }

  void _openBookmarksList(BuildContext context, AcademyUserProvider userProv) async {
    final List<FormulaModel> bookmarkedFormulas = [];
    for (final id in userProv.bookmarkedIds) {
      final f = await FormulaRepository.instance.getFormulaById(id);
      if (f != null) bookmarkedFormulas.add(f);
    }

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Bookmarked Lessons')),
          body: bookmarkedFormulas.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.star_border_rounded,
                  message: 'No Bookmarked Lessons',
                  subtitle: 'Tap the star icon on any lesson page to save it for quick reference.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: bookmarkedFormulas.length,
                  itemBuilder: (context, index) {
                    final item = bookmarkedFormulas[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: StitchCard(
                        padding: const EdgeInsets.all(16),
                        child: ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${item.topic} • ${item.difficulty.label}'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FormulaLessonScreen(formula: item)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _openRecentlyViewedList(BuildContext context, AcademyUserProvider userProv) async {
    final List<FormulaModel> recentFormulas = [];
    for (final id in userProv.recentlyViewedIds) {
      final f = await FormulaRepository.instance.getFormulaById(id);
      if (f != null) recentFormulas.add(f);
    }

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Recently Viewed Lessons')),
          body: recentFormulas.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.history_rounded,
                  message: 'No Recently Viewed Lessons',
                  subtitle: 'Lessons you view in STEM Academy will automatically appear here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: recentFormulas.length,
                  itemBuilder: (context, index) {
                    final item = recentFormulas[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: StitchCard(
                        padding: const EdgeInsets.all(16),
                        child: ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${item.topic} • ${item.difficulty.label}'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FormulaLessonScreen(formula: item)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
