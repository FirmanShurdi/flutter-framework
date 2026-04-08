import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/preference_provider.dart';
import '../../providers/data_provider.dart';
import 'auth_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final prefProvider = Provider.of<PreferenceProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    
    final String token = authProvider.token ?? '';
    Map<String, dynamic> decodedToken = {};
    if (token.isNotEmpty) {
      try {
        decodedToken = JwtDecoder.decode(token);
      } catch (_) {}
    }

    final String name = prefProvider.userName;
    final String role = decodedToken['role'] ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Utama'),
        actions: [
          IconButton(
            icon: Icon(prefProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => prefProvider.toggleDarkMode(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await authProvider.logout();
              if (mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, $name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(role, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Profile Settings Section
            const Text('Preferensi Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Ubah Nama Panggilan'),
                subtitle: Text('Saat ini: $name'),
                onTap: () => _showNameDialog(context, prefProvider),
              ),
            ),
            const SizedBox(height: 32),

            // Data Section with Caching
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Statistik Parkir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildSourceBadge(dataProvider.dataSource),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataCard(dataProvider),
            const SizedBox(height: 16),
            
            // Simulation Controls
            const Divider(),
            SwitchListTile(
              title: const Text('Simulasi Jaringan Terputus'),
              subtitle: const Text('Gunakan data cache jika diaktifkan'),
              value: dataProvider.simulateError,
              onChanged: (_) => dataProvider.toggleSimulateError(),
            ),
            ElevatedButton.icon(
              onPressed: dataProvider.isLoading ? null : () => dataProvider.refreshData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Segarkan Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceBadge(String source) {
    Color color = Colors.grey;
    if (source == 'Online Data') color = Colors.green;
    if (source == 'Cached Data') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        source,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildDataCard(DataProvider provider) {
    if (provider.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final data = provider.parkingData;
    if (data == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('Tidak ada data tersedia')),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _dataRow('Total Slot', data['total_slots'].toString()),
            const Divider(),
            _dataRow('Tersedia', data['available_slots'].toString(), color: Colors.green),
            const Divider(),
            _dataRow('Terpakai', data['occupied_slots'].toString(), color: Colors.red),
            const SizedBox(height: 12),
            Text('Pembaruan terakhir: ${data['last_update'].toString().substring(11, 16)}', 
                 style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _dataRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showNameDialog(BuildContext context, PreferenceProvider pref) {
    final controller = TextEditingController(text: pref.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Masukkan nama baru')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              pref.updateUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
