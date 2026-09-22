import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KabadiwalaConnectApp());
}

// ============================================================
// APP
// ============================================================

class KabadiwalaConnectApp extends StatelessWidget {
  const KabadiwalaConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kabadiwala Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// CONSTANTS
// ============================================================

const Color primaryGreen = Color(0xFF16A34A);
const Color darkGreen = Color(0xFF166534);
const Color lightGreen = Color(0xFFDCFCE7);
const Color blueColor = Color(0xFF2563EB);
const Color yellowColor = Color(0xFFF59E0B);
const Color textColor = Color(0xFF1E293B);
const Color grayColor = Color(0xFF64748B);

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startSplash();
  }

  Future<void> startSplash() async {
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.recycling,
                color: primaryGreen,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'KABADIWALA CONNECT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connecting collectors to formal recycling',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 35),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  bool loading = false;

  Future<void> sendOTP() async {
    String phone = phoneController.text.trim();

    if (phone.length != 10) {
      showMessage('Please enter a valid 10-digit mobile number.');
      return;
    }

    setState(() {
      loading = true;
    });

    final fullPhone = '+91$phone';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
          } catch (e) {
            debugPrint('Automatic verification error: $e');
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            loading = false;
          });

          showMessage(
            e.message ?? 'OTP could not be sent.',
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() {
            loading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPScreen(
                verificationId: verificationId,
                phoneNumber: fullPhone,
              ),
            ),
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(
            'OTP auto retrieval timeout: $verificationId',
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage('Something went wrong. Please try again.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 55),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.recycling,
                  color: primaryGreen,
                  size: 52,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Welcome to',
                style: TextStyle(
                  color: grayColor,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Kabadiwala Connect',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Fair prices • Verified recyclers • Digital records',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: grayColor,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 55),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mobile Number',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: '',
                  prefixText: '+91  ',
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  hintText: 'Enter 10-digit mobile number',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'By continuing, you agree to use the platform for\n'
                'responsible and formal recycling transactions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: grayColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// OTP SCREEN
// ============================================================

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();

  bool loading = false;

  Future<void> verifyOTP() async {
    String otp = otpController.text.trim();

    if (otp.length != 6) {
      showMessage('Please enter the 6-digit OTP.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        e.message ?? 'Invalid OTP.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage('OTP verification failed.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 35),

            const Icon(
              Icons.sms_outlined,
              color: primaryGreen,
              size: 65,
            ),

            const SizedBox(height: 25),

            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'OTP sent to ${widget.phoneNumber}',
              style: const TextStyle(
                color: grayColor,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
String selectedLanguage = 'English';
  final List<Widget> screens = const [
    HomeDashboard(),
    TransactionHistory(),
  ];

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME DASHBOARD
// ============================================================

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.recycling,
                    color: primaryGreen,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello! 👋',
                        style: TextStyle(
                          color: grayColor,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Kabadiwala Connect',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
  children: [
    IconButton(
      tooltip: 'Language',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          builder: (sheetContext) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Choose Language',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ListTile(
                      leading: const Text(
                        '🇬🇧',
                        style: TextStyle(fontSize: 25),
                      ),
                      title: const Text('English'),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: primaryGreen,
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                      },
                    ),

                    ListTile(
                      leading: const Text(
                        '🇮🇳',
                        style: TextStyle(fontSize: 25),
                      ),
                      title: const Text('हिंदी'),
                      onTap: () {
                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Hindi language selected',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      icon: const Icon(
        Icons.language,
        color: grayColor,
      ),
    ),
    IconButton(
  onPressed: () async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  },
  icon: const Icon(
    Icons.logout,
    color: grayColor,
       ),
    ),
  ],
 ),
              ],
            ), 

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sell scrap through\nformal recycling',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Check fair prices, find verified recyclers\nand keep digital transaction records.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Quick Actions',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    icon: Icons.add_box_outlined,
                    title: 'Add Scrap',
                    subtitle: 'Create a new lot',
                    iconColor: primaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddScrapScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ActionCard(
                    icon: Icons.price_check,
                    title: 'Fair Price',
                    subtitle: 'Check material rates',
                    iconColor: yellowColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddScrapScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    icon: Icons.recycling,
                    title: 'Recyclers',
                    subtitle: 'Find verified recyclers',
                    iconColor: blueColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecyclerMatchingScreen(
                            material: 'PCB',
                            weight: 10,
                            estimatedValue: 250,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ActionCard(
                    icon: Icons.history,
                    title: 'History',
                    subtitle: 'View transactions',
                    iconColor: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionHistory(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Why Kabadiwala Connect?',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            FeatureTile(
              icon: Icons.currency_rupee,
              title: 'Fair Price Information',
              description:
                  'See estimated value before selling your material.',
            ),

            FeatureTile(
              icon: Icons.verified_outlined,
              title: 'Verified Recycler Connection',
              description:
                  'Find recyclers according to material and distance.',
            ),

            FeatureTile(
              icon: Icons.receipt_long_outlined,
              title: 'Digital Transaction Record',
              description:
                  'Each completed transaction gets a unique Lot ID.',
            ),

            FeatureTile(
              icon: Icons.wifi_off_outlined,
              title: 'Simple & Offline-Friendly',
              description:
                  'Designed for entry-level Android users and low connectivity.',
            ),

            if (user != null) ...[
              const SizedBox(height: 15),
              Text(
                'Logged in successfully',
                style: TextStyle(
                  color: primaryGreen.withValues(alpha: 0.8),
                  fontSize: 12,
        ),
       ),
      ],
     ],
    ),
   ),
  );
 }
}

// ============================================================
// ACTION CARD
// ============================================================

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: grayColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FEATURE TILE
// ============================================================

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: primaryGreen,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: grayColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADD SCRAP SCREEN
// ============================================================

class AddScrapScreen extends StatefulWidget {
  const AddScrapScreen({super.key});

  @override
  State<AddScrapScreen> createState() => _AddScrapScreenState();
}

class _AddScrapScreenState extends State<AddScrapScreen> {
  final TextEditingController weightController =
      TextEditingController();

  String selectedMaterial = 'PCB';

  // Photo variable
  XFile? selectedPhoto;

  final Map<String, int> rates = {
    'PCB': 25,
    'Copper': 550,
    'Aluminium': 180,
    'Iron': 35,
    'Plastic': 30,
    'Paper': 15,
    'E-Waste': 45,
  };

  // ==========================================================
  // TAKE PHOTO
  // ==========================================================

  Future<void> pickPhoto() async {
    final ImagePicker picker = ImagePicker();

    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (photo != null) {
      setState(() {
        selectedPhoto = photo;
      });
    }
  }

  // ==========================================================
  // CONTINUE TO PRICE
  // ==========================================================

  void continueToPrice() {
    final weight = double.tryParse(
      weightController.text.trim(),
    );

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight.'),
        ),
      );
      return;
    }

    final rate = rates[selectedMaterial] ?? 0;

    final value = weight * rate;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PriceEstimateScreen(
          material: selectedMaterial,
          weight: weight,
          rate: rate,
          estimatedValue: value,
        ),
      ),
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Scrap'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'What material do you have?',
              style: TextStyle(
                color: textColor,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Select material and enter approximate weight.',
              style: TextStyle(
                color: grayColor,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // MATERIAL
            // ==================================================

            const Text(
              'Material',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: selectedMaterial,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              items: rates.keys.map((material) {
                return DropdownMenuItem(
                  value: material,
                  child: Text(material),
                );
              }).toList(),

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedMaterial = value;
                });
              },
            ),

            const SizedBox(height: 25),

            // ==================================================
            // WEIGHT
            // ==================================================

            const Text(
              'Approximate Weight',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: weightController,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: InputDecoration(
                hintText: 'Example: 50',
                suffixText: 'kg',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // PHOTO SECTION
            // ==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),

                borderRadius: BorderRadius.circular(18),

                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),

              child: Column(
                children: [

                  // PHOTO PREVIEW
                  if (selectedPhoto != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),

                      child: Image.file(
                        File(selectedPhoto!.path),

                        height: 180,

                        width: double.infinity,

                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const Icon(
                      Icons.photo_camera_outlined,
                      size: 55,
                      color: primaryGreen,
                    ),

                  const SizedBox(height: 12),

                  // PHOTO TEXT
                  Text(
                    selectedPhoto == null
                        ? 'Add photo of scrap'
                        : 'Scrap photo added',

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CAMERA BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: pickPhoto,

                      icon: const Icon(
                        Icons.camera_alt,
                      ),

                      label: Text(
                        selectedPhoto == null
                            ? 'Take Photo'
                            : 'Retake Photo',
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,

                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // CURRENT RATE
            // ==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: lightGreen,

                borderRadius: BorderRadius.circular(18),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.info_outline,
                    color: darkGreen,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Current sample rate: ₹${rates[selectedMaterial]}/kg',

                      style: const TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // CHECK VALUE BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed: continueToPrice,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                child: const Text(
                  'Check Estimated Value',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRICE ESTIMATE SCREEN
// ============================================================

class PriceEstimateScreen extends StatelessWidget {
  final String material;
  final double weight;
  final int rate;
  final double estimatedValue;

  // Photo received from Add Scrap screen
  final XFile? selectedPhoto;

  const PriceEstimateScreen({
    super.key,
    required this.material,
    required this.weight,
    required this.rate,
    required this.estimatedValue,
    this.selectedPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Estimate'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            // ==================================================
            // PRICE
            // ==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                children: [

                  const Icon(
                    Icons.currency_rupee,
                    color: primaryGreen,
                    size: 55,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Estimated Value',
                    style: TextStyle(
                      color: grayColor,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '₹${estimatedValue.toStringAsFixed(0)}',

                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PHOTO CONFIRMATION
            // ==================================================

            if (selectedPhoto != null)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(16),

                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),

                child: Row(
                  children: [

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),

                      child: Image.file(
                        File(selectedPhoto!.path),

                        width: 70,
                        height: 70,

                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'Scrap photo added successfully',
                        style: TextStyle(
                          color: darkGreen,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.check_circle,
                      color: primaryGreen,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ==================================================
            // DETAILS
            // ==================================================

            InfoRow(
              label: 'Material',
              value: material,
            ),

            InfoRow(
              label: 'Weight',
              value:
                  '${weight.toStringAsFixed(1)} kg',
            ),

            InfoRow(
              label: 'Rate',
              value: '₹$rate/kg',
            ),

            const Spacer(),

            // ==================================================
            // FIND RECYCLER
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          RecyclerMatchingScreen(
                        material: material,
                        weight: weight,
                        estimatedValue:
                            estimatedValue,

                        // Pass photo forward
                        selectedPhoto:
                            selectedPhoto,
                      ),
                    ),
                  );
                },

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryGreen,

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                child: const Text(
                  'Find Recycler',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: grayColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RECYCLER MATCHING SCREEN
// ============================================================

class RecyclerMatchingScreen extends StatelessWidget {
  final String material;
  final double weight;
  final double estimatedValue;
  final XFile? selectedPhoto;

  const RecyclerMatchingScreen({
    super.key,
    required this.material,
    required this.weight,
    required this.estimatedValue,
    this.selectedPhoto,
  });
  final List<Map<String, dynamic>> recyclers = const [
    {
      'name': 'GreenTech Recycling Center',
      'distance': '3.2 km',
      'rate': 27,
      'available': true,
    },
    {
      'name': 'EcoCycle Recycling',
      'distance': '5.8 km',
      'rate': 26,
      'available': true,
    },
    {
      'name': 'Clean Earth Recycling',
      'distance': '7.1 km',
      'rate': 25,
      'available': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verified Recyclers'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.recycling,
                  color: darkGreen,
                  size: 35,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$material • ${weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Matching recyclers',
            style: TextStyle(
              color: textColor,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...recyclers.map(
            (recycler) {
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: lightGreen,
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            recycler['name'],
                            style: const TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.verified,
                          color: blueColor,
                          size: 22,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: grayColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          recycler['distance'],
                          style: const TextStyle(
                            color: grayColor,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.currency_rupee,
                          size: 18,
                          color: grayColor,
                        ),
                        Text(
                          '${recycler['rate']}/kg',
                          style: const TextStyle(
                            color: grayColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed:
                            recycler['available'] == true
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            LotHandoverScreen(
                                          material: material,
                                          weight: weight,
                                          rate: recycler[
                                              'rate'],
                                          recyclerName:
                                              recycler[
                                                  'name'],
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          recycler['available'] == true
                              ? 'Select Recycler'
                              : 'Currently Unavailable',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOT + HANDOVER SCREEN
// ============================================================

class LotHandoverScreen extends StatefulWidget {
  final String material;
  final double weight;
  final int rate;
  final String recyclerName;

  const LotHandoverScreen({
    super.key,
    required this.material,
    required this.weight,
    required this.rate,
    required this.recyclerName,
  });

  @override
  State<LotHandoverScreen> createState() =>
      _LotHandoverScreenState();
}

class _LotHandoverScreenState
    extends State<LotHandoverScreen> {
  bool saving = false;

  // ==========================================================
  // CREATE DIGITAL LOT ID
  // ==========================================================

  String createLotId() {
    final now = DateTime.now();

    return 'KC-${now.year}-'
        '${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  // ==========================================================
  // COMPLETE HANDOVER
  // ==========================================================

  Future<void> completeHandover() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login again.'),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    final lotId = createLotId();

    final estimatedValue =
        widget.weight * widget.rate;

    // Current date and time
    final handoverDateTime = DateTime.now();

    try {
      // ======================================================
      // SAVE TRANSACTION TO FIRESTORE
      // ======================================================

      await FirebaseFirestore.instance
          .collection('transactions')
          .add({
        'userId': user.uid,

        'lotId': lotId,

        'material': widget.material,

        'weight': widget.weight,

        'rate': widget.rate,

        'estimatedValue': estimatedValue,

        'recyclerName': widget.recyclerName,

        'status': 'Completed',

        // Server timestamp
        'createdAt': FieldValue.serverTimestamp(),

        // Handover date and time
        'handoverDateTime':
            Timestamp.fromDate(handoverDateTime),
      });

      if (!mounted) return;

      // ======================================================
      // OPEN DIGITAL RECEIPT
      // ======================================================

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (_) => DigitalReceiptScreen(
            lotId: lotId,
            material: widget.material,
            weight: widget.weight,
            rate: widget.rate,
            estimatedValue: estimatedValue,
            recyclerName: widget.recyclerName,
          ),
        ),

        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaction could not be saved: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final estimatedValue =
        widget.weight * widget.rate;

    final now = DateTime.now();

    final dateText =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';

    final timeText =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Handover'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'Confirm Handover',
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Review the transaction before creating the digital record.',
              style: TextStyle(
                color: grayColor,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // DIGITAL LOT ID
            // ==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(17),

              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius:
                    BorderRadius.circular(17),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.qr_code_2,
                    color: darkGreen,
                    size: 30,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Digital Lot ID',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Created after confirmation',
                          style: const TextStyle(
                            color: darkGreen,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // TRANSACTION DETAILS
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(18),

                    border: Border.all(
                      color:
                          const Color(0xFFE2E8F0),
                    ),
                  ),

                  child: Column(
                    children: [

                      InfoRow(
                        label: 'Material',
                        value: widget.material,
                      ),

                      InfoRow(
                        label: 'Weight',
                        value:
                            '${widget.weight.toStringAsFixed(1)} kg',
                      ),

                      InfoRow(
                        label: 'Rate',
                        value:
                            '₹${widget.rate}/kg',
                      ),

                      InfoRow(
                        label: 'Recycler',
                        value:
                            widget.recyclerName,
                      ),

                      InfoRow(
                        label: 'Estimated Value',
                        value:
                            '₹${estimatedValue.toStringAsFixed(0)}',
                      ),

                      InfoRow(
                        label: 'Date',
                        value: dateText,
                      ),

                      InfoRow(
                        label: 'Time',
                        value: timeText,
                      ),

                      const SizedBox(height: 15),

                      // STATUS
                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: lightGreen,

                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: const Row(
                          children: [

                            Icon(
                              Icons.verified,
                              color: darkGreen,
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                'Status: Ready for digital handover',
                                style: TextStyle(
                                  color: darkGreen,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // CONFIRM BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed:
                    saving
                        ? null
                        : completeHandover,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryGreen,

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                child: saving
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Confirm & Create Digital Record',
                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// DIGITAL RECEIPT
// ============================================================

class DigitalReceiptScreen extends StatelessWidget {
  final String lotId;
  final String material;
  final double weight;
  final int rate;
  final double estimatedValue;
  final String recyclerName;

  const DigitalReceiptScreen({
    super.key,
    required this.lotId,
    required this.material,
    required this.weight,
    required this.rate,
    required this.estimatedValue,
    required this.recyclerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Receipt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.check_circle,
                color: primaryGreen,
                size: 55,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Transaction Completed',
              style: TextStyle(
                color: darkGreen,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Digital handover record created successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: grayColor,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'DIGITAL LOT ID',
                    style: TextStyle(
                      color: grayColor,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    lotId,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Divider(height: 30),

                  InfoRow(
                    label: 'Material',
                    value: material,
                  ),

                  InfoRow(
                    label: 'Weight',
                    value:
                        '${weight.toStringAsFixed(1)} kg',
                  ),

                  InfoRow(
                    label: 'Rate',
                    value: '₹$rate/kg',
                  ),

                  InfoRow(
                    label: 'Estimated Value',
                    value:
                        '₹${estimatedValue.toStringAsFixed(0)}',
                  ),

                  InfoRow(
                    label: 'Recycler',
                    value: recyclerName,
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          color: darkGreen,
                          size: 18,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Transaction Recorded',
                          style: TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TRANSACTION HISTORY
// ============================================================

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          'Please login again.',
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              10,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Transaction History',
                style: TextStyle(
                  color: textColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .snapshots(),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryGreen,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),
                      child: Text(
                        'Could not load history.\n\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: grayColor,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 65,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: grayColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final allDocs =
                    snapshot.data!.docs.toList();

                final userDocs = allDocs.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  return data['userId'] == user.uid;
                }).toList();

                userDocs.sort((a, b) {
                  final dataA =
                      a.data() as Map<String, dynamic>;
                  final dataB =
                      b.data() as Map<String, dynamic>;

                  final timeA =
                      dataA['createdAt']
                          as Timestamp?;

                  final timeB =
                      dataB['createdAt']
                          as Timestamp?;

                  if (timeA == null && timeB == null) {
                    return 0;
                  }

                  if (timeA == null) {
                    return 1;
                  }

                  if (timeB == null) {
                    return -1;
                  }

                  return timeB.compareTo(timeA);
                });

                if (userDocs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 65,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: grayColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: userDocs.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final data =
                        userDocs[index].data()
                            as Map<String, dynamic>;

                    final material =
                        data['material'] ?? 'Unknown';

                    final weight =
                        data['weight'] ?? 0;

                    final value =
                        data['estimatedValue'] ?? 0;

                    final recycler =
                        data['recyclerName'] ??
                            'Recycler';

                    final lotId =
                        data['lotId'] ??
                            'No Lot ID';

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 15,
                      ),
                      padding:
                          const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration:
                                    BoxDecoration(
                                  color: lightGreen,
                                  borderRadius:
                                      BorderRadius
                                          .circular(14),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color:
                                      primaryGreen,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      material.toString(),
                                      style:
                                          const TextStyle(
                                        color:
                                            textColor,
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      lotId.toString(),
                                      style:
                                          const TextStyle(
                                        color:
                                            grayColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                '₹${value is num ? value.toStringAsFixed(0) : value}',
                                style:
                                    const TextStyle(
                                  color:
                                      primaryGreen,
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          const Divider(),

                          const SizedBox(height: 10),

                          Text(
                            'Weight: $weight kg',
                            style:
                                const TextStyle(
                              color: grayColor,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Recycler: $recycler',
                            style:
                                const TextStyle(
                              color: grayColor,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration:
                                BoxDecoration(
                              color: lightGreen,
                              borderRadius:
                                  BorderRadius.circular(
                                      8),
                            ),
                            child: const Text(
                              'Completed',
                              style: TextStyle(
                                color: darkGreen,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}