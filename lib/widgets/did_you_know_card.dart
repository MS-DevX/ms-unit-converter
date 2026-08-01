/// Educational "Did You Know?" rotating card widget.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/did_you_know.dart';
import '../repositories/educational_facts_repository.dart';

/// Displays a randomly rotating [DidYouKnowFact] with a fade animation.
///
/// The fact changes every 180 seconds (3 minutes) automatically. The user can tap
/// the forward arrow to skip to the next fact. All facts are loaded from SQLite
/// database via [EducationalFactsRepository].
class DidYouKnowCard extends StatefulWidget {
  const DidYouKnowCard({super.key});

  @override
  State<DidYouKnowCard> createState() => _DidYouKnowCardState();
}

class _DidYouKnowCardState extends State<DidYouKnowCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  Timer? _timer;
  List<DidYouKnowFact> _facts = const [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _loadFacts();
  }

  Future<void> _loadFacts() async {
    final facts = await EducationalFactsRepository.instance.loadAll();
    if (!mounted) return;
    setState(() {
      _facts = facts;
      if (_facts.isNotEmpty) {
        _currentIndex = Random().nextInt(_facts.length);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 180), (_) => _nextFact());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _nextFact() {
    if (_facts.isEmpty) return;
    _fadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _facts.length;
      });
      _fadeCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_facts.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final fact = _facts[_currentIndex];

    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji
            Text(
              fact.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            // Fact text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'DID YOU KNOW?',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.secondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      // Tap to next
                      GestureDetector(
                        onTap: _nextFact,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fact.fact,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
