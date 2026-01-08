import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  String fullName = "";
  String username = "";
  String? avatarUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return;
      }

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        fullName = data['full_name'] ?? "No Name";
        username = data['username'] ?? "no_username";
        avatarUrl = data['avatar_url'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load profile: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();

    // Kembali ke login screen
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5E2E0),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 25),

                    // FOTO PROFIL
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl!)
                          : const AssetImage("assets/images/profile.png.jpeg")
                              as ImageProvider,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      fullName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "@$username",
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 15),
                    ),

                    const SizedBox(height: 30),

                    // MENU LIST
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ProfileMenu(
                            icon: Icons.edit,
                            text: "Edit Profile",
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen()),
                              );
                              // Reload profile setelah kembali dari edit
                              _loadProfile();
                            },
                          ),
                          const ProfileMenu(
                              icon: Icons.credit_card, text: "Payment Methods"),
                          const ProfileMenu(
                              icon: Icons.history, text: "Trip History"),
                          const ProfileMenu(
                              icon: Icons.settings, text: "Settings"),
                          const ProfileMenu(
                              icon: Icons.help_outline, text: "Help & Support"),

                          // LOGOUT
                          ProfileMenu(
                            icon: Icons.logout,
                            text: "Logout",
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const ProfileMenu({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon, color: Colors.black87, size: 25),
        title: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$text clicked')),
              );
            },
      ),
    );
  }
}
