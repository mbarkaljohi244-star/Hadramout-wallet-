class UserSession {
  const UserSession({
    required this.accessToken,
    required this.userId,
    required this.walletId,
    this.name,
    this.email,
  });

  final String accessToken;
  final String userId;
  final String walletId;
  final String? name;
  final String? email;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      accessToken: json['accessToken'] as String,
      userId: json['userId'] as String,
      walletId: json['walletId'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }
}

class TransferResult {
  const TransferResult({
    required this.transferId,
    required this.senderWalletId,
    required this.receiverWalletId,
    required this.amount,
    required this.currency,
    required this.senderBalance,
    required this.receiverBalance,
    required this.transferredAt,
  });

  final String transferId;
  final String senderWalletId;
  final String receiverWalletId;
  final double amount;
  final String currency;
  final double senderBalance;
  final double receiverBalance;
  final DateTime transferredAt;

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      transferId: json['transferId'] as String,
      senderWalletId: json['senderWalletId'] as String,
      receiverWalletId: json['receiverWalletId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      senderBalance: (json['senderBalance'] as num).toDouble(),
      receiverBalance: (json['receiverBalance'] as num).toDouble(),
      transferredAt: DateTime.parse(json['transferredAt'] as String),
    );
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
