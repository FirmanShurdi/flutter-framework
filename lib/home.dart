import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import 'main.dart'; // To access AuthProvider and AuthPage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String token = authProvider.token ?? '';
    
    bool isExpired = true;
    Map<String, dynamic> decodedToken = {};
    String tokenStatus = 'Sesi Tidak Valid';
    
    if (token.isNotEmpty) {
      try {
        isExpired = JwtDecoder.isExpired(token);
        decodedToken = JwtDecoder.decode(token);
        if (isExpired) {
          tokenStatus = 'Token Kedaluwarsa';
        } else {
          tokenStatus = 'Token Aktif';
        }
      } catch (e) {
        tokenStatus = 'Format Token Rusak';
      }
    }

    final String name = decodedToken['name'] ?? 'Anonim';
    final String email = decodedToken['email'] ?? '-';
    final String role = decodedToken['role'] ?? 'Tidak punya akses';

    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F7),
      appBar: AppBar(
        title: const Text('Dashboard Utama', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.indigo),
                const SizedBox(height: 24),
                Text(
                  'Halo, $name!',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Akses terverifikasi menggunakan standar murni JSON Web Token.',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: Colors.indigo.shade100, width: 2),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(icon: Icons.badge, label: 'Jabatan (Role)', value: role, isHighlight: true),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()),
                      _DetailRow(icon: Icons.email, label: 'Alamat Email', value: email),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()),
                      _DetailRow(icon: Icons.timer, label: 'Status Sesi', value: tokenStatus, valueColor: isExpired ? Colors.red : Colors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Raw Token (Kriptografi JWT Asli):',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SelectableText(
                    token,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const AuthPage()),
                      );
                    }
                  },
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: const Text('Akhiri Sesi (Log Out)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF0F172A),
    this.isHighlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo.shade400, size: 24),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
        ),
        const Spacer(),
        Container(
          padding: isHighlight ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) : null,
          decoration: isHighlight
              ? BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.indigo.shade700 : valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
