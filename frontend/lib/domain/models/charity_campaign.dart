/// Domain entity for Charity Campaign
/// Represents charity/relief campaigns displayed on charity screens
/// Clean domain model - no JSON serialization logic

class CharityCampaign {
  final String id;
  final String name;
  final String benefactorName;
  final CampaignStatus status;
  final BankInfo bankInfo;
  final String reliefLocation;
  final DateRange period;
  final List<CampaignAnnouncement> announcements;
  final List<PurchasedSupply> purchasedSupplies;
  final List<Donation> donations;

  const CharityCampaign({
    required this.id,
    required this.name,
    required this.benefactorName,
    required this.status,
    required this.bankInfo,
    required this.reliefLocation,
    required this.period,
    this.announcements = const [],
    this.purchasedSupplies = const [],
    this.donations = const [],
  });

  /// Calculate total donations
  double get totalDonations {
    return donations.fold(0, (sum, d) => sum + d.amount);
  }

  /// Calculate total spent on supplies
  double get totalSpent {
    return purchasedSupplies.fold(0, (sum, s) => sum + s.totalPrice);
  }

  /// Remaining funds
  double get remainingFunds => totalDonations - totalSpent;

  /// Check if campaign is active (can receive donations)
  bool get isActive => status == CampaignStatus.donating;

  /// Check if campaign is finished
  bool get isFinished => status == CampaignStatus.finished;

  /// Get progress percentage (days elapsed)
  double get progressPercentage {
    final totalDays = period.endDate.difference(period.startDate).inDays;
    final elapsedDays = DateTime.now().difference(period.startDate).inDays;
    if (totalDays <= 0) return 100;
    return (elapsedDays / totalDays * 100).clamp(0, 100);
  }

  CharityCampaign copyWith({
    String? id,
    String? name,
    String? benefactorName,
    CampaignStatus? status,
    BankInfo? bankInfo,
    String? reliefLocation,
    DateRange? period,
    List<CampaignAnnouncement>? announcements,
    List<PurchasedSupply>? purchasedSupplies,
    List<Donation>? donations,
  }) {
    return CharityCampaign(
      id: id ?? this.id,
      name: name ?? this.name,
      benefactorName: benefactorName ?? this.benefactorName,
      status: status ?? this.status,
      bankInfo: bankInfo ?? this.bankInfo,
      reliefLocation: reliefLocation ?? this.reliefLocation,
      period: period ?? this.period,
      announcements: announcements ?? this.announcements,
      purchasedSupplies: purchasedSupplies ?? this.purchasedSupplies,
      donations: donations ?? this.donations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CharityCampaign && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Campaign status enum
enum CampaignStatus {
  /// Waiting for approval
  pending,
  
  /// Approved, ready to start
  approved,
  
  /// Rejected by admin
  rejected,
  
  /// Currently accepting donations
  donating,
  
  /// Distributing relief supplies
  distributing,
  
  /// Campaign completed
  finished;

  String get displayName {
    switch (this) {
      case CampaignStatus.pending:
        return 'Chờ duyệt';
      case CampaignStatus.approved:
        return 'Đã duyệt';
      case CampaignStatus.rejected:
        return 'Từ chối';
      case CampaignStatus.donating:
        return 'Đang quyên góp';
      case CampaignStatus.distributing:
        return 'Đang phát hàng';
      case CampaignStatus.finished:
        return 'Hoàn thành';
    }
  }

  static CampaignStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return CampaignStatus.pending;
      case 'approved':
      case 'accepted':
        return CampaignStatus.approved;
      case 'rejected':
        return CampaignStatus.rejected;
      case 'donating':
        return CampaignStatus.donating;
      case 'distributing':
        return CampaignStatus.distributing;
      case 'finished':
        return CampaignStatus.finished;
      default:
        return CampaignStatus.pending;
    }
  }
}

/// Value object for bank information
class BankInfo {
  final String accountNumber;
  final String bankName;
  final String? accountHolder;

  const BankInfo({
    required this.accountNumber,
    required this.bankName,
    this.accountHolder,
  });

  /// Masked account number for display
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }

  BankInfo copyWith({
    String? accountNumber,
    String? bankName,
    String? accountHolder,
  }) {
    return BankInfo(
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      accountHolder: accountHolder ?? this.accountHolder,
    );
  }
}

/// Value object for date range
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  /// Duration in days
  int get durationDays => endDate.difference(startDate).inDays;

  /// Check if currently within range
  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Days remaining
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRange(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Value object for campaign announcements
class CampaignAnnouncement {
  final String text;
  final String? imageUrl;
  final DateTime date;

  const CampaignAnnouncement({
    required this.text,
    this.imageUrl,
    required this.date,
  });

  CampaignAnnouncement copyWith({
    String? text,
    String? imageUrl,
    DateTime? date,
  }) {
    return CampaignAnnouncement(
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
    );
  }
}

/// Value object for purchased supplies
class PurchasedSupply {
  final String productName;
  final String vendor;
  final int quantity;
  final double unitPrice;

  const PurchasedSupply({
    required this.productName,
    required this.vendor,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  PurchasedSupply copyWith({
    String? productName,
    String? vendor,
    int? quantity,
    double? unitPrice,
  }) {
    return PurchasedSupply(
      productName: productName ?? this.productName,
      vendor: vendor ?? this.vendor,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

/// Value object for donations
class Donation {
  final double amount;
  final String donorName;
  final DateTime date;
  final String? message;

  const Donation({
    required this.amount,
    required this.donorName,
    required this.date,
    this.message,
  });

  Donation copyWith({
    double? amount,
    String? donorName,
    DateTime? date,
    String? message,
  }) {
    return Donation(
      amount: amount ?? this.amount,
      donorName: donorName ?? this.donorName,
      date: date ?? this.date,
      message: message ?? this.message,
    );
  }
}
