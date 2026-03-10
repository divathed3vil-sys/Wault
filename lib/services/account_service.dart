// lib/services/account_service.dart
// CRUD for Account objects persisted in SharedPreferences as a JSON list.
// Also handles process slot assignment (0-4) and accent color cycling.

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../utils/constants.dart';

class AccountService {
  static const _uuid = Uuid();

  // ── Read ─────────────────────────────────────────────────────────────────

  static Future<List<Account>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(WaultConstants.prefAccountsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Account.listFromJson(raw);
    } catch (_) {
      return [];
    }
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  static Future<List<Account>> _saveAccounts(List<Account> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        WaultConstants.prefAccountsKey, Account.listToJson(accounts));
    return accounts;
  }

  // ── Create ────────────────────────────────────────────────────────────────

  /// Creates a new account with the given label.
  /// Returns the updated list of accounts, or null if the vault is full.
  static Future<Account?> createAccount(String label) async {
    final existing = await loadAccounts();
    if (existing.length >= WaultConstants.maxAccounts) return null;

    // Find the next available process slot (0-4 not yet used)
    final usedSlots = existing.map((a) => a.processSlot).toSet();
    int slot = -1;
    for (int i = 0; i < WaultConstants.maxAccounts; i++) {
      if (!usedSlots.contains(i)) {
        slot = i;
        break;
      }
    }
    if (slot == -1) return null; // should not happen if maxAccounts is 5

    // Assign accent color by cycling through palette
    final colorIndex = existing.length % WaultConstants.accentPalette.length;
    final accentColor = WaultConstants.accentPalette[colorIndex];

    final account = Account(
      id: _uuid.v4(),
      label: label.trim(),
      accentColorHex: accentColor,
      processSlot: slot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    existing.add(account);
    await _saveAccounts(existing);
    return account;
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  static Future<List<Account>> deleteAccount(String id) async {
    final existing = await loadAccounts();
    existing.removeWhere((a) => a.id == id);
    return _saveAccounts(existing);
  }
}
