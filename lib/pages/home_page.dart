import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';   // ← EDIT: path ke LoginPage
import 'list_page.dart';    // ← EDIT: path ke ListPage
import 'favorite_page.dart'; // ← EDIT: path ke FavoritePage

class HomePage extends StatelessWidget {
  // username diterima dari LoginPage setelah login berhasil
  // Ditampilkan di AppBar: "Hai, {username}!"
  // ← EDIT: nama parameter ini harus sama dengan yang dikirim dari LoginPage
  final String username;
  const HomePage({super.key, required this.username});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout(); // hapus sesi dari SharedPreferences

    if (!context.mounted) return;
    // pushAndRemoveUntil → hapus semua route di stack
    // Sehingga tombol back tidak bisa kembali ke HomePage setelah logout
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()), // ← EDIT: nama class
      (route) => false,
    );
  }
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ── FITUR: TAMPILKAN USERNAME DI APPBAR ───────────────
        // COPY: title ini — UNIVERSAL
        // EDIT: ganti 'username' dengan nama variabel username kamu
        title: Text('Hai, $username!'), // ← EDIT: format teks boleh diganti
        // ──────────────────────────────────────────────────────
        backgroundColor: const Color(0xFF4CAF50), // ← EDIT: warna AppBar
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // Tombol Favourite di AppBar kanan (opsional, boleh dihapus)
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritePage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── FITUR: DAFTAR MENU (News, Blog, Reports) ───────
            // COPY: Expanded + ListView ini
            // EDIT: tambah/kurang _buildMenuCard sesuai menu yang dibutuhkan
            //       Ganti 'type' dengan identifier menu kamu
            Expanded(
              child: ListView(
                children: [
                  // ── KARTU MENU 1 (terhubung ke ApiConfig.urls['news']) ──
                  _buildMenuCard(
                    context,
                    icon: Icons.newspaper,
                    title: 'Resep Masakan', // ← BOLEH EDIT (opsional): ubah nama menu sesuai API 1
                    subtitle: 'Cari tahu resep masakan terbaru.', // ← BOLEH EDIT (opsional)
                    type: 'news', // ← JANGAN DIUBAH (harus sama dengan key di ApiConfig.urls)
                  ),
                  const SizedBox(height: 12),

                  // ── KARTU MENU 2 (terhubung ke ApiConfig.urls['blogs']) ──
                 

                  // ── KARTU MENU 3 (terhubung ke ApiConfig.urls['reports']) ──
                  // CATATAN: Jika cuma pakai 2 API, hapus atau beri komentar (//) blok di bawah ini
                 
                ],
              ),
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,     // ← merah untuk logout
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Log Out', style: TextStyle(fontSize: 16)), // ← EDIT: teks
              ),
            ),
            const SizedBox(height: 8),
            // ══════════════════════════════════════════════════
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String type, // dikirim ke ListPage agar tahu endpoint mana yang dipanggil
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF4CAF50), size: 28), // ← EDIT: warna ikon
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        // Saat diklik → ke ListPage dengan type yang sesuai
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListPage(type: type), // ← EDIT: nama class ListPage
          ),
        ),
      ),
    );
  }
}
