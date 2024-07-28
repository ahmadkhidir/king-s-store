enum Status { initial, loading, loaded, error }

class TransactionModel {
  final String url, accessCode, reference;

  TransactionModel({
    required this.url,
    required this.accessCode,
    required this.reference,
  });
}
