import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import '../pages/photos_list_page.dart';
import '../../domain/entities/photo_info.dart';
import '../../utils/image_stamper.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraReady = false;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isProcessing = false;
  late AnimationController _flashAnimationController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('CameraPage: initState');
    _initializeCamera().then((_) => _checkPermissions());

    _flashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Adjusted duration
      vsync: this,
    );

    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flashAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
  }

  Future<void> _checkPermissions() async {
    try {
      // Cek kedua izin
      await handleLocationPermission();
      // await handleCameraPermission();

      log('Permission granted');
    } catch (e) {
      log('Permission tolak');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      log('Initializing camera...');
      final cameras = await availableCameras();
      log('Available cameras: ${cameras.length}');

      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      log('Initializing camera controller...');
      await _controller!.initialize();
      log('Camera controller initialized');

      if (mounted) {
        setState(() {
          _isCameraReady = true;
          log('Camera is ready: $_isCameraReady');
        });
      }
    } catch (e) {
      log('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: ${e.toString()}')),
        );
      }
    }
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    log(serviceEnabled.toString());
    if (!serviceEnabled) {
      throw Exception(
          'Layanan lokasi dinonaktifkan. Mohon aktifkan layanan lokasi di pengaturan.');
    }

    // Cek status izin lokasi saat ini
    permission = await Geolocator.checkPermission();
    log(permission.toString());
    if (permission == LocationPermission.denied) {
      // Minta izin jika belum diberikan
      log('mulai minta izin');
      permission = await Geolocator.requestPermission();
      log(permission.toString());
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }
    log('masuk sini');
    // Cek jika izin ditolak secara permanen
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Izin lokasi ditolak secara permanen. Mohon aktifkan di pengaturan aplikasi.');
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Memeriksa dan meminta izin kamera
  Future<bool> handleCameraPermission() async {
    // Cek status izin kamera
    PermissionStatus status = await Permission.camera.status;

    if (status.isDenied) {
      // Minta izin jika belum diberikan
      status = await Permission.camera.request();
      if (status.isDenied) {
        throw Exception('Izin kamera ditolak');
      }
    }

    // Cek jika izin ditolak secara permanen
    if (status.isPermanentlyDenied) {
      throw Exception(
          'Izin kamera ditolak secara permanen. Mohon aktifkan di pengaturan aplikasi.');
    }

    return status.isGranted;
  }

  Future<void> _takePicture() async {
    debugPrint('=== Starting _takePicture ===');
    debugPrint('Camera ready: $_isCameraReady');
    debugPrint('Controller initialized: ${_controller?.value.isInitialized}');
    debugPrint('Is processing: $_isProcessing');

    if (!_isCameraReady || _controller == null || _isProcessing) {
      debugPrint('Cannot take picture: conditions not met');
      return;
    }

    try {
      debugPrint('Setting processing state to true');
      setState(() => _isProcessing = true);

      debugPrint('Playing flash animation');
      _flashAnimationController.forward().then((_) {
        _flashAnimationController.reverse();
      });

      debugPrint('Attempting to take picture...');
      final XFile image = await _controller!.takePicture();
      debugPrint('Picture taken successfully: ${image.path}');

      // Prepare directories
      final directory = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${directory.path}/photos');
      await photoDir.create(recursive: true);
      debugPrint('Photo directory created: ${photoDir.path}');

      // Save image dengan timestamp
      final timestamp = DateTime.now();
      final fileName = '${timestamp.millisecondsSinceEpoch}_photo.jpg';
      final savedImage = File(path.join(photoDir.path, fileName));

      // Copy foto ke direktori aplikasi
      await File(image.path).copy(savedImage.path);
      debugPrint('Photo saved to: ${savedImage.path}');

      // Update location in parallel
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint(
          'Location received: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');

      if (_currentPosition != null) {
        try {
          final placemarks = await placemarkFromCoordinates(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            localeIdentifier: 'id_ID',
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            _currentAddress = [
              if (place.street?.isNotEmpty ?? false) place.street,
              if (place.subLocality?.isNotEmpty ?? false) place.subLocality,
              if (place.locality?.isNotEmpty ?? false) place.locality,
            ].where((e) => e != null).join(', ');
          }
        } catch (e) {
          debugPrint('Error getting address: $e');
          _currentAddress = 'Lokasi ditemukan, alamat tidak tersedia';
        }
      }

      final photoInfo = PhotoInfo(
        id: timestamp.millisecondsSinceEpoch.toString(),
        imagePath: savedImage.path,
        timestamp: timestamp,
        latitude: _currentPosition?.latitude ?? 0,
        longitude: _currentPosition?.longitude ?? 0,
        address: _currentAddress ?? 'Lokasi tidak tersedia',
      );

      // Process image with stamp
      debugPrint('Processing image with stamp...');
      await ImageStamper.stampImage(
        sourceImagePath: savedImage.path,
        photoInfo: photoInfo,
      );
      debugPrint('Image stamped');

      // Save metadata
      await _savePhotoMetadata(photoInfo);
      debugPrint('Metadata saved');

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveFile(savedImage.path);
      debugPrint('Saved to gallery: ${result['isSuccess']}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil disimpan'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('ERROR in _takePicture: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          debugPrint('Processing completed, state reset');
        });
      }
    }
  }

  Future<void> _savePhotoMetadata(PhotoInfo photo) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataDir = Directory('${directory.path}/metadata');
      await metadataDir.create(recursive: true);

      final metadataFile = File(
        path.join(metadataDir.path, '${photo.id}_metadata.txt'),
      );

      final metadata = {
        'id': photo.id,
        'timestamp': photo.timestamp.toIso8601String(),
        'latitude': photo.latitude.toString(),
        'longitude': photo.longitude.toString(),
        'address': photo.address,
        'imagePath': photo.imagePath,
      };

      await metadataFile.writeAsString(jsonEncode(metadata));
    } catch (e) {
      debugPrint('Error saving metadata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady || _controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final scale = 1 / (_controller!.value.aspectRatio * size.aspectRatio);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview
            Transform.scale(
              scale: scale,
              child: Center(
                child: CameraPreview(_controller!),
              ),
            ),

            // Controls Layer
            Column(
              children: [
                // Header
                Material(
                  color: Colors.black45,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm:ss')
                              .format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 2.0, color: Colors.black),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: const Icon(Icons.photo_library),
                            color: Colors.white,
                            iconSize: 28,
                            splashRadius: 24,
                            onPressed: () {
                              debugPrint('Opening gallery...');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PhotosListPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Camera Button
                Material(
                  color: Colors.black45,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _takePicture,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(24),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(80, 80),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: const Icon(Icons.camera_alt, size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Loading Overlay
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Memproses foto...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

            // Flash Effect
            Visibility(
              visible: _flashAnimationController.isAnimating,
              child: FadeTransition(
                opacity: _flashAnimation,
                child: Container(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _flashAnimationController.dispose();
    super.dispose();
  }
}
