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
  bool _showDefinition = false;
  bool _shuffled = false;

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
      _showDefinition = false;
    });
  }

  void _next() {
    setState(() {
      _position = (_position + 1) % _order.length;
      _showDefinition = false;
    });
  }

  void _previous() {
    setState(() {
      _position = (_position - 1 + _order.length) % _order.length;
      _showDefinition = false;
    });
  }

  void _handleVerticalSwipe(DragEndDetails details) {
    const threshold = 200.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() >= threshold) {
      setState(() => _showDefinition = !_showDefinition);
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
                    onTap: () =>
                        setState(() => _showDefinition = !_showDefinition),
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 240),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _showDefinition ? word.definition : word.hanzi,
                          textAlign: TextAlign.center,
                          style: _showDefinition
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
