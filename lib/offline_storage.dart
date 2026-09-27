import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineStorage {
  static const String marketRatesKey = 'cached_market_rates';
  static const String recyclersKey = 'cached_recyclers';
  static const String pendingTransactionsKey =
    'pending_transactions';

  // ---------------- MARKET RATES ----------------

  static Future<void> saveMarketRates(
    List<Map<String, dynamic>> rates,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      marketRatesKey,
      jsonEncode(rates),
    );
  }

  static Future<List<Map<String, dynamic>>> getMarketRates() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(marketRatesKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(data);

    return List<Map<String, dynamic>>.from(
      decoded.map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  // ---------------- RECYCLERS ----------------

  static Future<void> saveRecyclers(
    List<Map<String, dynamic>> recyclers,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      recyclersKey,
      jsonEncode(recyclers),
    );
  }

  static Future<List<Map<String, dynamic>>> getRecyclers() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(recyclersKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(data);

    return List<Map<String, dynamic>>.from(
      decoded.map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );
  }
    // ---------------- PENDING TRANSACTIONS ----------------

  static Future<void> savePendingTransaction(
    Map<String, dynamic> transaction,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final existing =
        await getPendingTransactions();

    existing.add(transaction);

    await prefs.setString(
      pendingTransactionsKey,
      jsonEncode(existing),
    );
  }

  static Future<List<Map<String, dynamic>>>
      getPendingTransactions() async {
    final prefs = await SharedPreferences.getInstance();

    final data =
        prefs.getString(pendingTransactionsKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(data);

    return List<Map<String, dynamic>>.from(
      decoded.map(
        (item) =>
            Map<String, dynamic>.from(item),
      ),
    );
  }

  static Future<void> removePendingTransaction(
    String transactionId,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final existing =
        await getPendingTransactions();

    existing.removeWhere(
      (item) =>
          item['transactionId']?.toString() ==
          transactionId,
    );

    await prefs.setString(
      pendingTransactionsKey,
      jsonEncode(existing),
    );
  }
    static Future<void> clearPendingTransactions() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(pendingTransactionsKey);
  }
}