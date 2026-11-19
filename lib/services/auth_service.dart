
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ── KEY SharedPreferences ───────────────────────────────────────
  // KEY INI UNIVERSAL — tidak perlu diganti di project manapun
  // 'logged_in_user' → menyimpan username yang sedang login
  static const String _keyLoggedInUser = 'logged_in_user';

  // 'user_' adalah PREFIX untuk menyimpan password tiap akun
  // Format key: "user_{username}" → value: password
  // Contoh: key="user_rahman", value="12345"
  static const String _prefixUser = 'user_';
  // ───────────────────────────────────────────────────────────────

  // ══════════════════════════════════════════════════════════════
  // FITUR: REGISTER
  // COPY: method ini — UNIVERSAL, langsung tempel tanpa edit
  // ══════════════════════════════════════════════════════════════
  // Mengembalikan null jika berhasil, String pesan error jika gagal
  static Future<String?> register(String username, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Cek apakah username sudah terdaftar
    // Ketentuan: tidak boleh register username yang sama dua kali
    final String? existing = prefs.getString('$_prefixUser$username');
    if (existing != null) {
      return 'Username sudah digunakan, coba yang lain.'; // ← pesan error, boleh ganti teksnya
    }

    // Simpan password dengan key "user_{username}"
    await prefs.setString('$_prefixUser$username', password);
    return null; // null = sukses
  }

  static Future<String?> login(String username, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ambil password tersimpan untuk username ini
    final String? savedPassword = prefs.getString('$_prefixUser$username');

    if (savedPassword == null) {
      return 'Username tidak ditemukan. Silakan Register dahulu.'; // ← ganti teks sesuai selera
    }
    if (savedPassword != password) {
      return 'Password salah. Pastikan sudah Register atau cek password.'; // ← ganti teks sesuai selera
    }

    // ── INI YANG MEMBUAT LOGIN PERSIST ──────────────────────────
    // Simpan username yang sedang login ke SharedPreferences
    // Sehingga meski app ditutup, getLoggedInUser() masih return username ini
    await prefs.setString(_keyLoggedInUser, username);
    // ────────────────────────────────────────────────────────────

    return null; // null = sukses
  }

  // ══════════════════════════════════════════════════════════════
  // FITUR: LOGOUT
  // COPY: method ini — UNIVERSAL, langsung tempel tanpa edit
  // ══════════════════════════════════════════════════════════════
  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedInUser); // hapus status login, data akun tetap ada
  }

  static Future<String?> getLoggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedInUser);
  }
}
