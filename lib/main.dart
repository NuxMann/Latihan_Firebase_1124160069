import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'firebase_options.dart';         
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase
  // Inisialisasi menggunakan opsi yang di-generate sesuai platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //   await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Simple',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Menggunakan StreamBuilder untuk mendeteksi status login
      home: const AuthWrapper(),
    );
  }
}

/// Widget penyaring untuk menentukan halaman mana yang dirender
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Menampilkan loading saat mengecek status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Jika terdapat data user (sudah login), tampilkan halaman info
        if (snapshot.hasData) {
          return UserInfoScreen(user: snapshot.data!);
        }
        // Jika tidak ada data user, tampilkan halaman login
        return const LoginScreen();
      },
    );
  }
}

/// Halaman Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberLogin = true;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Firebase Auth menyimpan status sesi secara persisten secara default.
      // Jika opsi dihapus, langsung keluarkan sesi setelah autentikasi berhasil.
      if (!_rememberLogin && credential.user != null) {
        await FirebaseAuth.instance.signOut();
      }
      // Jika berhasil, AuthWrapper otomatis mendeteksi perubahan stream
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Terjadi kesalahan saat login.';
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
      backgroundColor: const Color(0xFFF5F7FB),
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginIllustration()),
          SafeArea(
            child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.lock_person_rounded, size: 38, color: Color(0xFF356AE6)),
                  ),
                  const SizedBox(height: 32),
                  const Text('Selamat datang', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF17233C))),
                  const SizedBox(height: 8),
                  Text('Masuk untuk melanjutkan ke akun Anda.', style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade600)),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 8,
                    shadowColor: const Color(0x1A17233C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                              child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700), textAlign: TextAlign.center),
                            ),
                            const SizedBox(height: 18),
                          ],
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: const Color(0xFFF7F9FC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            onSubmitted: (_) => _isLoading ? null : _login(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              filled: true,
                              fillColor: const Color(0xFFF7F9FC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 6),
                          CheckboxListTile(
                            value: _rememberLogin,
                            onChanged: _isLoading
                                ? null
                                : (value) => setState(() => _rememberLogin = value ?? false),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Ingat saya', style: TextStyle(fontSize: 14)),
                            subtitle: const Text('Tetap masuk di perangkat ini', style: TextStyle(fontSize: 12)),
                            activeColor: const Color(0xFF356AE6),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF356AE6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Aman dan mudah dengan Firebase', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13)),
                ],
              ),
            ),
          ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginIllustration extends StatefulWidget {
  const _LoginIllustration();

  @override
  State<_LoginIllustration> createState() => _LoginIllustrationState();
}

class _LoginIllustrationState extends State<_LoginIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final lift = math.sin(_controller.value * math.pi) * 14;
        return Stack(
          children: [
            Positioned(
              top: -110 + lift,
              right: -95,
              child: _blob(300, const Color(0xFFDCE8FF)),
            ),
            Positioned(
              bottom: -150 - lift,
              left: -100,
              child: _blob(340, const Color(0xFFE4F3F4)),
            ),
            Positioned(
              top: 105 + lift,
              right: 38,
              child: Icon(Icons.auto_awesome, size: 28, color: Colors.blue.shade200),
            ),
            Positioned(
              bottom: 110 + lift,
              right: 58,
              child: Icon(Icons.circle, size: 12, color: Colors.teal.shade200),
            ),
          ],
        );
      },
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Halaman Informasi User
class UserInfoScreen extends StatelessWidget {
  final User user;

  const UserInfoScreen({Key? key, required this.user}) : super(key: key);

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 58,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null || user.photoURL!.isEmpty
                    ? const Icon(Icons.person, size: 64, color: Colors.blue)
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Login Berhasil!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              _LedNameDisplay(
                name: user.displayName?.isNotEmpty == true
                    ? user.displayName!
                    : 'Pengguna Firebase',
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shadowColor: Colors.blue.withOpacity(0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email ?? 'Tidak ada email'),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: user.emailVerified ? Icons.verified_outlined : Icons.info_outline,
                        label: 'Status email',
                        value: user.emailVerified ? 'Terverifikasi' : 'Belum terverifikasi',
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: 'Terakhir login',
                        value: user.metadata.lastSignInTime?.toLocal().toString() ?? '-',
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

class _LedNameDisplay extends StatefulWidget {
  final String name;

  const _LedNameDisplay({required this.name});

  @override
  State<_LedNameDisplay> createState() => _LedNameDisplayState();
}

class _LedNameDisplayState extends State<_LedNameDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.name.length * 180).clamp(2200, 9000)),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ledColors = [
      Color(0xFFFF4D6D), // merah
      Color(0xFFFFB84D), // jingga
      Color(0xFFFFFF5C), // kuning
      Color(0xFF62FF8E), // hijau
      Color(0xFF55E7FF), // biru muda
      Color(0xFF6790FF), // biru
      Color(0xFFD66BFF), // ungu
    ];

    return Container(
      height: 54,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF080D0A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF26352B)),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _LedGridPainter()),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => LayoutBuilder(
              builder: (context, constraints) {
                // Tambahkan ruang untuk huruf lebar dan letter spacing agar
                // karakter terakhir tidak terpotong pada nama yang panjang.
                final textWidth = (widget.name.length * 16.0 + 36).clamp(190.0, 700.0);
                final x = constraints.maxWidth -
                    _controller.value * (constraints.maxWidth + textWidth);
                return Transform.translate(
                  offset: Offset(x, 0),
                  child: SizedBox(
                    width: textWidth,
                    height: constraints.maxHeight,
                    child: Center(
                      child: Text(
                        widget.name.toUpperCase(),
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: ledColors,
                            ).createShader(const Rect.fromLTWH(0, 0, 700, 54)),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          fontFamily: 'monospace',
                          shadows: const [
                            Shadow(color: Color(0xFF62FF8E), blurRadius: 8),
                            Shadow(color: Color(0xFF55E7FF), blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x1F68FF8A);
    const spacing = 7.0;
    for (double y = 4; y < size.height; y += spacing) {
      for (double x = 4; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
