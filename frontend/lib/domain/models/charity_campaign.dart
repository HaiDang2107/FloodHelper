// Domain entity for Charity Campaign
// Represents charity/relief campaigns displayed on charity screens
// Clean domain model - no JSON serialization logic

class CharityCampaign {
  final String id;
  final String? organizedBy;
  final String? checkedBy;
  final String name;
  final String benefactorName;
  final String purpose;
  final String charityObject;
  final CampaignStatus status;
  final BankInfo bankInfo;
  final String? bankStatementFileUrl;
  final DateTime? requestedAt;
  final DateTime? respondedAt;
  final DateTime? createdAt;
  final String? noteByAuthority;
  final DateTime? startedDonationAt;
  final DateTime? finishedDonationAt;
  final DateTime? startedDistributionAt;
  final DateTime? finishedDistributionAt;
  final String reliefLocation;
  final double? latitude;
  final double? longitude;
  final DateRange period;
  final List<CampaignAnnouncement> announcements;
  final List<PurchasedSupply> purchasedSupplies;
  final List<FinancialSupportAllocation> financialSupports;
  final List<Donation> donations;

  const CharityCampaign({
    required this.id,
    this.organizedBy,
    this.checkedBy,
    required this.name,
    required this.benefactorName,
    this.purpose = '',
    this.charityObject = '',
    required this.status,
    required this.bankInfo,
    this.bankStatementFileUrl,
    this.requestedAt,
    this.respondedAt,
    this.createdAt,
    this.noteByAuthority,
    this.startedDonationAt,
    this.finishedDonationAt,
    this.startedDistributionAt,
    this.finishedDistributionAt,
    required this.reliefLocation,
    this.latitude,
    this.longitude,
    required this.period,
    this.announcements = const [],
    this.purchasedSupplies = const [],
    this.financialSupports = const [],
    this.donations = const [],
  });

  /// Calculate total donations
  double get totalDonations {
    return donations.fold(0, (sum, d) => sum + d.amount);
  }

  /// Calculate total spent on supplies
  // double get totalSpent {
  //   return purchasedSupplies.fold(0, (sum, s) => sum + s.totalPrice);
  // }

  /// Remaining funds
  // double get remainingFunds => totalDonations - totalSpent;

  /// Check if campaign is active (can receive donations)
  bool get isActive => status == CampaignStatus.donating;

  /// Check if campaign is finished
  bool get isFinished => status == CampaignStatus.finished;

  /// Get progress percentage (days elapsed)
  // double get progressPercentage {
  //   final totalDays = finishedDistributionAt?.difference(startedDonationAt ?? DateTime.now()).inDays ?? 0;
  //   final elapsedDays = DateTime.now().difference(startedDonationAt ?? DateTime.now()).inDays;
  //   if (totalDays <= 0) return 100;
  //   return (elapsedDays / totalDays * 100).clamp(0, 100);
  // }

  CharityCampaign copyWith({
    String? id,
    String? organizedBy,
    String? checkedBy,
    String? name,
    String? benefactorName,
    String? purpose,
    String? charityObject,
    CampaignStatus? status,
    BankInfo? bankInfo,
    String? bankStatementFileUrl,
    DateTime? requestedAt,
    DateTime? respondedAt,
    DateTime? createdAt,
    String? noteByAuthority,
    DateTime? startedDonationAt,
    DateTime? finishedDonationAt,
    DateTime? startedDistributionAt,
    DateTime? finishedDistributionAt,
    String? reliefLocation,
    double? latitude,
    double? longitude,
    DateRange? period,
    List<CampaignAnnouncement>? announcements,
    List<PurchasedSupply>? purchasedSupplies,
    List<FinancialSupportAllocation>? financialSupports,
    List<Donation>? donations,
  }) {
    return CharityCampaign(
      id: id ?? this.id,
      organizedBy: organizedBy ?? this.organizedBy,
      checkedBy: checkedBy ?? this.checkedBy,
      name: name ?? this.name,
      benefactorName: benefactorName ?? this.benefactorName,
      purpose: purpose ?? this.purpose,
      charityObject: charityObject ?? this.charityObject,
      status: status ?? this.status,
      bankInfo: bankInfo ?? this.bankInfo,
      bankStatementFileUrl: bankStatementFileUrl ?? this.bankStatementFileUrl,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt ?? this.createdAt,
      noteByAuthority: noteByAuthority ?? this.noteByAuthority,
      startedDonationAt: startedDonationAt ?? this.startedDonationAt,
      finishedDonationAt: finishedDonationAt ?? this.finishedDonationAt,
      startedDistributionAt: startedDistributionAt ?? this.startedDistributionAt,
      finishedDistributionAt: finishedDistributionAt ?? this.finishedDistributionAt,
      reliefLocation: reliefLocation ?? this.reliefLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      period: period ?? this.period,
      announcements: announcements ?? this.announcements,
      purchasedSupplies: purchasedSupplies ?? this.purchasedSupplies,
      financialSupports: financialSupports ?? this.financialSupports,
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

  /// Draft created by benefactor
  created,

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
      case CampaignStatus.created:
        return 'Mới tạo';
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
      case 'created':
        return CampaignStatus.created;
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

  const DateRange({required this.startDate, required this.endDate});

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

  DateRange copyWith({DateTime? startDate, DateTime? endDate}) {
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
  final String? supplyId;
  final String productName;
  final String vendor;
  final int quantity;
  final double unitPrice;
  final DateTime? boughtAt;

  const PurchasedSupply({
    this.supplyId,
    required this.productName,
    required this.vendor,
    required this.quantity,
    required this.unitPrice,
    this.boughtAt,
  });

  double get totalPrice => quantity * unitPrice;

  PurchasedSupply copyWith({
    String? supplyId,
    String? productName,
    String? vendor,
    int? quantity,
    double? unitPrice,
    DateTime? boughtAt,
  }) {
    return PurchasedSupply(
      supplyId: supplyId ?? this.supplyId,
      productName: productName ?? this.productName,
      vendor: vendor ?? this.vendor,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      boughtAt: boughtAt ?? this.boughtAt,
    );
  }
}

class FinancialSupportAllocation {
  final String? financialSupportId;
  final String householdName;
  final double amount;
  final DateTime? allocatedAt;

  const FinancialSupportAllocation({
    this.financialSupportId,
    required this.householdName,
    required this.amount,
    this.allocatedAt,
  });

  FinancialSupportAllocation copyWith({
    String? financialSupportId,
    String? householdName,
    double? amount,
    DateTime? allocatedAt,
  }) {
    return FinancialSupportAllocation(
      financialSupportId: financialSupportId ?? this.financialSupportId,
      householdName: householdName ?? this.householdName,
      amount: amount ?? this.amount,
      allocatedAt: allocatedAt ?? this.allocatedAt,
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

class DonateQrResult {
  final String qrLink;
  final String transactionId;

  const DonateQrResult({
    required this.qrLink,
    required this.transactionId,
  });
}

class CharityCampaignLocation {
  final String campaignId;
  final String campaignName;
  final String destination;
  final double latitude;
  final double longitude;

  const CharityCampaignLocation({
    required this.campaignId,
    required this.campaignName,
    required this.destination,
    required this.latitude,
    required this.longitude,
  });
}
