import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  PdfViewerController? _pdfViewerController; // Make nullable
  PdfTextSearchResult? _searchResult; // Make nullable
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarVisible = false;
  bool _isSearching = false;
  bool _isInitialized = false; // Add initialization flag

  @override
  void initState() {
    super.initState();
    _initializePdfViewer();
  }

  Future<void> _initializePdfViewer() async {
    _pdfViewerController = PdfViewerController();
    _searchResult = PdfTextSearchResult();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }

    _searchResult?.addListener(() {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (!_isInitialized) return;

    try {
      if (!mounted) return;

      if (query.isEmpty || query.length < 3) {
        setState(() {
          _searchResult?.clear();
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _isSearching = true;
        _searchResult?.clear();
      });

      // Perform search without auto-navigating
      _searchResult = _pdfViewerController?.searchText(query);

      // Add listener only once
      _searchResult?.addListener(() {
        if (!mounted) return;

        setState(() {
          _isSearching = false;
          // Don't auto-navigate here, just update the UI
        });
      });
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResult?.clear();
        });
      }
    }
  }

  void _navigateToNextResult() {
    if (_searchResult?.hasResult ?? false) {
      _searchResult?.nextInstance();
    }
  }

  void _toggleSearch() {
    if (!mounted) return;

    setState(() {
      _isSearchBarVisible = !_isSearchBarVisible;
      if (!_isSearchBarVisible) {
        _searchController.clear();
        _searchResult?.removeListener(() {}); // Remove existing listener
        _searchResult?.clear();
        setState(() {}); // Refresh UI to hide navigation
      }
    });
  }

  Widget _buildSearchFABs() {
    if (!(_searchResult?.hasResult ?? false)) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      bottom: 32, // Adjusted position since we removed bottom navigation
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_searchResult?.currentInstanceIndex ?? 0}/${_searchResult?.totalInstanceCount ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'previousSearch',
              mini: true,
              backgroundColor: Colors.amber,
              onPressed: () {
                _searchResult?.previousInstance();
                setState(() {});
              },
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'nextSearch',
              mini: true,
              backgroundColor: Colors.amber,
              onPressed: () {
                _searchResult?.nextInstance();
                setState(() {});
              },
              child: const Icon(Icons.arrow_downward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearchBarVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari dalam PDF...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (mounted) {
                    _performSearch(value);
                  }
                },
              )
            : const Text('kesehatan'),
        actions: [
          if (_isSearching)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          if (_searchResult?.hasResult ?? false) ...[
            // Center(
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 8),
            //     child: Text(
            //       '${_searchResult?.currentInstanceIndex ?? 0}/${_searchResult?.totalInstanceCount ?? 0}',
            //       style: const TextStyle(color: Colors.black),
            //     ),
            //   ),
            // ),
            // IconButton(
            //   icon: const Icon(Icons.arrow_upward),
            //   onPressed: () {
            //     _searchResult?.previousInstance();
            //     setState(() {}); // Update the instance counter
            //   },
            // ),
            // IconButton(
            //   icon: const Icon(Icons.arrow_downward),
            //   onPressed: () {
            //     _searchResult?.nextInstance();
            //     setState(() {}); // Update the instance counter
            //   },
            // ),
          ],
          IconButton(
            icon: Icon(_isSearchBarVisible ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.asset(
            'assets/pdfs/kesehatan.pdf',
            controller: _pdfViewerController,
            currentSearchTextHighlightColor: Colors.yellow.withOpacity(0.7),
            otherSearchTextHighlightColor: Colors.yellow.withOpacity(0.3),
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              debugPrint('PDF loaded successfully');
              // Cek apakah PDF searchable
              _checkPdfSearchable();
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              debugPrint('PDF load failed: ${details.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gagal memuat PDF'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          _buildSearchFABs(),
          if (_isSearching)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _checkPdfSearchable() async {
    try {
      // Test search dengan kata sederhana
      final testResult = await _pdfViewerController?.searchText('the');
      debugPrint('PDF searchable test: ${testResult?.hasResult ?? false}');
      debugPrint(
          'Total instances found: ${testResult?.totalInstanceCount ?? 0}');
    } catch (e) {
      debugPrint('PDF search test failed: $e');
    }
  }

  @override
  void dispose() {
    _searchResult?.removeListener(() {});
    _searchController.dispose();
    _pdfViewerController?.dispose();
    super.dispose();
  }
}
