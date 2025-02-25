import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  InAppWebViewController? _webViewController;
  String currentUrl = "";
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  bool _hasSearchResults = false;

  @override
  void initState() {
    super.initState();
  }

  void _performSearch(String searchText) async {
    if (_webViewController == null || searchText.isEmpty) {
      setState(() => _hasSearchResults = false);
      return;
    }

    final result = await _webViewController?.evaluateJavascript(
      source: "window.find('$searchText')",
    );

    if (mounted) {
      setState(() => _hasSearchResults = result == true);
    }
  }

  void _findNext() {
    _webViewController?.evaluateJavascript(
        source: "window.find('${_searchController.text}', false, false)");
  }

  void _findPrevious() {
    _webViewController?.evaluateJavascript(
        source: "window.find('${_searchController.text}', false, true)");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari dalam dokumen...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black87),
                ),
                style: const TextStyle(color: Colors.black87),
                autofocus: true,
                onChanged: _performSearch,
              )
            : const Text('Harga Susenas'),
        actions: [
          if (_isSearchVisible && _hasSearchResults) ...[
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: _findPrevious,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: _findNext,
            ),
          ],
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  _hasSearchResults = false;
                  _webViewController?.evaluateJavascript(
                      source: "window.getSelection().removeAllRanges()");
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(
                  'https://docs.google.com/document/d/1NvEkqOjkVLhdtfWngFW6bw7aWUVssph4/preview?rm=minimal'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                currentUrl = url.toString();
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              if (mounted) {
                setState(() {
                  currentUrl = url.toString();
                  _isLoading = false;
                });
              }
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
