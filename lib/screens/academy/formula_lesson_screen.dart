/// STEM Lesson View Screen — Standalone offline STEM lesson.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/formula_model.dart';
import '../../providers/academy_user_provider.dart';
import '../../repositories/formula_repository.dart';
import '../../widgets/formula_calculator_widget.dart';
import '../../widgets/formula_renderer.dart';
import '../../widgets/stitch_card.dart';

class FormulaLessonScreen extends StatefulWidget {
  final FormulaModel formula;

  const FormulaLessonScreen({
    super.key,
    required this.formula,
  });

  @override
  State<FormulaLessonScreen> createState() => _FormulaLessonScreenState();
}

class _FormulaLessonScreenState extends State<FormulaLessonScreen> {
  bool _studyMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademyUserProvider>().recordViewed(widget.formula.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userProv = context.watch<AcademyUserProvider>();
    final isBookmarked = userProv.isBookmarked(widget.formula.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.formula.name),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_studyMode ? Icons.auto_stories_rounded : Icons.auto_stories_outlined),
            tooltip: _studyMode ? 'Exit Study Mode' : 'Study Mode (Revision)',
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _studyMode = !_studyMode);
            },
          ),
          IconButton(
            icon: Icon(isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded),
            color: isBookmarked ? const Color(0xFFF59E0B) : null,
            tooltip: isBookmarked ? 'Remove Bookmark' : 'Bookmark Lesson',
            onPressed: () {
              HapticFeedback.lightImpact();
              userProv.toggleBookmark(widget.formula.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. BREADCRUMB NAVIGATION ──────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Mathematics',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.chevron_right_rounded, size: 14),
                    ),
                    Text(
                      widget.formula.categoryId.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.chevron_right_rounded, size: 14),
                    ),
                    Text(
                      widget.formula.topic,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── 2. LESSON TITLE & BADGES ───────────────────────────────────
              Text(
                widget.formula.name,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.formula.difficulty.label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⏱️ ${widget.formula.estimatedReadMinutes} min read',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  if (_studyMode) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '📖 Study Mode',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA855F7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // ── 3. FORMULA DISPLAY CARD ────────────────────────────────────
              StitchCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.functions_rounded, size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Formula Expression',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FormulaRenderer(
                      formula: widget.formula.formula,
                      showCardBackground: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── 3.5 INTERACTIVE CALCULATOR (If Available) ──────────────────
              if (widget.formula.calculator != null) ...[
                FormulaCalculatorWidget(
                  calculator: widget.formula.calculator!,
                  workedExample: widget.formula.workedExample,
                ),
                const SizedBox(height: 24),
              ],

              // ── 4. CONCEPT DESCRIPTION (Hidden in strict Study Mode if desired) ──
              if (!_studyMode) ...[
                Text(
                  'Overview & Concept',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.formula.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── 5. VARIABLES LIST SECTION ──────────────────────────────────
              if (widget.formula.variables.isNotEmpty) ...[
                Text(
                  'Variables & Symbols',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                StitchCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final v in widget.formula.variables)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  v.symbol,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      v.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── 6. WORKED EXAMPLE SECTION ──────────────────────────────────
              if (widget.formula.workedExample != null) ...[
                Text(
                  'Worked Example',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                StitchCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('📝', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.formula.workedExample!.problem,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Step-by-step Solution:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (int i = 0; i < widget.formula.workedExample!.steps.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${i + 1}. ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.formula.workedExample!.steps[i],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Final Solution: ${widget.formula.workedExample!.solution}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── 7. ACTIONS & RELATED CONTENT (Hidden in Study Mode) ───────
              if (!_studyMode) ...[
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Interactive calculator coming in future updates!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calculate_outlined),
                        label: const Text('Calculator'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(
                            ClipboardData(
                              text: '${widget.formula.name}\nFormula: ${widget.formula.formula}\n${widget.formula.description}',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lesson formula copied to clipboard!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Related Content Section
                if (widget.formula.relatedContent.isNotEmpty) ...[
                  Text(
                    'Related STEM Content',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final rel in widget.formula.relatedContent)
                    FutureBuilder<FormulaModel?>(
                      future: FormulaRepository.instance.getFormulaById(
                        int.tryParse(rel.targetId) ?? -1,
                      ),
                      builder: (context, snapshot) {
                        final relFormula = snapshot.data;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: StitchCard(
                            padding: const EdgeInsets.all(12),
                            child: ListTile(
                              dense: true,
                              title: Text(
                                rel.title,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(
                                '${rel.relationshipType.toUpperCase()} • ${rel.targetType}',
                                style: TextStyle(fontSize: 11, color: colorScheme.primary),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                              onTap: () {
                                if (relFormula != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FormulaLessonScreen(formula: relFormula),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
