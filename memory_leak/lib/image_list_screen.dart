import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:leak_tracker/leak_tracker.dart';

class ImageListScreen extends StatefulWidget {
  const ImageListScreen({super.key});

  @override
  State<ImageListScreen> createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<int> _items = [];
  bool _isLoading = false;
  static const int _initialLoadCount = 50;
  static const int _loadMoreCount = 50;

  // Toggle to enable/disable memory leaks
  bool _leakEnabled = false;
  bool _showLeakyWidget = false;

  @override
  void initState() {
    super.initState();
    // Track object creation
    LeakTracking.dispatchObjectCreated(
      library: 'memory_leak',
      className: '_ImageListScreenState',
      object: this,
    );
    // Track ScrollController
    LeakTracking.dispatchObjectCreated(
      library: 'memory_leak',
      className: 'ScrollController',
      object: _scrollController,
    );

    _loadItems(_initialLoadCount);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Track object disposal
    LeakTracking.dispatchObjectDisposed(object: this);
    LeakTracking.dispatchObjectDisposed(object: _scrollController);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadItems(int count) {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          final startIndex = _items.length;
          for (int i = 0; i < count; i++) {
            _items.add(startIndex + i);
          }
          _isLoading = false;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading) {
        _loadItems(_loadMoreCount);
      }
    }
  }

  void _toggleLeakEnabled(bool value) {
    setState(() {
      _leakEnabled = value;
      if (!value) {
        // Remove leaky widget if leaks are disabled
        _showLeakyWidget = false;
      }
    });
  }

  void _toggleLeakyWidget() {
    if (!_leakEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable memory leaks first using the toggle'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _showLeakyWidget = !_showLeakyWidget;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _showLeakyWidget
              ? 'Created leaky widget - remove it to trigger leak detection'
              : 'Removed leaky widget - check console for leaks',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Image List'),
        actions: [
          // Toggle to enable/disable memory leaks
          Row(
            children: [
              const Text('Leaks:', style: TextStyle(fontSize: 12)),
              Switch(value: _leakEnabled, onChanged: _toggleLeakEnabled),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_showLeakyWidget ? Icons.delete : Icons.add),
            tooltip: _showLeakyWidget
                ? 'Remove Leaky Widget'
                : 'Create Leaky Widget',
            onPressed: _toggleLeakyWidget,
            color: _leakEnabled ? null : Colors.grey,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showLeakyWidget) const LeakyWidget(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _items.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final itemIndex = _items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://picsum.photos/seed/$itemIndex/400/300',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Item $itemIndex',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LeakyWidget extends StatefulWidget {
  const LeakyWidget({super.key});

  @override
  State<LeakyWidget> createState() => _LeakyWidgetState();
}

class _LeakyWidgetState extends State<LeakyWidget> {
  StreamController<String>? _leakedStreamController;

  @override
  void initState() {
    super.initState();
    LeakTracking.dispatchObjectCreated(
      library: 'memory_leak',
      className: '_LeakyWidgetState',
      object: this,
    );

    _leakedStreamController = StreamController<String>.broadcast();
    LeakTracking.dispatchObjectCreated(
      library: 'memory_leak',
      className: 'StreamController',
      object: _leakedStreamController!,
    );
  }

  @override
  void dispose() {
    LeakTracking.dispatchObjectDisposed(object: this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red.withValues(alpha: 0.2),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This widget has a memory leak (StreamController not closed). Remove it to trigger leak detection.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
