import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'dart:typed_data';
import 'upload_recyclers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_storage.dart';
// ============================================================
// AUTO SYNC PENDING TRANSACTIONS
// ============================================================

Future<void> syncPendingTransactions() async {
  try {
    final pendingTransactions =
        await OfflineStorage.getPendingTransactions();

    if (pendingTransactions.isEmpty) {
      return;
    }

    for (final transaction
        in pendingTransactions) {
      try {
        final transactionId =
            transaction['transactionId']
                ?.toString();

        if (transactionId == null ||
            transactionId.isEmpty) {
          continue;
        }

        // ================================================
        // UPLOAD TO FIRESTORE
        // ================================================

        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionId)
            .set({
          'transactionId':
              transaction['transactionId'],

          'lotId':
              transaction['lotId'],

          'material':
              transaction['material'],

          'weight':
              transaction['weight'],

          'rate':
              transaction['rate'],

          'estimatedValue':
              transaction['estimatedValue'],

          'recyclerId':
              transaction['recyclerId'],

          'recyclerName':
              transaction['recyclerName'],

          'recyclerCity':
              transaction['recyclerCity'],

          'status':
              transaction['status'],

          'handoverDateTime':
              Timestamp.fromDate(
            DateTime.parse(
              transaction[
                  'handoverDateTime'],
            ),
          ),

          'createdAt':
              FieldValue.serverTimestamp(),
        });

        // ================================================
        // REMOVE FROM LOCAL PENDING LIST
        // ================================================

        await OfflineStorage
            .removePendingTransaction(
          transactionId,
        );
      } catch (_) {
        // If one transaction fails,
        // keep it locally for the next sync.
        continue;
      }
    }
  } catch (_) {
    // No action needed.
    // Pending data remains safely stored.
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
// await FirebaseAppCheck.instance.activate(
  //  providerAndroid: const AndroidDebugProvider(),
//  );
  // ========================================================
  // SYNC PENDING OFFLINE TRANSACTIONS
  // ========================================================

  await syncPendingTransactions();

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
// LANGUAGE SYSTEM
// ============================================================

class AppLanguage {
  static bool isHindi = false;

  static String get(String english, String hindi) {
    return isHindi ? hindi : english;
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
      builder: (_) => const HomeScreen(),
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
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeDashboard(
        onLanguageChanged: () {
          setState(() {});
        },
      ),
      const TransactionHistory(),
    ];

    return Scaffold(
      body: screens[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLanguage.get(
              'Home',
              'होम',
            ),
          ),

          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: AppLanguage.get(
              'History',
              'इतिहास',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME DASHBOARD
// ============================================================

class HomeDashboard extends StatefulWidget {
  final VoidCallback? onLanguageChanged;

  const HomeDashboard({
    super.key,
    this.onLanguageChanged,
  });

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  bool isOnline = true;

  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();

    checkConnectivity();

    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;

      setState(() {
        isOnline = results.any(
          (result) => result != ConnectivityResult.none,
        );
      });
    });
  }
Future<void> checkConnectivity() async {
  final results = await Connectivity().checkConnectivity();

  if (!mounted) return;

  final online = results.any(
    (result) => result != ConnectivityResult.none,
  );

  setState(() {
    isOnline = online;
  });

  // ========================================================
  // INTERNET AVAILABLE -> SYNC PENDING TRANSACTIONS
  // ========================================================

  if (online) {
    await syncPendingTransactions();
  }
}

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // HEADER
            // ============================================================

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

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguage.get(
                          'Hello! 👋',
                          'नमस्ते! 👋',
                        ),
                        style: const TextStyle(
                          color: grayColor,
                          fontSize: 14,
                        ),
                      ),

                      const Text(
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

                IconButton(
                  tooltip: AppLanguage.get(
                    'Language',
                    'भाषा',
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape:
                          const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (sheetContext) {
                        return SafeArea(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Text(
                                  AppLanguage.get(
                                    'Choose Language',
                                    'भाषा चुनें',
                                  ),
                                  style:
                                      const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                ListTile(
                                  leading: const Text(
                                    '🇬🇧',
                                    style:
                                        TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  title:
                                      const Text(
                                    'English',
                                  ),
                                  trailing:
                                      !AppLanguage
                                              .isHindi
                                          ? const Icon(
                                              Icons
                                                  .check_circle,
                                              color:
                                                  primaryGreen,
                                            )
                                          : null,
                                  onTap: () {
                                    AppLanguage
                                            .isHindi =
                                        false;

                                    Navigator.pop(
                                      sheetContext,
                                    );

                                    setState(() {});

                                    widget
                                        .onLanguageChanged
                                        ?.call();
                                  },
                                ),

                                ListTile(
                                  leading: const Text(
                                    '🇮🇳',
                                    style:
                                        TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  title:
                                      const Text(
                                    'हिंदी',
                                  ),
                                  trailing:
                                      AppLanguage
                                              .isHindi
                                          ? const Icon(
                                              Icons
                                                  .check_circle,
                                              color:
                                                  primaryGreen,
                                            )
                                          : null,
                                  onTap: () {
                                    AppLanguage
                                            .isHindi =
                                        true;

                                    Navigator.pop(
                                      sheetContext,
                                    );

                                    setState(() {});

                                    widget
                                        .onLanguageChanged
                                        ?.call();
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
              ],
            ),

            const SizedBox(height: 12),

            // ============================================================
            // ONLINE / OFFLINE STATUS
            // ============================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isOnline
                    ? lightGreen
                    : const Color(0xFFFFF7ED),
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: isOnline
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFFED7AA),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnline
                        ? Icons.wifi
                        : Icons.wifi_off,
                    size: 18,
                    color: isOnline
                        ? darkGreen
                        : const Color(0xFFC2410C),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOnline
                          ? AppLanguage.get(
                              'Online',
                              'ऑनलाइन',
                            )
                          : AppLanguage.get(
                              'Offline — Data will be saved locally',
                              'ऑफलाइन — डेटा स्थानीय रूप से सेव होगा',
                            ),
                      style: TextStyle(
                        color: isOnline
                            ? darkGreen
                            : const Color(
                                0xFFC2410C,
                              ),
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ============================================================
            // BANNER
            // ============================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLanguage.get(
                      'Sell scrap through\nformal recycling',
                      'स्क्रैप बेचें\nऔपचारिक रीसाइक्लिंग के माध्यम से',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    AppLanguage.get(
                      'Check fair prices, find verified recyclers\nand keep digital transaction records.',
                      'उचित कीमत देखें, सत्यापित रीसाइक्लर खोजें\nऔर डिजिटल लेनदेन रिकॉर्ड रखें।',
                    ),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ============================================================
            // QUICK ACTIONS
            // ============================================================

            Text(
              AppLanguage.get(
                'Quick Actions',
                'त्वरित कार्य',
              ),
              style: const TextStyle(
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
                    icon:
                        Icons.add_box_outlined,
                    title: AppLanguage.get(
                      'Add Scrap',
                      'स्क्रैप जोड़ें',
                    ),
                    subtitle:
                        AppLanguage.get(
                      'Create a new lot',
                      'नया लॉट बनाएं',
                    ),
                    iconColor: primaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddScrapScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ActionCard(
                    icon: Icons.price_check,
                    title: AppLanguage.get(
                      'Fair Price',
                      'उचित कीमत',
                    ),
                    subtitle:
                        AppLanguage.get(
                      'Check material rates',
                      'मटेरियल की दर देखें',
                    ),
                    iconColor: yellowColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddScrapScreen(),
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
                    title: AppLanguage.get(
                      'Recyclers',
                      'रीसाइक्लर',
                    ),
                    subtitle:
                        AppLanguage.get(
                      'Find verified recyclers',
                      'सत्यापित रीसाइक्लर खोजें',
                    ),
                    iconColor: blueColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RecyclerMatchingScreen(
                            city: 'Jaipur',
                            material: 'PCB',
                            weight: 10,
                            rate: 25,
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
                    title: AppLanguage.get(
                      'History',
                      'इतिहास',
                    ),
                    subtitle:
                        AppLanguage.get(
                      'View transactions',
                      'लेनदेन देखें',
                    ),
                    iconColor:
                        Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const TransactionHistory(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ============================================================
            // WHY KABADIWALA CONNECT
            // ============================================================

            Text(
              AppLanguage.get(
                'Why Kabadiwala Connect?',
                'Kabadiwala Connect क्यों?',
              ),
              style: const TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            FeatureTile(
              icon: Icons.currency_rupee,
              title: AppLanguage.get(
                'Fair Price Information',
                'उचित कीमत की जानकारी',
              ),
              description:
                  AppLanguage.get(
                'See estimated value before selling your material.',
                'अपना मटेरियल बेचने से पहले अनुमानित कीमत देखें।',
              ),
            ),

            FeatureTile(
              icon:
                  Icons.verified_outlined,
              title: AppLanguage.get(
                'Verified Recycler Connection',
                'सत्यापित रीसाइक्लर से कनेक्शन',
              ),
              description:
                  AppLanguage.get(
                'Find recyclers according to material and distance.',
                'मटेरियल और दूरी के अनुसार रीसाइक्लर खोजें।',
              ),
            ),

            FeatureTile(
              icon:
                  Icons.receipt_long_outlined,
              title: AppLanguage.get(
                'Digital Transaction Record',
                'डिजिटल लेनदेन रिकॉर्ड',
              ),
              description:
                  AppLanguage.get(
                'Each completed transaction gets a unique Lot ID.',
                'हर पूर्ण लेनदेन को एक यूनिक लॉट ID मिलती है।',
              ),
            ),

            FeatureTile(
              icon:
                  Icons.wifi_off_outlined,
              title: AppLanguage.get(
                'Simple & Offline-Friendly',
                'सरल और ऑफलाइन उपयोग के अनुकूल',
              ),
              description:
                  AppLanguage.get(
                'Designed for entry-level Android users and low connectivity.',
                'कम कनेक्टिविटी और शुरुआती Android यूज़र्स के लिए बनाया गया है।',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
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
  String? aiAnalysisResult;
  bool isAnalyzing = false;

  double? currentRate;
  String currentRateUnit = 'kg';
  String? rateSource;
  String? rateDate;
  bool isLoadingRate = false;
  String? rateError;

  String selectedCity = 'Jaipur';

  final List<String> cities = [
    'Ahmedabad',
    'Bengaluru Urban',
    'Bhopal',
    'Chandigarh',
    'Chennai',
    'Cochin',
    'Coimbatore',
    'Gurugram',
    'Hyderabad',
    'Indore',
    'Jaipur',
    'Jammu',
    'Jamnagar',
    'Kanpur',
    'Kolkata',
    'Lucknow',
    'Ludhiana',
    'Mandi Gobindgarh',
    'Mumbai',
    'Nagpur',
    'New Delhi',
    'Pune',
    'Surat',
    'Vadodara',
  ];

  final List<String> materials = [
    'Copper',
    'Aluminium',
    'Iron',
    'Brass',
    'Wire',
    'E-waste',
    'Li-ion Battery',
    'Magnet',
    'AC Jali',
    'AC Split',
    'AC Window',
    'Compressor',
    'Fridge (Double Door)',
    'Fridge (Single Door)',
    'PCB',
    'Washing Machine',
  ];

  // ==========================================================
  // TAKE PHOTO
  // ==========================================================

  Future<void> pickPhoto() async {
    final ImagePicker picker = ImagePicker();

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
                Text(
                  AppLanguage.get(
                    'Add Scrap Photo',
                    'स्क्रैप की फोटो जोड़ें',
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: primaryGreen,
                  ),
                  title: Text(
                    AppLanguage.get(
                      'Take Photo',
                      'फोटो लें',
                    ),
                  ),
                  subtitle: Text(
                    AppLanguage.get(
                      'Use camera',
                      'कैमरा इस्तेमाल करें',
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    final XFile? photo =
                        await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 70,
                    );

                    if (photo != null) {
                      setState(() {
                        selectedPhoto = photo;
                      });
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: primaryGreen,
                  ),
                  title: Text(
                    AppLanguage.get(
                      'Choose from Gallery',
                      'गैलरी से चुनें',
                    ),
                  ),
                  subtitle: Text(
                    AppLanguage.get(
                      'Select an existing photo',
                      'पहले से मौजूद फोटो चुनें',
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    final XFile? photo =
                        await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );

                    if (photo != null) {
                      setState(() {
                        selectedPhoto = photo;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // AI SCRAP ANALYSIS
  // ==========================================================

  Future<void> analyzeScrapWithAI() async {
    if (selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.get(
              'Please add a scrap photo first.',
              'कृपया पहले स्क्रैप की फोटो जोड़ें।',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      isAnalyzing = true;
    });

    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3.8-flash',
      );

      final imageBytes =
          await selectedPhoto!.readAsBytes();

      final imagePart = InlineDataPart(
        'image/jpeg',
        imageBytes,
      );

      const prompt = '''
Analyze this scrap/e-waste image for a recycling application.

Identify the visible materials and estimate their approximate percentage composition.

Give the result in this exact format:

Material: ...

Composition:
- Material 1: ...%
- Material 2: ...%
- Material 3: ...%

Components: ...

Recyclable: ...

Estimated Weight Range: ... kg

Confidence: ...

Rules:
- Composition percentages must be approximate visual estimates only.
- Try to make the composition percentages add up to approximately 100%.
- If only one material is clearly visible, give it a high approximate percentage.
- Do not invent materials that are not visible.
- Weight must be an approximate RANGE, not an exact weight.
- Do not claim that weight or composition is measured.
- If the image is unclear, clearly say "Low confidence".
- Keep the answer simple and practical for a scrap collector.
''';

      final response =
          await model.generateContent([
        Content.multi([
          TextPart(prompt),
          imagePart,
        ]),
      ]);

      final result =
          response.text ?? 'No analysis received.';

      if (!mounted) return;

      setState(() {
        aiAnalysisResult = result;
        isAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.get(
              'AI analysis failed: $e',
              'AI विश्लेषण विफल हुआ: $e',
            ),
          ),
        ),
      );
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
        SnackBar(
          content: Text(
            AppLanguage.get(
              'Please enter a valid weight.',
              'कृपया सही वजन दर्ज करें।',
            ),
          ),
        ),
      );
      return;
    }

    if (currentRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.get(
              'Market rate is unavailable for this material and city.',
              'इस मटेरियल और शहर के लिए बाजार दर उपलब्ध नहीं है।',
            ),
          ),
        ),
      );
      return;
    }

    final value = weight * currentRate!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PriceEstimateScreen(
          material: selectedMaterial,
          weight: weight,
          rate: currentRate!,
          estimatedValue: value,
          city: selectedCity,
          selectedPhoto: selectedPhoto,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMarketRate();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  // ==========================================================
// FETCH MARKET RATE - ONLINE + OFFLINE CACHE
// ==========================================================

Future<void> fetchMarketRate() async {
  setState(() {
    isLoadingRate = true;
    rateError = null;
    currentRate = null;
  });

  try {
    // ======================================================
    // 1. TRY FIRESTORE FIRST
    // ======================================================

    final snapshot = await FirebaseFirestore.instance
        .collection('market_rates')
        .where(
          'city',
          isEqualTo: selectedCity,
        )
        .where(
          'material',
          isEqualTo: selectedMaterial,
        )
        .orderBy(
          'date',
          descending: true,
        )
        .limit(1)
        .get();

    // ======================================================
    // 2. FIRESTORE DATA FOUND
    // ======================================================

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();

      final newRateData = <String, dynamic>{
        'city': selectedCity,
        'material': selectedMaterial,
        'rate': (data['rate'] as num?)?.toDouble() ?? 0,
        'unit': data['unit']?.toString() ?? 'kg',
        'source': data['source']?.toString() ?? 'Market data',
        'date': data['date']?.toString() ?? '',
      };

      // ====================================================
      // SAVE THIS RATE LOCALLY
      // ====================================================

      final cachedRates =
          await OfflineStorage.getMarketRates();

      // Remove old cache for same city + material
      cachedRates.removeWhere(
        (item) =>
            item['city']?.toString().toLowerCase() ==
                selectedCity.toLowerCase() &&
            item['material']?.toString().toLowerCase() ==
                selectedMaterial.toLowerCase(),
      );

      // Add latest rate
      cachedRates.add(newRateData);

      await OfflineStorage.saveMarketRates(
        cachedRates,
      );

      // ====================================================
      // SHOW ONLINE RATE
      // ====================================================

      if (!mounted) return;

      setState(() {
        currentRate =
            (data['rate'] as num?)?.toDouble();

        currentRateUnit =
            data['unit']?.toString() ?? 'kg';

        rateSource =
            data['source']?.toString();

        rateDate =
            data['date']?.toString();

        rateError = null;
        isLoadingRate = false;
      });

      return;
    }

    // ======================================================
    // 3. FIRESTORE HAS NO RATE
    //    TRY LOCAL CACHE
    // ======================================================

    final cachedRates =
        await OfflineStorage.getMarketRates();

    final cachedRate = cachedRates.where(
      (item) =>
          item['city']?.toString().toLowerCase() ==
              selectedCity.toLowerCase() &&
          item['material']?.toString().toLowerCase() ==
              selectedMaterial.toLowerCase(),
    ).toList();

    if (cachedRate.isNotEmpty) {
      final data = cachedRate.first;

      if (!mounted) return;

      setState(() {
        currentRate =
            (data['rate'] as num?)?.toDouble();

        currentRateUnit =
            data['unit']?.toString() ?? 'kg';

        rateSource =
            '${data['source']?.toString() ?? 'Market data'} (Cached)';

        rateDate =
            data['date']?.toString();

        rateError = null;
        isLoadingRate = false;
      });

      return;
    }

    // ======================================================
    // 4. NO ONLINE + NO CACHE
    // ======================================================

    if (!mounted) return;

    setState(() {
      currentRate = null;
      rateSource = null;
      rateDate = null;
      currentRateUnit = 'kg';

      rateError = AppLanguage.get(
        'Rate unavailable for $selectedMaterial in $selectedCity.',
        '$selectedCity में $selectedMaterial की दर उपलब्ध नहीं है।',
      );

      isLoadingRate = false;
    });
  } catch (e) {
    // ======================================================
    // 5. INTERNET / FIRESTORE ERROR
    //    USE LOCAL CACHE
    // ======================================================

    try {
      final cachedRates =
          await OfflineStorage.getMarketRates();

      final cachedRate = cachedRates.where(
        (item) =>
            item['city']?.toString().toLowerCase() ==
                selectedCity.toLowerCase() &&
            item['material']?.toString().toLowerCase() ==
                selectedMaterial.toLowerCase(),
      ).toList();

      if (cachedRate.isNotEmpty) {
        final data = cachedRate.first;

        if (!mounted) return;

        setState(() {
          currentRate =
              (data['rate'] as num?)?.toDouble();

          currentRateUnit =
              data['unit']?.toString() ?? 'kg';

          rateSource =
              '${data['source']?.toString() ?? 'Market data'} (Offline Cache)';

          rateDate =
              data['date']?.toString();

          rateError = null;
          isLoadingRate = false;
        });

        return;
      }
    } catch (_) {
      // Local cache also failed.
    }

    // ======================================================
    // 6. NOTHING AVAILABLE
    // ======================================================

    if (!mounted) return;

    setState(() {
      currentRate = null;

      rateError = AppLanguage.get(
        'Could not load market rate. No offline data available.',
        'बाजार दर लोड नहीं हो सकी। ऑफलाइन डेटा उपलब्ध नहीं है।',
      );

      isLoadingRate = false;
    });
  }
}

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLanguage.get(
            'Add Scrap',
            'स्क्रैप जोड़ें',
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // TITLE
            // ==================================================

            Text(
              AppLanguage.get(
                'What material do you have?',
                'आपके पास कौन सा मटेरियल है?',
              ),
              style: const TextStyle(
                color: textColor,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              AppLanguage.get(
                'Take a photo and let AI analyze your scrap.',
                'फोटो लें और AI से अपने स्क्रैप का विश्लेषण करवाएं।',
              ),
              style: const TextStyle(
                color: grayColor,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PHOTO SECTION
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color:
                      const Color(0xFFE2E8F0),
                ),
              ),

              child: Column(
                children: [
                  // PHOTO PREVIEW

                  if (selectedPhoto != null)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),

                      child:
                          FutureBuilder<Uint8List>(
                        future:
                            selectedPhoto!.readAsBytes(),

                        builder:
                            (context, snapshot) {
                          if (snapshot
                                  .connectionState ==
                              ConnectionState
                                  .waiting) {
                            return const SizedBox(
                              height: 180,
                              width:
                                  double.infinity,
                              child: Center(
                                child:
                                    CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              height: 180,
                              width:
                                  double.infinity,
                              fit: BoxFit.cover,
                            );
                          }

                          return SizedBox(
                            height: 180,
                            child: Center(
                              child: Text(
                                AppLanguage.get(
                                  'Unable to preview image',
                                  'फोटो का प्रीव्यू नहीं दिखाया जा सका',
                                ),
                              ),
                            ),
                          );
                        },
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
                        ? AppLanguage.get(
                            'Add photo of scrap',
                            'स्क्रैप की फोटो जोड़ें',
                          )
                        : AppLanguage.get(
                            'Scrap photo added',
                            'स्क्रैप की फोटो जोड़ दी गई',
                          ),

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // PHOTO BUTTON

                  SizedBox(
                    width: double.infinity,

                    child:
                        ElevatedButton.icon(
                      onPressed: pickPhoto,

                      icon: const Icon(
                        Icons.camera_alt,
                      ),

                      label: Text(
                        selectedPhoto == null
                            ? AppLanguage.get(
                                'Add Scrap Photo',
                                'स्क्रैप की फोटो जोड़ें',
                              )
                            : AppLanguage.get(
                                'Retake Photo',
                                'फोटो दोबारा लें',
                              ),
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryGreen,
                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // AI ANALYSIS BUTTON

                  SizedBox(
                    width: double.infinity,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          selectedPhoto == null
                              ? null
                              : analyzeScrapWithAI,

                      icon: const Icon(
                        Icons.auto_awesome,
                      ),

                      label: Text(
                        AppLanguage.get(
                          'Analyze Scrap with AI',
                          'AI से स्क्रैप का विश्लेषण करें',
                        ),
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            darkGreen,
                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // AI ANALYSIS RESULT
            // ==================================================

            if (aiAnalysisResult != null)
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                      BorderRadius.circular(18),

                  border: Border.all(
                    color: primaryGreen,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: darkGreen,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          AppLanguage.get(
                            'AI Scrap Analysis',
                            'AI स्क्रैप विश्लेषण',
                          ),

                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),

                      child: Text(
                        aiAnalysisResult!,
                        style:
                            const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      AppLanguage.get(
                        'Please confirm or edit the material and weight below before calculating price.',
                        'कीमत निकालने से पहले नीचे मटेरियल और वजन की पुष्टि या बदलाव करें।',
                      ),

                      style:
                          const TextStyle(
                        fontSize: 13,
                        color: grayColor,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            // ==================================================
            // MATERIAL
            // ==================================================

            Text(
              AppLanguage.get(
                'Material',
                'मटेरियल',
              ),

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue:
                  selectedMaterial,

              decoration:
                  InputDecoration(
                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),

              items: materials.map(
                (material) {
                  return DropdownMenuItem(
                    value: material,
                    child: Text(material),
                  );
                },
              ).toList(),

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedMaterial = value;
                });

                fetchMarketRate();
              },
            ),

            const SizedBox(height: 25),

            // ==================================================
            // CITY
            // ==================================================

            Text(
              AppLanguage.get(
                'City',
                'शहर',
              ),

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue:
                  selectedCity,

              decoration:
                  InputDecoration(
                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),

              items: cities.map(
                (city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                },
              ).toList(),

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedCity = value;
                });

                fetchMarketRate();
              },
            ),

            const SizedBox(height: 25),

            // ==================================================
            // WEIGHT
            // ==================================================

            Text(
              AppLanguage.get(
                'Approximate Weight',
                'लगभग वजन',
              ),

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  weightController,

              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),

              decoration:
                  InputDecoration(
                hintText:
                    AppLanguage.get(
                  'Example: 50',
                  'उदाहरण: 50',
                ),

                suffixText: 'kg',

                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // CURRENT RATE
            // ==================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: lightGreen,

                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: darkGreen,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: isLoadingRate
                        ? Text(
                            AppLanguage.get(
                              'Loading latest market rate...',
                              'नवीनतम बाजार दर लोड हो रही है...',
                            ),

                            style:
                                const TextStyle(
                              color: darkGreen,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          )
                        : rateError != null
                            ? Text(
                                rateError!,
                                style:
                                    const TextStyle(
                                  color:
                                      darkGreen,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              )
                            : Text(
                                AppLanguage.get(
                                  'Indicative market rate: ₹${currentRate!.toStringAsFixed(2)}/$currentRateUnit\nSource: ${rateSource ?? 'Market data'}\nDate: ${rateDate ?? 'N/A'}',

                                  'अनुमानित बाजार दर: ₹${currentRate!.toStringAsFixed(2)}/$currentRateUnit\nस्रोत: ${rateSource ?? 'Market data'}\nदिनांक: ${rateDate ?? 'N/A'}',
                                ),

                                style:
                                    const TextStyle(
                                  color:
                                      darkGreen,
                                  fontWeight:
                                      FontWeight.w600,
                                  height: 1.5,
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
                onPressed:
                    continueToPrice,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryGreen,
                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                child: Text(
                  AppLanguage.get(
                    'Check Estimated Value',
                    'अनुमानित कीमत देखें',
                  ),

                  style:
                      const TextStyle(
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
// PRICE ESTIMATE SCREEN
// ============================================================

class PriceEstimateScreen extends StatelessWidget {
  final String material;
  final double weight;
  final double rate;
  final double estimatedValue;
  final String city;
  final XFile? selectedPhoto;

  const PriceEstimateScreen({
    super.key,
    required this.material,
    required this.weight,
    required this.rate,
    required this.estimatedValue,
    required this.city,
    this.selectedPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLanguage.get(
            'Price Estimate',
            'कीमत का अनुमान',
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // =========================
            // ESTIMATED VALUE
            // =========================

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

                  Text(
                    AppLanguage.get(
                      'Estimated Value',
                      'अनुमानित कीमत',
                    ),
                    style: const TextStyle(
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

            // =========================
            // SCRAP PHOTO
            // =========================

            if (selectedPhoto != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),

                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),

                      child: FutureBuilder<Uint8List>(
                        future:
                            selectedPhoto!.readAsBytes(),

                        builder:
                            (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            );
                          }

                          return const SizedBox(
                            width: 70,
                            height: 70,
                            child: Center(
                              child:
                                  CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        AppLanguage.get(
                          'Scrap photo added successfully',
                          'स्क्रैप की फोटो सफलतापूर्वक जोड़ दी गई',
                        ),
                        style: const TextStyle(
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

            // =========================
            // SCRAP DETAILS
            // =========================

            InfoRow(
              label: AppLanguage.get(
                'Material',
                'मटेरियल',
              ),
              value: material,
            ),

            InfoRow(
              label: AppLanguage.get(
                'Weight',
                'वजन',
              ),
              value:
                  '${weight.toStringAsFixed(1)} kg',
            ),

            InfoRow(
              label: AppLanguage.get(
                'Rate',
                'दर',
              ),
              value:
                  '₹${rate.toStringAsFixed(2)}/kg',
            ),

            InfoRow(
              label: AppLanguage.get(
                'City',
                'शहर',
              ),
              value: city,
            ),

            const Spacer(),

            // =========================
            // FIND RECYCLER BUTTON
            // =========================

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
                        city: city,
                        rate: rate,
                        material: material,
                        weight: weight,
                        estimatedValue:
                            estimatedValue,
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

                child: Text(
                  AppLanguage.get(
                    'Find Recycler',
                    'रीसाइक्लर खोजें',
                  ),

                  style: const TextStyle(
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
// RECYCLER MATCHING SCREEN - ONLINE + OFFLINE
// ============================================================

class RecyclerMatchingScreen extends StatefulWidget {
  final String city;
  final String material;
  final double weight;
  final double rate;
  final double estimatedValue;
  final XFile? selectedPhoto;

  const RecyclerMatchingScreen({
    super.key,
    required this.material,
    required this.city,
    required this.weight,
    required this.rate,
    required this.estimatedValue,
    this.selectedPhoto,
  });

  @override
  State<RecyclerMatchingScreen> createState() =>
      _RecyclerMatchingScreenState();
}

class _RecyclerMatchingScreenState
    extends State<RecyclerMatchingScreen> {

  bool isLoading = true;
  bool isOfflineData = false;

  List<Map<String, dynamic>> recyclers = [];

  @override
  void initState() {
    super.initState();
    loadRecyclers();
  }

  // ==========================================================
  // LOAD RECYCLERS - ONLINE + OFFLINE CACHE
  // ==========================================================

  Future<void> loadRecyclers() async {
    setState(() {
      isLoading = true;
      isOfflineData = false;
    });

    try {
      // ======================================================
      // 1. TRY FIRESTORE FIRST
      // ======================================================

      final snapshot = await FirebaseFirestore.instance
          .collection('recyclers')
          .get();

      final onlineRecyclers = snapshot.docs.map((doc) {
        final data = doc.data();

        return <String, dynamic>{
          ...data,
          'documentId': doc.id,
        };
      }).toList();

      // ======================================================
      // 2. SAVE FIRESTORE DATA TO LOCAL CACHE
      // ======================================================

      if (onlineRecyclers.isNotEmpty) {
        await OfflineStorage.saveRecyclers(
          onlineRecyclers,
        );
      }

      // ======================================================
      // 3. FILTER CITY
      // ======================================================

      final filteredRecyclers =
          onlineRecyclers.where((recycler) {
        final recyclerCity =
            recycler['city']?.toString().trim();

        if (recyclerCity == null ||
            recyclerCity.isEmpty) {
          return false;
        }

        return recyclerCity.toLowerCase() ==
            widget.city.toLowerCase();
      }).toList();

      if (!mounted) return;

      setState(() {
        recyclers = filteredRecyclers;
        isLoading = false;
        isOfflineData = false;
      });

      return;
    } catch (e) {
      // ======================================================
      // 4. FIRESTORE FAILED -> USE LOCAL CACHE
      // ======================================================

      try {
        final cachedRecyclers =
            await OfflineStorage.getRecyclers();

        final filteredCachedRecyclers =
            cachedRecyclers.where((recycler) {
          final recyclerCity =
              recycler['city']?.toString().trim();

          if (recyclerCity == null ||
              recyclerCity.isEmpty) {
            return false;
          }

          return recyclerCity.toLowerCase() ==
              widget.city.toLowerCase();
        }).toList();

        if (!mounted) return;

        setState(() {
          recyclers = filteredCachedRecyclers;
          isLoading = false;
          isOfflineData = true;
        });

        return;
      } catch (_) {
        // Local cache also failed.
      }

      // ======================================================
      // 5. NOTHING AVAILABLE
      // ======================================================

      if (!mounted) return;

      setState(() {
        recyclers = [];
        isLoading = false;
        isOfflineData = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLanguage.get(
            'Verified Recyclers',
            'सत्यापित रीसाइक्लर',
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // ==================================================
          // SCRAP SUMMARY
          // ==================================================

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
                    '${widget.material} • '
                    '${widget.weight.toStringAsFixed(1)} kg',

                    style: const TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ==================================================
          // SELECTED CITY
          // ==================================================

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: grayColor,
              ),

              const SizedBox(width: 6),

              Text(
                AppLanguage.get(
                  'Location: ${widget.city}',
                  'स्थान: ${widget.city}',
                ),

                style: const TextStyle(
                  color: grayColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==================================================
          // HEADING
          // ==================================================

          Text(
            AppLanguage.get(
              'Matching Recyclers',
              'मैचिंग रीसाइक्लर',
            ),

            style: const TextStyle(
              color: textColor,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            AppLanguage.get(
              'Verified recyclers available in ${widget.city}',
              '${widget.city} में उपलब्ध सत्यापित रीसाइक्लर',
            ),

            style: const TextStyle(
              color: grayColor,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // OFFLINE CACHE INDICATOR
          // ==================================================

          if (isOfflineData && !isLoading)
            Container(
              margin: const EdgeInsets.only(bottom: 15),

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFED7AA),
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off,
                    color: Colors.orange,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      AppLanguage.get(
                        'Showing saved recycler data (Offline)',
                        'सेव किया हुआ रीसाइक्लर डेटा दिखाया जा रहा है (ऑफलाइन)',
                      ),

                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ==================================================
          // LOADING
          // ==================================================

          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(),
              ),
            )

          // ==================================================
          // NO MATCHING RECYCLER
          // ==================================================

          else if (recyclers.isEmpty)
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),

              child: Column(
                children: [
                  const Icon(
                    Icons.location_off_outlined,
                    color: grayColor,
                    size: 45,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    AppLanguage.get(
                      'No matching recycler found in ${widget.city}.',
                      '${widget.city} में कोई मैचिंग रीसाइक्लर नहीं मिला।',
                    ),

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppLanguage.get(
                      'Please try another city.',
                      'कृपया कोई दूसरा शहर चुनें।',
                    ),

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: grayColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )

          // ==================================================
          // RECYCLER CARDS
          // ==================================================

          else
            Column(
              children: recyclers.map((recycler) {
                final name =
                    recycler['name'] ??
                        'Recycler';

                final address =
                    recycler['address'] ??
                        'Address not available';

                final activity =
                    recycler['activity'] ??
                        'E-waste recycling';

                final status =
                    recycler['registrationStatus'] ??
                        'Status not available';

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(18),

                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // ======================================
                      // RECYCLER NAME
                      // ======================================

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
                              name.toString(),

                              style:
                                  const TextStyle(
                                color: textColor,
                                fontWeight:
                                    FontWeight.bold,
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

                      // ======================================
                      // ADDRESS
                      // ======================================

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: grayColor,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              address.toString(),

                              style:
                                  const TextStyle(
                                color: grayColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ======================================
                      // ACTIVITY
                      // ======================================

                      Text(
                        AppLanguage.get(
                          'Activity: ${activity.toString()}',
                          'कार्य: ${activity.toString()}',
                        ),

                        style: const TextStyle(
                          color: grayColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ======================================
                      // STATUS
                      // ======================================

                      Text(
                        AppLanguage.get(
                          'Status: ${status.toString()}',
                          'स्थिति: ${status.toString()}',
                        ),

                        style: const TextStyle(
                          color: grayColor,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ======================================
                      // SELECT RECYCLER
                      // ======================================

                      SizedBox(
                        width: double.infinity,
                        height: 45,

                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    LotHandoverScreen(
                                  material:
                                      widget.material,

                                  weight:
                                      widget.weight,

                                  rate:
                                      widget.rate,

                                  recyclerId:
                                      recycler[
                                              'recyclerId']
                                          ?.toString() ??
                                      '',

                                  recyclerName:
                                      recycler['name']
                                              ?.toString() ??
                                          'Recycler',

                                  recyclerCity:
                                      recycler['city']
                                              ?.toString() ??
                                          widget.city,
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
                                  BorderRadius.circular(12),
                            ),
                          ),

                          child: Text(
                            AppLanguage.get(
                              'Select Recycler',
                              'रीसाइक्लर चुनें',
                            ),

                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
  final double rate;
  final String recyclerId;
  final String recyclerName;
  final String recyclerCity;

  const LotHandoverScreen({
    super.key,
    required this.material,
    required this.weight,
    required this.rate,
    required this.recyclerId,
    required this.recyclerName,
    required this.recyclerCity,
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
        '${now.millisecondsSinceEpoch}';
  }

  // ==========================================================
// COMPLETE HANDOVER - ONLINE + OFFLINE
// ==========================================================

Future<void> completeHandover() async {
  if (saving) return;

  setState(() {
    saving = true;
  });

  final lotId = createLotId();

  final estimatedValue =
      widget.weight * widget.rate;

  final handoverDateTime = DateTime.now();

  // Unique transaction ID
  final transactionId =
      'TX-${DateTime.now().millisecondsSinceEpoch}';

  // ========================================================
  // TRANSACTION DATA
  // ========================================================

  final transactionData = <String, dynamic>{
    'transactionId': transactionId,
    'lotId': lotId,

    'material': widget.material,
    'weight': widget.weight,
    'rate': widget.rate,
    'estimatedValue': estimatedValue,

    'recyclerId': widget.recyclerId,
    'recyclerName': widget.recyclerName,
    'recyclerCity': widget.recyclerCity,

    'status': 'Handover Record Created',

    // Store as String for local storage compatibility
    'handoverDateTime':
        handoverDateTime.toIso8601String(),

    'createdAt':
        handoverDateTime.toIso8601String(),
  };

  try {
    // ======================================================
    // 1. TRY FIRESTORE
    // ======================================================

    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transactionId)
        .set({
      'transactionId': transactionId,
      'lotId': lotId,

      'material': widget.material,
      'weight': widget.weight,
      'rate': widget.rate,
      'estimatedValue': estimatedValue,

      'recyclerId': widget.recyclerId,
      'recyclerName': widget.recyclerName,
      'recyclerCity': widget.recyclerCity,

      'status': 'Handover Record Created',

      'createdAt':
          FieldValue.serverTimestamp(),

      'handoverDateTime':
          Timestamp.fromDate(handoverDateTime),
    });

    // ======================================================
    // ONLINE SUCCESS
    // ======================================================

    if (!mounted) return;

    setState(() {
      saving = false;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => DigitalReceiptScreen(
          lotId: lotId,
          material: widget.material,
          weight: widget.weight,
          rate: widget.rate,
          estimatedValue: estimatedValue,
          recyclerId: widget.recyclerId,
          recyclerName: widget.recyclerName,
          recyclerCity: widget.recyclerCity,
          handoverDateTime:
              handoverDateTime,
        ),
      ),
      (route) => route.isFirst,
    );
  } catch (e) {
    // ======================================================
    // 2. FIRESTORE FAILED
    //    SAVE TRANSACTION LOCALLY
    // ======================================================

    try {
      await OfflineStorage.savePendingTransaction(
        transactionData,
      );

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      // ====================================================
      // OFFLINE RECEIPT
      // ====================================================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.get(
              'No internet. Transaction saved offline and will sync later.',
              'इंटरनेट नहीं है। लेनदेन ऑफलाइन सेव हो गया है और बाद में सिंक होगा।',
            ),
          ),
          duration:
              const Duration(seconds: 3),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => DigitalReceiptScreen(
            lotId: lotId,
            material: widget.material,
            weight: widget.weight,
            rate: widget.rate,
            estimatedValue:
                estimatedValue,
            recyclerId:
                widget.recyclerId,
            recyclerName:
                widget.recyclerName,
            recyclerCity:
                widget.recyclerCity,
            handoverDateTime:
                handoverDateTime,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (localError) {
      // ====================================================
      // LOCAL SAVE ALSO FAILED
      // ====================================================

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.get(
              'Transaction could not be saved.',
              'लेनदेन सेव नहीं हो सका।',
            ),
          ),
        ),
      );
    }
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
        title: Text(
          AppLanguage.get(
            'Digital Handover',
            'डिजिटल हैंडओवर',
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HEADING
            // ==================================================

            Text(
              AppLanguage.get(
                'Confirm Handover',
                'हैंडओवर की पुष्टि करें',
              ),

              style: const TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              AppLanguage.get(
                'Review the transaction before creating the digital record.',
                'डिजिटल रिकॉर्ड बनाने से पहले लेनदेन की जानकारी जांचें।',
              ),

              style: const TextStyle(
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
                        Text(
                          AppLanguage.get(
                            'Digital Lot ID',
                            'डिजिटल लॉट ID',
                          ),

                          style: const TextStyle(
                            color: darkGreen,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          AppLanguage.get(
                            'Will be: ${createLotId()}',
                            'होगा: ${createLotId()}',
                          ),

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
                        label: AppLanguage.get(
                          'Material',
                          'मटेरियल',
                        ),
                        value: widget.material,
                      ),

                      InfoRow(
                        label: AppLanguage.get(
                          'Weight',
                          'वजन',
                        ),
                        value:
                            '${widget.weight.toStringAsFixed(1)} kg',
                      ),

                      InfoRow(
                        label: AppLanguage.get(
                          'Rate',
                          'दर',
                        ),
                        value:
                            '₹${widget.rate.toStringAsFixed(2)}/kg',
                      ),

                      InfoRow(
                        label: AppLanguage.get(
                          'Recycler',
                          'रीसाइक्लर',
                        ),
                        value:
                            widget.recyclerName,
                      ),

                      InfoRow(
                        label: AppLanguage.get(
                          'Recycler City',
                          'रीसाइक्लर शहर',
                        ),
                        value:
                            widget.recyclerCity,
                      ),

                      InfoRow(
                        label: AppLanguage.get(
                          'Estimated Value',
                          'अनुमानित कीमत',
                        ),
                        value:
                            '₹${estimatedValue.toStringAsFixed(0)}',
                      ),

                      InfoRow(
                        label: AppLanguage.get(
                          'Date',
                          'दिनांक',
                        ),
                        value: dateText,
                      ),

                      InfoRow(
                        label: AppLanguage.get(
                          'Time',
                          'समय',
                        ),
                        value: timeText,
                      ),

                      const SizedBox(height: 15),

                      // ========================================
                      // STATUS
                      // ========================================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: darkGreen,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                AppLanguage.get(
                                  'Status: Ready for digital handover',
                                  'स्थिति: डिजिटल हैंडओवर के लिए तैयार',
                                ),

                                style:
                                    const TextStyle(
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
                    : Text(
                        AppLanguage.get(
                          'Confirm & Create Digital Record',
                          'पुष्टि करें और डिजिटल रिकॉर्ड बनाएं',
                        ),

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
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
  final double rate;
  final double estimatedValue;

  final String recyclerId;
  final String recyclerName;
  final String recyclerCity;

  final DateTime handoverDateTime;

  const DigitalReceiptScreen({
    super.key,
    required this.lotId,
    required this.material,
    required this.weight,
    required this.rate,
    required this.estimatedValue,
    required this.recyclerId,
    required this.recyclerName,
    required this.recyclerCity,
    required this.handoverDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${handoverDateTime.day.toString().padLeft(2, '0')}/'
        '${handoverDateTime.month.toString().padLeft(2, '0')}/'
        '${handoverDateTime.year}';

    final timeText =
        '${handoverDateTime.hour.toString().padLeft(2, '0')}:'
        '${handoverDateTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLanguage.get(
            'Digital Receipt',
            'डिजिटल रसीद',
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 15),

            // ==================================================
            // SUCCESS ICON
            // ==================================================

            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius:
                    BorderRadius.circular(25),
              ),

              child: const Icon(
                Icons.check_circle,
                color: primaryGreen,
                size: 55,
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // SUCCESS MESSAGE
            // ==================================================

            Text(
              AppLanguage.get(
                'Digital Record Created',
                'डिजिटल रिकॉर्ड बन गया',
              ),

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: darkGreen,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              AppLanguage.get(
                'Your handover transaction has been recorded successfully.',
                'आपका हैंडओवर लेनदेन सफलतापूर्वक रिकॉर्ड हो गया है।',
              ),

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: grayColor,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // RECEIPT CARD
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),

                border: Border.all(
                  color:
                      const Color(0xFFE2E8F0),
                ),
              ),

              child: Column(
                children: [
                  // ==========================================
                  // LOT ID
                  // ==========================================

                  Text(
                    AppLanguage.get(
                      'DIGITAL LOT ID',
                      'डिजिटल लॉट ID',
                    ),

                    style: const TextStyle(
                      color: grayColor,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    lotId,

                    textAlign:
                        TextAlign.center,

                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const Divider(height: 30),

                  // ==========================================
                  // TRANSACTION DETAILS
                  // ==========================================

                  InfoRow(
                    label: AppLanguage.get(
                      'Material',
                      'मटेरियल',
                    ),
                    value: material,
                  ),

                  InfoRow(
                    label: AppLanguage.get(
                      'Weight',
                      'वजन',
                    ),
                    value:
                        '${weight.toStringAsFixed(1)} kg',
                  ),

                  InfoRow(
                    label: AppLanguage.get(
                      'Rate',
                      'दर',
                    ),
                    value:
                        '₹${rate.toStringAsFixed(2)}/kg',
                  ),

                  InfoRow(
                    label: AppLanguage.get(
                      'Estimated Value',
                      'अनुमानित कीमत',
                    ),
                    value:
                        '₹${estimatedValue.toStringAsFixed(0)}',
                  ),

                  InfoRow(
                    label: AppLanguage.get(
                      'Recycler',
                      'रीसाइक्लर',
                    ),
                    value: recyclerName,
                  ),

                  InfoRow(
                    label: AppLanguage.get(
                      'Recycler City',
                      'रीसाइक्लर शहर',
                    ),
                    value: recyclerCity,
                  ),

                  InfoRow(
                    label: AppLanguage.get(
                      'Date',
                      'दिनांक',
                    ),
                    value: dateText,
                  ),

                  InfoRow(
                    label: AppLanguage.get(
                      'Time',
                      'समय',
                    ),
                    value: timeText,
                  ),

                  const SizedBox(height: 10),

                  // ==========================================
                  // TRANSACTION STATUS
                  // ==========================================

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        const Icon(
                          Icons.verified,
                          color: darkGreen,
                          size: 18,
                        ),

                        const SizedBox(width: 7),

                        Text(
                          AppLanguage.get(
                            'Transaction Recorded',
                            'लेनदेन रिकॉर्ड हो गया',
                          ),

                          style:
                              const TextStyle(
                            color: darkGreen,
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

            const SizedBox(height: 25),

            // ==================================================
            // BACK TO HOME
            // ==================================================

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

                child: Text(
                  AppLanguage.get(
                    'Back to Home',
                    'होम पर जाएं',
                  ),

                  style: const TextStyle(
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
// TRANSACTION HISTORY
// ============================================================

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

  String formatDate(dynamic timestamp) {
    if (timestamp is! Timestamp) {
      return AppLanguage.get(
        'Date not available',
        'दिनांक उपलब्ध नहीं है',
      );
    }

    final date = timestamp.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ==================================================
          // TITLE
          // ==================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              10,
            ),

            child: Align(
              alignment: Alignment.centerLeft,

              child: Text(
                AppLanguage.get(
                  'Transaction History',
                  'लेनदेन इतिहास',
                ),

                style: const TextStyle(
                  color: textColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ==================================================
          // FIRESTORE HISTORY
          // ==================================================

          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .snapshots(),

              builder: (
                context,
                snapshot,
              ) {
                // ==========================================
                // LOADING
                // ==========================================

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryGreen,
                    ),
                  );
                }

                // ==========================================
                // ERROR
                // ==========================================

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),

                      child: Text(
                        AppLanguage.get(
                          'Could not load history.\n\n'
                          '${snapshot.error}',

                          'इतिहास लोड नहीं हो सका।\n\n'
                          '${snapshot.error}',
                        ),

                        textAlign:
                            TextAlign.center,

                        style: const TextStyle(
                          color: grayColor,
                        ),
                      ),
                    ),
                  );
                }

                // ==========================================
                // EMPTY HISTORY
                // ==========================================

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 65,
                          color: Color(0xFFCBD5E1),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          AppLanguage.get(
                            'No transactions yet',
                            'अभी कोई लेनदेन नहीं है',
                          ),

                          style:
                              const TextStyle(
                            color: grayColor,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // ==========================================
                // SORT TRANSACTIONS
                // ==========================================

                final userDocs =
                    snapshot.data!.docs.toList();

                // Latest transaction first
                userDocs.sort((a, b) {
                  final dataA = a.data();
                  final dataB = b.data();

                  final timeA =
                      dataA['createdAt'];

                  final timeB =
                      dataB['createdAt'];

                  if (timeA is! Timestamp &&
                      timeB is! Timestamp) {
                    return 0;
                  }

                  if (timeA is! Timestamp) {
                    return 1;
                  }

                  if (timeB is! Timestamp) {
                    return -1;
                  }

                  return timeB.compareTo(timeA);
                });

                // ==========================================
                // HISTORY LIST
                // ==========================================

                return ListView.builder(
                  padding:
                      const EdgeInsets.all(20),

                  itemCount:
                      userDocs.length,

                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final data =
                        userDocs[index].data();

                    final material =
                        data['material']
                                ?.toString() ??
                            'Unknown';

                    final weight =
                        data['weight'] is num
                            ? (data['weight']
                                    as num)
                                .toDouble()
                            : 0.0;

                    final value =
                        data['estimatedValue']
                                is num
                            ? (data[
                                        'estimatedValue']
                                    as num)
                                .toDouble()
                            : 0.0;

                    final recycler =
                        data['recyclerName']
                                ?.toString() ??
                            'Recycler';

                    final recyclerCity =
                        data['recyclerCity']
                                ?.toString() ??
                            AppLanguage.get(
                              'City not available',
                              'शहर उपलब्ध नहीं है',
                            );

                    final lotId =
                        data['lotId']
                                ?.toString() ??
                            AppLanguage.get(
                              'No Lot ID',
                              'लॉट ID उपलब्ध नहीं है',
                            );

                    final status =
                        data['status']
                                ?.toString() ??
                            'Recorded';

                    final date =
                        formatDate(
                      data['createdAt'],
                    );

                    // ======================================
                    // TRANSACTION CARD
                    // ======================================

                    return Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),

                      padding:
                          const EdgeInsets.all(18),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        border: Border.all(
                          color: const Color(
                            0xFFE2E8F0,
                          ),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          // ==================================
                          // MATERIAL + VALUE
                          // ==================================

                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,

                                decoration:
                                    BoxDecoration(
                                  color:
                                      lightGreen,

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    14,
                                  ),
                                ),

                                child:
                                    const Icon(
                                  Icons.receipt_long,
                                  color:
                                      primaryGreen,
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    Text(
                                      material,

                                      style:
                                          const TextStyle(
                                        color:
                                            textColor,
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 3,
                                    ),

                                    Text(
                                      lotId,

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
                                '₹${value.toStringAsFixed(0)}',

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

                          const SizedBox(
                            height: 15,
                          ),

                          const Divider(),

                          const SizedBox(
                            height: 10,
                          ),

                          // ==================================
                          // WEIGHT
                          // ==================================

                          Text(
                            AppLanguage.get(
                              'Weight: '
                              '${weight.toStringAsFixed(1)} kg',

                              'वजन: '
                              '${weight.toStringAsFixed(1)} kg',
                            ),

                            style:
                                const TextStyle(
                              color: grayColor,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          // ==================================
                          // RECYCLER
                          // ==================================

                          Text(
                            AppLanguage.get(
                              'Recycler: $recycler',
                              'रीसाइक्लर: $recycler',
                            ),

                            style:
                                const TextStyle(
                              color: grayColor,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          // ==================================
                          // CITY
                          // ==================================

                          Text(
                            AppLanguage.get(
                              'City: $recyclerCity',
                              'शहर: $recyclerCity',
                            ),

                            style:
                                const TextStyle(
                              color: grayColor,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          // ==================================
                          // DATE
                          // ==================================

                          Text(
                            AppLanguage.get(
                              'Date: $date',
                              'दिनांक: $date',
                            ),

                            style:
                                const TextStyle(
                              color: grayColor,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          // ==================================
                          // STATUS
                          // ==================================

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  lightGreen,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8,
                              ),
                            ),

                            child: Text(
                              status,

                              style:
                                  const TextStyle(
                                color:
                                    darkGreen,
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
class RecyclerUploadScreen extends StatelessWidget {
  const RecyclerUploadScreen({super.key});

  Future<void> upload() async {
    await uploadRecyclers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLanguage.get(
            'Recycler Data Upload',
            'रीसाइक्लर डेटा अपलोड',
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await upload();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLanguage.get(
                      'Recycler uploaded successfully!',
                      'रीसाइक्लर डेटा सफलतापूर्वक अपलोड हो गया!',
                    ),
                  ),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLanguage.get(
                      'Upload failed: $e',
                      'अपलोड विफल रहा: $e',
                    ),
                  ),
                ),
              );
            }
          },
          child: Text(
            AppLanguage.get(
              'UPLOAD RECYCLER DATA',
              'रीसाइक्लर डेटा अपलोड करें',
            ),
          ),
        ),
      ),
    );
  }
}