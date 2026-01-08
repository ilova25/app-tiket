import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._(); // private constructor
  static final SupabaseService instance = SupabaseService._();

  final supabase = Supabase.instance.client;

  // =====================================================
  // REGISTER USER
  // =====================================================
  Future<String?> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          "username": username,
          "full_name": fullName,
        },
      );

      if (res.user == null) {
        return "Pendaftaran gagal.";
      }

      return null; // sukses
    } catch (e) {
      return e.toString();
    }
  }

  // =====================================================
  // LOGIN
  // =====================================================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        return "Login gagal.";
      }

      return null; // sukses
    } catch (e) {
      return e.toString();
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // =====================================================
  // GET USER PROFILE
  // =====================================================
  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final data = await supabase
        .from("profiles")
        .select()
        .eq("id", user.id)
        .single();

    return data;
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================
  Future<String?> updateProfile({
    required String fullName,
    required String username,
    required String phone,
  }) async {
    try {
      final uid = supabase.auth.currentUser!.id;

      await supabase.from("profiles").update({
        "full_name": fullName,
        "username": username,
        "phone": phone,
        "updated_at": DateTime.now().toIso8601String(),
      }).eq("id", uid);

      return null; // sukses
    } catch (e) {
      return e.toString();
    }
  }

  // =====================================================
  // UPLOAD AVATAR (FILE)
  // =====================================================
  Future<String?> uploadAvatar(File file) async {
    try {
      final uid = supabase.auth.currentUser!.id;

      final fileName = "$uid-${DateTime.now().millisecondsSinceEpoch}.jpg";

      // upload file ke bucket
      await supabase.storage.from("avatars").upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // generate public URL
      final publicUrl =
          supabase.storage.from("avatars").getPublicUrl(fileName);

      // simpan ke database
      await supabase.from("profiles").update({
        "avatar_url": publicUrl,
      }).eq("id", uid);

      return publicUrl;
    } catch (e) {
      return null;
    }
  }
}
