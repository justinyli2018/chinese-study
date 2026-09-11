import 'dart:math';

import 'package:flutter/material.dart';

import '../models/word_set.dart';

class FlashcardScreen extends StatefulWidget {
  final WordSet wordSet;

  const FlashcardScreen({super.key, required this.wordSet});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late List<int> _order;
  int _position = 0;
  bool _flipped = false;
  bool _shuffled = false;
  bool _definitionFirst = false;

  /// Whether the card's face currently shows the definition, accounting for
  /// both the per-card flip state and the "show definition first" setting.
  bool get _isShowingDefinition => _definitionFirst ? !_flipped : _flipped;

  @override
  void initState() {
    super.initState();
    _order = List.generate(widget.wordSet.words.length, (i) => i);
  }

  void _toggleShuffle() {
    setState(() {
      _shuffled = !_shuffled;
      if (_shuffled) {
        _order.shuffle(Random());
      } else {
        _order = List.generate(widget.wordSet.words.length, (i) => i);
      }
      _position = 0;
      _flipped = false;
    });
  }

  void _toggleDefinitionFirst() {
    setState(() {
      _definitionFirst = !_definitionFirst;
      _flipped = false;
    });
  }

  void _next() {
    setState(() {
      _position = (_position + 1) % _order.length;
      _flipped = false;
    });
  }

  void _previous() {
    setState(() {
      _position = (_position - 1 + _order.length) % _order.length;
      _flipped = false;
    });
  }

  void _handleVerticalSwipe(DragEndDetails details) {
    const threshold = 200.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() >= threshold) {
      setState(() => _flipped = !_flipped);
    }
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    const threshold = 200.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity <= -threshold) {
      _next();
    } else if (velocity >= threshold) {
      _previous();
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.wordSet.words;
    if (words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.wordSet.displayName)),
        body: const Center(child: Text('This set has no words.')),
      );
    }

    final word = words[_order[_position]];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wordSet.displayName),
        actions: [
          IconButton(
            tooltip: _shuffled ? 'Shuffled (tap to sort)' : 'Shuffle',
            icon: Icon(_shuffled ? Icons.shuffle_on_outlined : Icons.shuffle),
            onPressed: _toggleShuffle,
          ),
          IconButton(
            tooltip: _definitionFirst
                ? 'Showing definition first (tap to show word first)'
                : 'Showing word first (tap to show definition first)',
            icon: Icon(_definitionFirst ? Icons.translate : Icons.text_fields),
            onPressed: _toggleDefinitionFirst,
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragEnd: _handleVerticalSwipe,
          onHorizontalDragEnd: _handleHorizontalSwipe,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '${_position + 1} / ${words.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _flipped = !_flipped),
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 240),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _isShowingDefinition ? word.definition : word.hanzi,
                          textAlign: TextAlign.center,
                          style: _isShowingDefinition
                              ? Theme.of(context).textTheme.headlineSmall
                              : Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(fontSize: 64),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Tap or swipe up/down to flip • swipe left/right to move',
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _previous,
                    ),
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
