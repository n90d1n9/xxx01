// lib/main.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const ProviderScope(child: BookingApp()));
}

class BookingApp extends ConsumerWidget {
  const BookingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'StayEase',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// lib/app/theme/app_theme.dart

class AppTheme {
  static const primaryColor = Color(0xFF2A9D8F);
  static const secondaryColor = Color(0xFFE9C46A);
  static const backgroundColor = Color(0xFFF8F9FA);
  static const textColor = Color(0xFF264653);
  static const errorColor = Color(0xFFE76F51);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        onBackground: textColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  //  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = true;
      // authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }

      if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PropertyDetailsScreen(id: id);
        },
      ),
      GoRoute(
        path: '/booking/:propertyId',
        builder: (context, state) {
          final propertyId = state.pathParameters['propertyId']!;
          return BookingScreen(propertyId: propertyId);
        },
      ),
      GoRoute(
        path: '/booking-confirmation/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingConfirmationScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

// lib/app/core/models/property.dart
class Property {
  final String id;
  final String name;
  final String description;
  final String address;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;
  final List<String> amenities;
  final List<String> imageUrls;
  final String hostId;
  final double rating;
  final int reviewCount;
  final PropertyType type;
  final bool hasWifi;
  final bool hasParking;
  final bool hasAirConditioning;
  final bool hasKitchen;

  final String imageUrl;

  final String? location;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.amenities,
    required this.imageUrls,
    required this.hostId,
    required this.rating,
    required this.reviewCount,
    required this.type,
    required this.hasWifi,
    required this.hasParking,
    required this.hasAirConditioning,
    required this.hasKitchen,
    required this.imageUrl,
    this.location,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      price: json['price'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      maxGuests: json['maxGuests'],
      amenities: List<String>.from(json['amenities']),
      imageUrls: List<String>.from(json['imageUrls']),
      hostId: json['hostId'],
      rating: json['rating'],
      reviewCount: json['reviewCount'],
      type: PropertyTypeExtension.fromString(json['type']),
      hasWifi: json['hasWifi'],
      hasParking: json['hasParking'],
      hasAirConditioning: json['hasAirConditioning'],
      hasKitchen: json['hasKitchen'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'maxGuests': maxGuests,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'hostId': hostId,
      'rating': rating,
      'reviewCount': reviewCount,
      'type': type.toString(),
      'hasWifi': hasWifi,
      'hasParking': hasParking,
      'hasAirConditioning': hasAirConditioning,
      'hasKitchen': hasKitchen,
    };
  }
}

enum PropertyType { residence, guestHouse, villa, apartment }

extension PropertyTypeExtension on PropertyType {
  String get displayName {
    switch (this) {
      case PropertyType.residence:
        return 'Residence';
      case PropertyType.guestHouse:
        return 'Guest House';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.apartment:
        return 'Apartment';
      default:
        return 'Unknown';
    }
  }

  static PropertyType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'residence':
        return PropertyType.residence;
      case 'guesthouse':
        return PropertyType.guestHouse;
      case 'villa':
        return PropertyType.villa;
      case 'apartment':
        return PropertyType.apartment;
      default:
        return PropertyType.residence;
    }
  }
}

// lib/app/core/models/booking.dart

class Booking {
  final String id;
  final String propertyId;
  final String userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final String? specialRequests;
  final bool isPaid;

  Booking({
    String? id,
    required this.propertyId,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    DateTime? createdAt,
    this.specialRequests,
    this.isPaid = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  int get numberOfNights {
    return checkOut.difference(checkIn).inDays;
  }

  bool get isActive {
    return status == BookingStatus.confirmed &&
        DateTime.now().isBefore(checkOut);
  }

  bool get isUpcoming {
    return status == BookingStatus.confirmed &&
        DateTime.now().isBefore(checkIn);
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      propertyId: json['propertyId'],
      userId: json['userId'],
      checkIn: DateTime.parse(json['checkIn']),
      checkOut: DateTime.parse(json['checkOut']),
      guestCount: json['guestCount'],
      totalPrice: json['totalPrice'],
      status: BookingStatusExtension.fromString(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      specialRequests: json['specialRequests'],
      isPaid: json['isPaid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guestCount': guestCount,
      'totalPrice': totalPrice,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'specialRequests': specialRequests,
      'isPaid': isPaid,
    };
  }

  Booking copyWith({
    String? id,
    String? propertyId,
    String? userId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestCount,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
    String? specialRequests,
    bool? isPaid,
  }) {
    return Booking(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guestCount: guestCount ?? this.guestCount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      specialRequests: specialRequests ?? this.specialRequests,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

enum BookingStatus { pending, confirmed, canceled, completed }

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.canceled:
        return 'Canceled';
      case BookingStatus.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'canceled':
        return BookingStatus.canceled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }
}

// lib/app/core/models/user.dart
class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isHost;
  final DateTime createdAt;
  final List<String> favoriteProperties;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profileImageUrl,
    this.isHost = false,
    required this.createdAt,
    this.favoriteProperties = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      isHost: json['isHost'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      favoriteProperties: json['favoriteProperties'] != null
          ? List<String>.from(json['favoriteProperties'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isHost': isHost,
      'createdAt': createdAt.toIso8601String(),
      'favoriteProperties': favoriteProperties,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isHost,
    DateTime? createdAt,
    List<String>? favoriteProperties,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isHost: isHost ?? this.isHost,
      createdAt: createdAt ?? this.createdAt,
      favoriteProperties: favoriteProperties ?? this.favoriteProperties,
    );
  }
}

// lib/app/features/auth/providers/auth_provider.dart

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(); //FirebaseAuth.instance);
});

/* final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
}); */

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  /*  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return null; */

  return authRepository.getUser('user.uid');
});

// lib/app/features/auth/data/auth_repository.dart

class AuthRepository {
  /*  final FirebaseAuth _firebaseAuth;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepository(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
 */
  Future<AppUser?> getUser(String uid) async {
    try {
      /* final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data()!..addAll({'id': uid}));
      } */
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      /* final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      final appUser = AppUser(
        id: user.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      // await _firestore.collection('users').doc(user.uid).set(appUser.toJson());

      return appUser; */
      return AppUser(
        id: 'id',
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      /* final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = await getUser(userCredential.user!.uid);
      if (user == null) {
        throw Exception('User not found');
      } */

      //return user;
      return AppUser(
        id: 'id',
        email: email,
        fullName: 'fullName',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    // await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    //await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

// lib/app/features/auth/presentation/screens/login_screen.dart

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid email or password. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Implement forgot password
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// lib/app/features/property/providers/property_provider.dart

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepository();
});

final propertiesProvider = FutureProvider<List<Property>>((ref) async {
  final repository = ref.watch(propertyRepositoryProvider);
  return repository.getProperties();
});

final propertyProvider = FutureProvider.family<Property, String>((
  ref,
  id,
) async {
  final repository = ref.watch(propertyRepositoryProvider);
  return repository.getProperty(id);
});

final featuredPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final properties = await ref.watch(propertiesProvider.future);
  // Sort by rating and limit to 5
  return properties.where((property) => property.rating >= 4.5).toList()
    ..sort((a, b) => b.rating.compareTo(a.rating));
});

final propertyTypeFilterProvider = StateProvider<PropertyType?>((ref) => null);

final filteredPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final properties = await ref.watch(propertiesProvider.future);
  final typeFilter = ref.watch(propertyTypeFilterProvider);

  if (typeFilter == null) {
    return properties;
  }

  return properties.where((property) => property.type == typeFilter).toList();
});

// lib/app/features/property/data/property_repository.dart

class PropertyRepository {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Property>> getProperties() async {
    try {
      /* final snapshot = await _firestore.collection('properties').get();
      return snapshot.docs
          .map((doc) => Property.fromJson(doc.data()..addAll({'id': doc.id})))
          .toList(); */
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Property> getProperty(String id) async {
    try {
      /* final doc = await _firestore.collection('properties').doc(id).get();
      if (!doc.exists) {
        throw Exception('Property not found');
      }
      return Property.fromJson(doc.data()!..addAll({'id': id})); */

      return Property(
        id: id,
        name: 'name',
        description: 'description',
        address: 'address',
        price: 545,
        bedrooms: 2,
        bathrooms: 3,
        maxGuests: 2,
        amenities: [],
        imageUrls: ['imageUrls'],
        hostId: 'hostId',
        rating: 2,
        reviewCount: 2,
        type: PropertyType.apartment,
        hasWifi: true,
        hasParking: true,
        hasAirConditioning: true,
        hasKitchen: true,
        imageUrl: 'imageUrl',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Property>> searchProperties({
    String? query,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    PropertyType? type,
  }) async {
    try {
      /* Query<Map<String, dynamic>> propertiesQuery = _firestore.collection(
        'properties',
      );

      if (type != null) {
        propertiesQuery = propertiesQuery.where(
          'type',
          isEqualTo: type.toString(),
        );
      }

      final snapshot = await propertiesQuery.get();
      final properties =
          snapshot.docs
              .map(
                (doc) => Property.fromJson(doc.data()..addAll({'id': doc.id})),
              )
              .toList(); */

      // Further filtering can be done in-memory for complex queries
      /* return properties.where((property) {
        bool matches = true;

        if (query != null && query.isNotEmpty) {
          matches =
              property.name.toLowerCase().contains(query.toLowerCase()) ||
              property.description.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              property.address.toLowerCase().contains(query.toLowerCase());
        }

        if (guests != null) {
          matches = matches && property.maxGuests >= guests;
        }

        return matches;
      }).toList(); */

      return [];
    } catch (e) {
      rethrow;
    }
  }
}

// lib/app/features/home/presentation/screens/home_screen.dart

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredProperties = ref.watch(featuredPropertiesProvider);
    final filteredProperties = ref.watch(filteredPropertiesProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('StayEase'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    // Navigate to favorites
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => context.go('/profile'),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SearchBarWidget(),
                    const SizedBox(height: 24),
                    const Text(
                      'Explore by Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CategorySelector(),
                    const SizedBox(height: 24),
                    const Text(
                      'Featured Properties',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            featuredProperties.when(
              data: (properties) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: properties.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: PropertyCard(
                            property: properties[index],
                            onTap: () =>
                                context.go('/property/${properties[index].id}'),
                            width: 260,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Center(
                  child: Text('Failed to load featured properties'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'All Properties',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            filteredProperties.when(
              data: (properties) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: PropertyCard(
                        property: properties[index],
                        onTap: () =>
                            context.go('/property/${properties[index].id}'),
                        isHorizontal: true,
                      ),
                    );
                  }, childCount: properties.length),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Center(child: Text('Failed to load properties')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/app/features/home/presentation/widgets/property_card.dart

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final double? width;
  final bool isHorizontal;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.width,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    }
    return _buildVerticalCard(context);
  }

  Widget _buildVerticalCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: property.imageUrls.first,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        property.type.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Add to favorites
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${property.price.toStringAsFixed(0)}/night',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              property.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: property.imageUrls.first,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.error),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              property.type.displayName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.favorite_border,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.address,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${property.price.toStringAsFixed(0)}/night',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                property.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/app/features/home/presentation/widgets/category_selector.dart

class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(propertyTypeFilterProvider);

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryItem(
            context,
            ref,
            icon: Icons.home_outlined,
            label: 'All',
            type: null,
            isSelected: selectedType == null,
          ),
          _buildCategoryItem(
            context,
            ref,
            icon: Icons.house_outlined,
            label: 'Residence',
            type: PropertyType.residence,
            isSelected: selectedType == PropertyType.residence,
          ),
          _buildCategoryItem(
            context,
            ref,
            icon: Icons.cabin_outlined,
            label: 'Guest House',
            type: PropertyType.guestHouse,
            isSelected: selectedType == PropertyType.guestHouse,
          ),
          _buildCategoryItem(
            context,
            ref,
            icon: Icons.villa_outlined,
            label: 'Villa',
            type: PropertyType.villa,
            isSelected: selectedType == PropertyType.villa,
          ),
          _buildCategoryItem(
            context,
            ref,
            icon: Icons.apartment_outlined,
            label: 'Apartment',
            type: PropertyType.apartment,
            isSelected: selectedType == PropertyType.apartment,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required PropertyType? type,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        ref.read(propertyTypeFilterProvider.notifier).state = type;
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/app/features/home/presentation/widgets/search_bar_widget.dart
class SearchBarWidget extends ConsumerWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search for properties',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.tune,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// lib/app/features/property/presentation/screens/property_details_screen.dart
class PropertyDetailsScreen extends ConsumerWidget {
  final String id;

  const PropertyDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyProvider(id));

    return Scaffold(
      body: propertyAsync.when(
        data: (property) => _buildPropertyDetails(context, property),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load property')),
      ),
      bottomNavigationBar: propertyAsync.maybeWhen(
        data: (property) => _buildBottomBar(context, property),
        orElse: () => null,
      ),
    );
  }

  Widget _buildPropertyDetails(BuildContext context, Property property) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: PropertyImageSlider(images: property.imageUrls),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () {
                    // Add to favorites
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.black),
                  onPressed: () {
                    // Share property
                  },
                ),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      property.type.displayName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${property.rating}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${property.reviewCount} reviews)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                property.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      property.address,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureItem(
                    icon: Icons.single_bed_outlined,
                    value: '${property.bedrooms}',
                    label: 'Bedrooms',
                  ),
                  _buildFeatureItem(
                    icon: Icons.bathtub_outlined,
                    value: '${property.bathrooms}',
                    label: 'Bathrooms',
                  ),
                  _buildFeatureItem(
                    icon: Icons.people_outline,
                    value: '${property.maxGuests}',
                    label: 'Guests',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(property.description, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 24),
              const Text(
                'Amenities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (property.hasWifi)
                    const AmenityItem(icon: Icons.wifi, label: 'WiFi'),
                  if (property.hasParking)
                    const AmenityItem(
                      icon: Icons.local_parking,
                      label: 'Parking',
                    ),
                  if (property.hasAirConditioning)
                    const AmenityItem(icon: Icons.ac_unit, label: 'AC'),
                  if (property.hasKitchen)
                    const AmenityItem(icon: Icons.kitchen, label: 'Kitchen'),
                  ...property.amenities.map(
                    (amenity) => AmenityItem(
                      icon: Icons.check_circle_outline,
                      label: amenity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Host',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const HostInfoCard(),
              const SizedBox(height: 100), // Extra space for bottom bar
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, Property property) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${property.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Text(
                'per night',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                context.go('/booking/${property.id}');
              },
              child: const Text('Book Now'),
            ),
          ),
        ],
      ),
    );
  }
}

// lib/app/features/property/presentation/widgets/property_image_slider.dart

class PropertyImageSlider extends StatefulWidget {
  final List<String> images;

  const PropertyImageSlider({super.key, required this.images});

  @override
  State<PropertyImageSlider> createState() => _PropertyImageSliderState();
}

class _PropertyImageSliderState extends State<PropertyImageSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.images.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.error_outline, size: 40),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: widget.images.length,
              effect: WormEffect(
                dotWidth: 8,
                dotHeight: 8,
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// lib/app/features/property/presentation/widgets/amenity_item.dart

class AmenityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const AmenityItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class HostInfoCard extends StatelessWidget {
  const HostInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              'https://randomuser.me/api/portraits/women/44.jpg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sarah Johnson',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      '4.9',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• Superhost',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Contact host action
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }
}

// lib/app/features/booking/data/booking_repository.dart

class BookingRepository {
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Booking>> getUserBookings() async {
    try {
      /*  final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      } */

      /* final snapshot =
          await _firestore
              .collection('bookings')
              .where('userId', isEqualTo: user.uid)
              .orderBy('checkIn', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => Booking.fromJson(doc.data()..addAll({'id': doc.id})))
          .toList(); */

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Booking> getBooking(String id) async {
    try {
      /*  final doc = await _firestore.collection('bookings').doc(id).get();
      if (!doc.exists) {
        throw Exception('Booking not found');
      }
      return Booking.fromJson(doc.data()!..addAll({'id': id})); */
      return Booking(
        propertyId: 'propertyId',
        userId: 'userId',
        checkIn: DateTime(20025),
        checkOut: DateTime(20225),
        guestCount: 2,
        totalPrice: 232323,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createBooking(Booking booking) async {
    try {
      /* final docRef = await _firestore
          .collection('bookings')
          .add(booking.toJson());
      return docRef.id; */
      return '';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBooking(Booking booking) async {
    try {
      /* await _firestore
          .collection('bookings')
          .doc(booking.id)
          .update(booking.toJson()); */
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      /* await _firestore.collection('bookings').doc(id).update({
        'status': BookingStatus.canceled.toString(),
      }); */
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DateTime>> getUnavailableDates(String propertyId) async {
    try {
      /* final snapshot =
          await _firestore
              .collection('bookings')
              .where('propertyId', isEqualTo: propertyId)
              .where('status', isEqualTo: BookingStatus.confirmed.toString())
              .get(); */

      /* final bookings =
          snapshot.docs
              .map(
                (doc) => Booking.fromJson(doc.data()..addAll({'id': doc.id})),
              )
              .toList();

      final unavailableDates = <DateTime>[];
      for (final booking in bookings) {
        DateTime date = booking.checkIn;
        while (date.isBefore(booking.checkOut)) {
          unavailableDates.add(DateTime(date.year, date.month, date.day));
          date = date.add(const Duration(days: 1));
        }
      }

      return unavailableDates; */
      return [];
    } catch (e) {
      rethrow;
    }
  }
}

// lib/app/features/booking/providers/booking_provider.dart

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

final userBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUserBookings();
});

final bookingProvider = FutureProvider.family<Booking, String>((ref, id) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBooking(id);
});

final unavailableDatesProvider = FutureProvider.family<List<DateTime>, String>((
  ref,
  propertyId,
) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUnavailableDates(propertyId);
});

final selectedDatesProvider = StateProvider<DateTimeRange?>((ref) => null);

final guestCountProvider = StateProvider<int>((ref) => 1);

final bookingPriceProvider = Provider.family<double, String>((ref, propertyId) {
  final propertyAsyncValue = ref.watch(propertyProvider(propertyId));
  final selectedDatesValue = ref.watch(selectedDatesProvider);

  if (propertyAsyncValue.value == null || selectedDatesValue == null) {
    return 0.0;
  }

  final property = propertyAsyncValue.value!;
  final selectedDates = selectedDatesValue;
  final nights = selectedDates.end.difference(selectedDates.start).inDays;

  return property.price * nights;
});

// lib/app/features/booking/presentation/screens/booking_screen.dart

class BookingScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const BookingScreen({super.key, required this.propertyId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialRequestsController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final property = await ref.read(propertyProvider(widget.propertyId).future);
    final selectedDates = ref.read(selectedDatesProvider);
    final guestCount = ref.read(guestCountProvider);
    final totalPrice = ref.read(bookingPriceProvider(widget.propertyId));
    //final currentUser = FirebaseAuth.instance.currentUser;

    // if (selectedDates == null || currentUser == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final booking = Booking(
        propertyId: widget.propertyId,
        userId: '', //currentUser.uid,
        checkIn: DateTime.now(), // selectedDates.start,
        checkOut: DateTime.now(), //selectedDates.end,
        guestCount: guestCount,
        totalPrice: totalPrice,
        specialRequests: _specialRequestsController.text.trim().isNotEmpty
            ? _specialRequestsController.text.trim()
            : null,
      );

      final bookingId = await ref
          .read(bookingRepositoryProvider)
          .createBooking(booking);

      if (mounted) {
        context.go('/booking-confirmation/$bookingId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(propertyProvider(widget.propertyId));
    final unavailableDatesAsync = ref.watch(
      unavailableDatesProvider(widget.propertyId),
    );
    final selectedDates = ref.watch(selectedDatesProvider);
    final guestCount = ref.watch(guestCountProvider);
    final totalPrice = ref.watch(bookingPriceProvider(widget.propertyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Book Your Stay'), elevation: 0),
      body: propertyAsync.when(
        data: (property) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Property summary card
                PropertySummaryCard(property: property),
                const SizedBox(height: 24),

                // Booking details section
                const Text(
                  'Booking Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Date selection
                unavailableDatesAsync.when(
                  data: (unavailableDates) {
                    return DateRangeSelector(
                      unavailableDates: unavailableDates,
                      onChanged: (range) {
                        ref.read(selectedDatesProvider.notifier).state = range;
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Failed to load availability'),
                ),
                const SizedBox(height: 24),

                // Guest count
                Row(
                  children: [
                    const Icon(Icons.people_outline),
                    const SizedBox(width: 8),
                    const Text(
                      'Guests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: guestCount > 1
                          ? () => ref.read(guestCountProvider.notifier).state--
                          : null,
                    ),
                    Text(
                      '$guestCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: guestCount < property.maxGuests
                          ? () => ref.read(guestCountProvider.notifier).state++
                          : null,
                    ),
                  ],
                ),
                Text(
                  'Maximum guests: ${property.maxGuests}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Special requests
                TextFormField(
                  controller: _specialRequestsController,
                  decoration: const InputDecoration(
                    labelText: 'Special Requests (Optional)',
                    hintText:
                        'Let the host know if you have any special requirements',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Price breakdown
                if (selectedDates != null) ...[
                  const Text(
                    'Price Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  PriceBreakdownCard(
                    basePrice: property.price,
                    nights: selectedDates.end
                        .difference(selectedDates.start)
                        .inDays,
                    totalPrice: totalPrice,
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load property')),
      ),
      bottomNavigationBar: propertyAsync.maybeWhen(
        data: (_) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      selectedDates != null
                          ? 'for ${selectedDates.end.difference(selectedDates.start).inDays} nights'
                          : 'Select dates',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedDates != null && !_isProcessing
                        ? _createBooking
                        : null,
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Book Now'),
                  ),
                ),
              ],
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

// First, let's complete the BookingScreen class that was cut off
/* class _BookingScreenState extends ConsumerState<BookingScreen> {
  // ... previous code ...

  @override
  Widget build(BuildContext context) {
    // ... previous build method content ...
    
    bottomNavigationBar: propertyAsync.maybeWhen(
      data: (_) {
        // ... previous content ...
      },
      orElse: () => const SizedBox.shrink(),
    ),
  );
} */

// Now, let's implement the RegisterScreen
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isProcessing = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    //try {
    // Create user with email and password
    /*  final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ); */

    // Create user profile in Firestore
    /* await ref
          .read(userRepositoryProvider)
          .createUserProfile(
            UserProfile(
              id: 'userCredential.user!.uid',
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              createdAt: DateTime.now(),
            ),
          );

      if (mounted) {
        context.go('/home');
      }
    }  */ /* on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage;

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already registered.';
            break;
          case 'weak-password':
            errorMessage =
                'Password is too weak. Please use a stronger password.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address.';
            break;
          default:
            errorMessage = 'Registration failed. ${e.message ?? ""}';
        } */

    /* ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorMessage')));
      } */
    /*  } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    } */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), elevation: 0),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              Text(
                'Join our community',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to start booking your perfect stay',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm password field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Register button
              ElevatedButton(
                onPressed: _isProcessing ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 16),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// BookingConfirmationScreen
class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed'), elevation: 0),
      body: bookingAsync.when(
        data: (booking) {
          // Watch the property data
          final propertyAsync = ref.watch(propertyProvider(booking.propertyId));

          return propertyAsync.when(
            data: (property) {
              final nights = booking.checkOut
                  .difference(booking.checkIn)
                  .inDays;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Success animation/icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.green.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confirmation message
                  Text(
                    'Your booking is confirmed!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Booking #${bookingId.substring(0, 8).toUpperCase()}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Property card
                  Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Property image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image.network(
                            property.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Property details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                property.location!,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Booking details
                  const Text(
                    'Booking Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Check-in info
                  BookingDetailRow(
                    icon: Icons.calendar_today,
                    title: 'Check-in',
                    value: DateFormat(
                      'EEE, MMM d, yyyy',
                    ).format(booking.checkIn),
                  ),

                  // Check-out info
                  BookingDetailRow(
                    icon: Icons.calendar_today,
                    title: 'Check-out',
                    value: DateFormat(
                      'EEE, MMM d, yyyy',
                    ).format(booking.checkOut),
                  ),

                  // Night count
                  BookingDetailRow(
                    icon: Icons.nights_stay,
                    title: 'Duration',
                    value: '$nights night${nights > 1 ? 's' : ''}',
                  ),

                  // Guest count
                  BookingDetailRow(
                    icon: Icons.people_outline,
                    title: 'Guests',
                    value:
                        '${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}',
                  ),

                  // Total price
                  BookingDetailRow(
                    icon: Icons.attach_money,
                    title: 'Total Price',
                    value: '\$${booking.totalPrice.toStringAsFixed(2)}',
                    isLast: true,
                  ),

                  // Special requests (if any)
                  if (booking.specialRequests != null &&
                      booking.specialRequests!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Special Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(booking.specialRequests!),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Add to calendar functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Calendar feature coming soon'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Add to Calendar'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(Icons.home),
                          label: const Text('Go to Home'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Failed to load property details')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Failed to load booking details')),
      ),
    );
  }
}

// Helper widget for the booking confirmation screen
class BookingDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  const BookingDetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ProfileScreen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view your profile'));
    } */

    final userProfileAsync = ref.watch(userProfileProvider('currentUser.uid'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          userProfileAsync.maybeWhen(
            data: (_) => _isEditing
                ? TextButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
                  )
                : IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: userProfileAsync.when(
        data: (userProfile) {
          // Initialize controllers if not already set and we're entering edit mode
          if (_isEditing && _nameController.text.isEmpty) {
            _nameController.text = userProfile.name;
            _phoneController.text = userProfile.phone ?? '';
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile photo section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        userProfile.name.isNotEmpty
                            ? userProfile.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 40,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_isEditing) ...[
                      Text(
                        userProfile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userProfile.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (_isEditing) ...[
                // Edit form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: userProfile.email,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Profile info sections
                _buildInfoSection(
                  title: 'Account Information',
                  items: [
                    _buildInfoItem(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: userProfile.email,
                    ),
                    if (userProfile.phone != null &&
                        userProfile.phone!.isNotEmpty)
                      _buildInfoItem(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        value: userProfile.phone!,
                      ),
                    _buildInfoItem(
                      icon: Icons.calendar_today,
                      title: 'Member Since',
                      value: DateFormat(
                        'MMMM yyyy',
                      ).format(userProfile.createdAt),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Bookings section
                _buildBookingsSection(),

                const SizedBox(height: 32),

                // Account actions
                _buildActionButton(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  onTap: _signOut,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete Account',
                  onTap: _showDeleteAccountConfirmation,
                  isDestructive: true,
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load profile')),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      //final currentUser = FirebaseAuth.instance.currentUser;
      // if (currentUser == null) return;

      final userProfile = await ref.read(
        userProfileProvider('currentUser.uid').future,
      );

      final updatedProfile = userProfile.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      );

      await ref.read(userRepositoryProvider).updateUserProfile(updatedProfile);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      // await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
        );
      }
    }
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _deleteAccount,
            child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      /* final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Delete user profile from Firestore
      await ref.read(userRepositoryProvider).deleteUserProfile(currentUser.uid);

      // Delete user authentication account
      await currentUser.delete(); */

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        context.go('/login');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive ? Colors.red.shade200 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red.shade700 : Colors.grey.shade700,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive
                    ? Colors.red.shade700
                    : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsSection() {
    /*  final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink(); */

    final userBookingsAsync = ref.watch(userBookingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/bookings'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        userBookingsAsync.when(
          data: (bookings) {
            if (bookings.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No bookings yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            // Only show the most recent 2 bookings
            final recentBookings = bookings.take(2).toList();

            return Column(
              children: recentBookings.map((booking) {
                return FutureBuilder<Property>(
                  future: ref.read(propertyProvider(booking.propertyId).future),
                  builder: (context, snapshot) {
                    final property = snapshot.data;
                    final isLoading = !snapshot.hasData;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () =>
                            context.go('/booking-details/${booking.id}'),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Property image or placeholder
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                child: isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          property!.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),

                              // Booking details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isLoading ? 'Loading...' : property!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${DateFormat('MMM d').format(booking.checkIn)} - ${DateFormat('MMM d, yyyy').format(booking.checkOut)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildBookingStatusChip(booking),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Failed to load bookings'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingStatusChip(Booking booking) {
    final now = DateTime.now();
    final isUpcoming = booking.checkIn.isAfter(now);
    final isActive =
        booking.checkIn.isBefore(now) && booking.checkOut.isAfter(now);
    final isPast = booking.checkOut.isBefore(now);

    Color color;
    String label;

    if (isUpcoming) {
      color = Colors.blue;
      label = 'Upcoming';
    } else if (isActive) {
      color = Colors.green;
      label = 'Active';
    } else {
      color = Colors.grey;
      label = 'Completed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Models needed for the implementation
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
  });

  UserProfile copyWith({String? name, String? email, String? phone}) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}
/* 
class Booking {
  final String id;
  final String propertyId;
  final String userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final double totalPrice;
  final String? specialRequests;
  final DateTime createdAt;

  Booking({
    this.id = '',
    required this.propertyId,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.totalPrice,
    this.specialRequests,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class Property {
  final String id;
  final String name;
  final String description;
  final String location;
  final double price;
  final String imageUrl;
  final int maxGuests;
  final List<String> amenities;
  final String hostId;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.maxGuests,
    required this.amenities,
    required this.hostId,
  });
} */

final userProfileProvider = FutureProvider.family<UserProfile, String>((
  ref,
  userId,
) {
  return ref.read(userRepositoryProvider).getUserProfile(userId);
});

/* final userBookingsProvider = FutureProvider.family<List<Booking>, String>((ref, userId) {
  return ref.read(bookingRepositoryProvider).getUserBookings(userId);
}); */

// Providers for state management
/* final selectedDatesProvider = StateProvider<DateTimeRange?>((ref) => null);

final guestCountProvider = StateProvider<int>((ref) => 1);

final bookingPriceProvider = Provider.family<double, String>((ref, propertyId) {
  final propertyAsync = ref.watch(propertyProvider(propertyId));
  final selectedDates = ref.watch(selectedDatesProvider);
  
  if (propertyAsync.value == null || selectedDates == null) {
    return 0.0;
  }
  
  final property = propertyAsync.value!;
  final days = selectedDates.end.difference(selectedDates.start).inDays;
  
  return property.price * days;
});

final propertyProvider = FutureProvider.family<Property, String>((ref, propertyId) {
  return ref.read(propertyRepositoryProvider).getProperty(propertyId);
});

final unavailableDatesProvider = FutureProvider.family<List<DateTime>, String>((ref, propertyId) {
  return ref.read(bookingRepositoryProvider).getUnavailableDates(propertyId);
});

final bookingProvider = FutureProvider.family<Booking, String>((ref, bookingId) {
  return ref.read(bookingRepositoryProvider).getBooking(bookingId);
});





// Repository providers
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return FirebasePropertyRepository();
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return FirebaseBookingRepository();
}); */

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository();
});

// Repository interfaces
/* abstract class PropertyRepository {
  Future<Property> getProperty(String propertyId);
  Future<List<Property>> getFeaturedProperties();
  Future<List<Property>> searchProperties(String query);
}

abstract class BookingRepository {
  Future<String> createBooking(Booking booking);
  Future<Booking> getBooking(String bookingId);
  Future<List<Booking>> getUserBookings(String userId);
  Future<List<DateTime>> getUnavailableDates(String propertyId);
} */

abstract class UserRepository {
  Future<void> createUserProfile(UserProfile userProfile);
  Future<UserProfile> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfile userProfile);
  Future<void> deleteUserProfile(String userId);
}

// Firebase implementations (stubs - to be implemented with actual Firebase code)
/* class FirebasePropertyRepository implements PropertyRepository {
  @override
  Future<Property> getProperty(String propertyId) async {
    // Implementation would use Firestore to fetch property data
    throw UnimplementedError();
  }
  
  @override
  Future<List<Property>> getFeaturedProperties() async {
    // Implementation would use Firestore to fetch featured properties
    throw UnimplementedError();
  }
  
  @override
  Future<List<Property>> searchProperties(String query) async {
    // Implementation would use Firestore to search properties
    throw UnimplementedError();
  }
} */
/* 
class FirebaseBookingRepository implements BookingRepository {
  @override
  Future<String> createBooking(Booking booking) async {
    // Implementation would use Firestore to create a booking
    throw UnimplementedError();
  }
  
  @override
  Future<Booking> getBooking(String bookingId) async {
    // Implementation would use Firestore to fetch booking data
    throw UnimplementedError();
  }
  
  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    // Implementation would use Firestore to fetch user's bookings
    throw UnimplementedError();
  }
  
  @override
  Future<List<DateTime>> getUnavailableDates(String propertyId) async {
    // Implementation would use Firestore to fetch dates that are already booked
    throw UnimplementedError();
  }
} */

class FirebaseUserRepository implements UserRepository {
  @override
  Future<void> createUserProfile(UserProfile userProfile) async {
    // Implementation would use Firestore to create a user profile
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    // Implementation would use Firestore to fetch user profile data
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserProfile(UserProfile userProfile) async {
    // Implementation would use Firestore to update user profile
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    // Implementation would use Firestore to delete user profile
    throw UnimplementedError();
  }
}

// Additional UI components required
class PropertySummaryCard extends StatelessWidget {
  final Property property;

  const PropertySummaryCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                property.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.location!,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${property.price.toStringAsFixed(2)} / night',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateRangeSelector extends StatefulWidget {
  final List<DateTime> unavailableDates;
  final Function(DateTimeRange)? onChanged;

  const DateRangeSelector({
    super.key,
    required this.unavailableDates,
    this.onChanged,
  });

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  DateTimeRange? _selectedRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _selectDateRange,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedRange == null
                        ? 'Select dates'
                        : '${DateFormat('MMM d').format(_selectedRange!.start)} - ${DateFormat('MMM d, yyyy').format(_selectedRange!.end)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_selectedRange != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              '${_selectedRange!.end.difference(_selectedRange!.start).inDays} nights',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dayAfterTomorrow = DateTime(now.year, now.month, now.day + 2);
    final initialRange =
        _selectedRange ?? DateTimeRange(start: tomorrow, end: dayAfterTomorrow);

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
      /* selectableDayPredicate: (day) {
        // Disable dates that are already booked
        return !widget.unavailableDates.any((date) => 
          date.year == day.year && 
          date.month == day.month && 
          date.day == day.day
        );
      }, */
    );

    if (pickedRange != null) {
      setState(() {
        _selectedRange = pickedRange;
      });

      if (widget.onChanged != null) {
        widget.onChanged!(pickedRange);
      }
    }
  }
}

class PriceBreakdownCard extends StatelessWidget {
  final double basePrice;
  final int nights;
  final double totalPrice;

  const PriceBreakdownCard({
    super.key,
    required this.basePrice,
    required this.nights,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPriceRow(
              title: '${basePrice.toStringAsFixed(2)} × $nights nights',
              value: (basePrice * nights).toStringAsFixed(2),
            ),
            const SizedBox(height: 8),
            _buildPriceRow(title: 'Cleaning fee', value: '50.00'),
            const SizedBox(height: 8),
            _buildPriceRow(title: 'Service fee', value: '25.00'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            _buildPriceRow(
              title: 'Total',
              value: totalPrice.toStringAsFixed(2),
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow({
    required String title,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          '\$$value',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
