import 'package:image_picker/image_picker.dart';

/// Abstraction over "pick a photo, then persist it somewhere".
///
/// [LocalPhotoService] keeps everything on-device for now. Swap it for a
/// Cloudinary/Supabase-backed implementation later — call sites only ever
/// see local paths going in and a saved reference coming out of [save], so
/// nothing else has to change when [save] starts doing a real upload.
abstract class PhotoService {
  /// Opens the system photo library and returns the picked image's local
  /// file path, or null if the user cancelled.
  Future<String?> pickFromLibrary();

  /// Persists [localPath] and returns a reference to it (a remote URL once
  /// Cloudinary/Supabase are wired up). For now this just returns the local
  /// path unchanged.
  Future<String> save(String localPath);
}

class LocalPhotoService implements PhotoService {
  const LocalPhotoService();

  @override
  Future<String?> pickFromLibrary() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return picked?.path;
  }

  @override
  Future<String> save(String localPath) async => localPath;
}
