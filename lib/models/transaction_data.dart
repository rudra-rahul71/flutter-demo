class TransactionData {

  final dynamic accounts;
  final List<dynamic> transactions;
  final dynamic item;
  final dynamic totalTransactions;

  TransactionData({
    required this.accounts,
    required this.transactions,
    required this.item,
    required this.totalTransactions,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      accounts: json['accounts'],
      transactions: json['transactions'],
      item: json['item'],
      totalTransactions: json['total_transactions'],
    );
  }
}