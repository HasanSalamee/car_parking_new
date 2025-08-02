class NfcTicket {
  final String id;
  final String token;
  final String bookingId;
  final String userId;
  final DateTime validFrom;
  final DateTime validTo;
  bool isUsed;

  NfcTicket({
    required this.id,
    required this.token,
    required this.bookingId,
    required this.userId,
    required this.validFrom,
    required this.validTo,
    this.isUsed = false,
  });

  factory NfcTicket.fromJson(Map<String, dynamic> json) {
    return NfcTicket(
      id: json['id'] as String,
      token: json['token'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: DateTime.parse(json['validTo'] as String),
      isUsed: json['isUsed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'bookingId': bookingId,
      'userId': userId,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'isUsed': isUsed,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validTo) && !isUsed;
  }

  void markAsUsed() => isUsed = true;
}
