import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final supabase = Supabase.instance.client;

  TextEditingController nameC = TextEditingController();
  TextEditingController usernameC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  String? avatarUrl;
  File? pickedImage;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // 🔹 Load Data Profile dari Supabase
  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    nameC.text = data['full_name'] ?? "";
    usernameC.text = data['username'] ?? "";
    phoneC.text = data['phone'] ?? "";
    emailC.text = user.email ?? "";
    avatarUrl = data['avatar_url'];

    setState(() => loading = false);
  }

  // 🔹 Upload Foto Profil
  Future<String?> uploadAvatar() async {
    if (pickedImage == null) return avatarUrl;

    final user = supabase.auth.currentUser;
    final fileName = "avatar_${user!.id}.jpg";

    await supabase.storage
        .from('avatars')
        .upload(fileName, pickedImage!, fileOptions: const FileOptions(upsert: true));

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

    return publicUrl;
  }

  // 🔹 Simpan ke Supabase
  Future<void> saveProfile() async {
    setState(() => loading = true);

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final uploadedUrl = await uploadAvatar();

    await supabase.from('profiles').update({
      'full_name': nameC.text,
      'username': usernameC.text,
      'phone': phoneC.text,
      'avatar_url': uploadedUrl,
    }).eq('id', user.id);

    setState(() => loading = false);

    Navigator.pop(context);
  }

  // 🔹 Pilih gambar
  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff6B7A87),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.black, size: 30),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // FOTO PROFIL
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: pickedImage != null
                          ? FileImage(pickedImage!)
                          : avatarUrl != null
                              ? NetworkImage(avatarUrl!)
                              : const AssetImage(
                                      "assets/images/profile.png.jpeg")
                                  as ImageProvider,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    nameC.text,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 35),

                  buildField("Name", nameC),
                  const SizedBox(height: 20),

                  buildField("Username", usernameC),
                  const SizedBox(height: 20),

                  buildField("Phone Number", phoneC),
                  const SizedBox(height: 20),

                  buildField("Email", emailC, readOnly: true),
                  const SizedBox(height: 35),

                  // SAVE BUTTON
                  GestureDetector(
                    onTap: saveProfile,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFD6D2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          "Save",
                          style:
                              TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // 🔹 CUSTOM FIELD
  Widget buildField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 8),
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFE1E1E1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
