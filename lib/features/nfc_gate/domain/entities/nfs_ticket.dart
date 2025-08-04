class NfcTicket {
  final String tokenId;
  final String tokenValue;
  String bookingId;
  String userId;
  final DateTime tokenValidFrom;
  final DateTime tokenValidTo;
  bool isUsed;

  NfcTicket({
    required this.tokenId,
    required this.tokenValue,
    required this.bookingId,
    required this.userId,
    required this.tokenValidFrom,
    required this.tokenValidTo,
    this.isUsed = false,
  });

  factory NfcTicket.fromJson(Map<String, dynamic> json) {
    return NfcTicket(
      tokenId: json['tokenId'] as String,
      tokenValue: json['tokenValue'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      tokenValidFrom: DateTime.parse(json['tokenValidFrom'] as String),
      tokenValidTo: DateTime.parse(json['tokenValidTo'] as String),
      isUsed: json['isUsed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': tokenId,
      'token': tokenValue,
      'bookingId': bookingId,
      'userId': userId,
      'validFrom': tokenValidFrom.toIso8601String(),
      'validTo': tokenValidTo.toIso8601String(),
      'isUsed': isUsed,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(tokenValidFrom) && now.isBefore(tokenValidTo) && !isUsed;
  }

  void markAsUsed() => isUsed = true;
}
