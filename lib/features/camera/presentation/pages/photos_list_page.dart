import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path; // Add this import
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart'; // Add this import
import '../../domain/entities/photo_info.dart';
import 'photo_detail_page.dart';

class PhotosListPage extends StatefulWidget {
  const PhotosListPage({super.key});

  @override
  State<PhotosListPage> createState() => _PhotosListPageState();
}

class _PhotosListPageState extends State<PhotosListPage> {
  List<PhotoInfo> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${directory.path}/photos');
      final metadataDir = Directory('${directory.path}/metadata');

      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
        return;
      }

      final List<PhotoInfo> loadedPhotos = [];

      // List all jpg files in photos directory
      final List<FileSystemEntity> photoFiles = await photoDir
          .list()
          .where((entity) => entity.path.endsWith('.jpg'))
          .toList();

      for (var photoFile in photoFiles) {
        final filename = path.basename(photoFile.path);
        final id = filename.split('_').first;

        try {
          // Try to read metadata
          final metadataFile = File('${metadataDir.path}/${id}_metadata.txt');
          if (await metadataFile.exists()) {
            final metadataString = await metadataFile.readAsString();
            final metadata = jsonDecode(metadataString) as Map<String, dynamic>;

            loadedPhotos.add(PhotoInfo(
              id: metadata['id'] as String,
              imagePath: photoFile.path,
              timestamp: DateTime.parse(metadata['timestamp'] as String),
              latitude: double.parse(metadata['latitude'] as String),
              longitude: double.parse(metadata['longitude'] as String),
              address: metadata['address'] as String,
            ));
          } else {
            // If no metadata, create basic PhotoInfo
            final timestamp =
                DateTime.fromMillisecondsSinceEpoch(int.parse(id));
            loadedPhotos.add(PhotoInfo(
              id: id,
              imagePath: photoFile.path,
              timestamp: timestamp,
              latitude: 0,
              longitude: 0,
              address: 'Metadata tidak tersedia',
            ));
          }
        } catch (e) {
          debugPrint('Error loading metadata for $id: $e');
          // Still add photo even if metadata fails
          loadedPhotos.add(PhotoInfo(
            id: id,
            imagePath: photoFile.path,
            timestamp: DateTime.now(),
            latitude: 0,
            longitude: 0,
            address: 'Error membaca metadata',
          ));
        }
      }

      // Sort photos by timestamp (newest first)
      loadedPhotos.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _photos = loadedPhotos;
      });

      debugPrint('Loaded ${loadedPhotos.length} photos');
    } catch (e) {
      debugPrint('Error loading photos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memuat foto: ${e.toString()}')),
        );
      }
    }
  }

  void _showPhoto(BuildContext context, PhotoInfo photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Container(
            color: Colors.black,
            child: Hero(
              tag: photo.id,
              child: PhotoView(
                imageProvider: FileImage(File(photo.imagePath)),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foto (${_photos.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPhotos,
          ),
        ],
      ),
      body: _photos.isEmpty
          ? const Center(child: Text('Belum ada foto'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return InkWell(
                  onTap: () => _showPhoto(context, photo),
                  child: Hero(
                    tag: photo.id,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(photo.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, size: 40),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                DateFormat('dd/MM/yyyy HH:mm')
                                    .format(photo.timestamp),
                                style: const TextStyle(color: Colors.white),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
