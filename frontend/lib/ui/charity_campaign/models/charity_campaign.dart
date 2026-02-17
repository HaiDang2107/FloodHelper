enum CampaignStatus {
  pending,
  accepted,
  rejected,
  donating,
  distributing,
  finished,
}

class CampaignAnnouncement {
  final String text;
  final String? imageUrl;
  final DateTime date;

  CampaignAnnouncement({
    required this.text,
    this.imageUrl,
    required this.date,
  });
}

class PurchasedSupply {
  final String productName;
  final String buyAt;
  final int quantity;
  final double unitPrice;
  double get totalPrice => quantity * unitPrice;

  PurchasedSupply({
    required this.productName,
    required this.buyAt,
    required this.quantity,
    required this.unitPrice,
  });
}

class Transaction {
  final double amount;
  final String name;
  final DateTime date;

  Transaction(
      {required this.amount, required this.name, required this.date});
}

class CharityCampaign {
  final String id;
  final String name;
  final String benefactorName;
  final CampaignStatus status;
  final String bankAccountNumber;
  final String bankName;
  final String reliefLocation;
  final DateTime startDate;
  final DateTime endDate;
  final List<CampaignAnnouncement> announcements; // Mutable for demo
  final List<PurchasedSupply> purchasedSupplies;
  final List<Transaction> transactions;

  CharityCampaign({
    required this.id,
    required this.name,
    required this.benefactorName,
    required this.status,
    required this.bankAccountNumber,
    required this.bankName,
    required this.reliefLocation,
    required this.startDate,
    required this.endDate,
    List<CampaignAnnouncement>? announcements,
    this.purchasedSupplies = const [],
    this.transactions = const [],
  }) : announcements = announcements ?? const [];
}
