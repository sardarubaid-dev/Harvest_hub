import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadReviewImage({
    required String productId,
    required String userId,
    required File imageFile,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = imageFile.path.split('.').last;
    final path = 'reviews/$productId/$userId/${timestamp}.$extension';

    final ref = _storage.ref().child(path);
    
    // Attempt upload
    final uploadTask = await ref.putFile(imageFile);
    
    // Get URL
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }
}
