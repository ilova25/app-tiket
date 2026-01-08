import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // biar background bawah menyatu, tidak putih
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 85,
        margin: EdgeInsets.zero, // hapus ruang putih di sisi
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(
          color: Color(0xFFA5C3BF), // hijau full
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 32),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 32),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final supabase = Supabase.instance.client;
  
  String fullName = "Guest";
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
      if (user == null) return;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        fullName = data['full_name'] ?? "Guest";
        avatarUrl = data['avatar_url'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load profile: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5E2E0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, $fullName",
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Where will you go",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ],
                    ),
                    ClipOval(
                      child: avatarUrl != null
                          ? Image.network(
                              avatarUrl!,
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "assets/images/profile.png.jpeg",
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Search box
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Balance card
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text("Balance",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 18)),
                        SizedBox(height: 5),
                        Text("\$18",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24)),
                      ]),
                      Column(children: [
                        Text("Rewards",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 18)),
                        SizedBox(height: 5),
                        Text("\$10.25",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24)),
                      ]),
                      Column(children: [
                        Text("Total Trips",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 18)),
                        SizedBox(height: 5),
                        Text("189",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24)),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text("Choose your Transport",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                // Bus Card
                TransportCard(
                  image: "assets/images/bus.png.png",
                  title: "Bus",
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bus selected")),
                  ),
                ),

                // MRT Card
                TransportCard(
                  image: "assets/images/train.png.png",
                  title: "MRT",
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("MRT selected")),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Transport Card
class TransportCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;

  const TransportCard({
    Key? key,
    required this.image,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB7CFCB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              image,
              height: 180, // diperbesar
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text("Select",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
