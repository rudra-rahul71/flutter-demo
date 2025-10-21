// 1. Define a class to hold the response data
class TransactionData {
  // Use final properties for immutable data
  final dynamic accounts;
  final dynamic transactions;
  final dynamic item;
  final dynamic totalTransactions; // Using camelCase for Dart fields

  // Standard constructor
  TransactionData({
    required this.accounts,
    required this.transactions,
    required this.item,
    required this.totalTransactions,
  });

  // 2. Add a factory constructor to parse from JSON
  // This maps your JSON keys (snake_case) to your class fields (camelCase)
  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      accounts: json['accounts'],
      transactions: json['transactions'],
      item: json['item'],
      totalTransactions: json['total_transactions'], // Maps from the JSON key
    );
  }
}