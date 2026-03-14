import 'dart:convert';
import 'package:flutter/services.dart';

class AssetManager {
  static const String logo = 'assets/images/logo.png'; // Make sure to add this later

  // Hardcoded categories mapping exactly to folder names
  static const List<String> categories = [
    'Tractor', 'Harvester', 'Plough', 'Seeder', 'Water Pump', 'Sprayer', 'Loader'
  ];

  static final Map<String, List<String>> _categoryImages = {};

  // Dynamically load all available image paths from the manifest
  static Future<void> loadAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // Decode URL-encoded paths (spaces become %20 in manifest)
      final imagePaths = manifestMap.keys
          .map((key) => Uri.decodeFull(key))
          .where((String key) => key.contains('assets/images/') && (key.toLowerCase().endsWith('.png') || key.toLowerCase().endsWith('.jpg') || key.toLowerCase().endsWith('.jpeg')))
          .toList();

      for (String category in categories) {
        _categoryImages[category] = imagePaths
            .where((path) => path.contains('assets/images/$category/'))
            .toList();
      }
    } catch (e) {
      print('Error loading assets manifest: $e');
    }
  }

  // Get all dynamically loaded images for a chosen category
  static List<String> getImagesForCategory(String category) {
    final allImages = _categoryImages[category] ?? [];
    // Prioritize real images over placeholders
    final realImages = allImages.where((img) => !img.contains('placeholder_')).toList();
    
    // If we only have placeholders, don't show them in the gallery (it looks blank)
    // unless you want to return them. For now, we return real images if present, 
    // or an empty list so the UI says "No images found".
    return realImages.isNotEmpty ? realImages : [];
  }

  // Get a single preferred image (for thumbnails)
  static String getEquipmentImage(String category) {
    final images = getImagesForCategory(category);
    if (images.isNotEmpty) {
      return images.first; 
    }
    return logo; // fallback to logo if no image found literally
  }
}

