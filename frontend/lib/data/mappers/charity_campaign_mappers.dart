import '../../domain/models/charity_campaign.dart';

class CharityCampaignMappers {
  static List<CharityCampaign> parseAndDeduplicateCampaigns(
    List<List<Map<String, dynamic>>> batches,
  ) {
    final merged = <String, CharityCampaign>{};

    for (final batch in batches) {
      for (final item in batch) {
        final campaign = campaignFromApi(item);
        merged[campaign.id] = campaign;
      }
    }

    final campaigns = merged.values.toList(growable: false);
    return campaigns;
  }

  static CharityCampaign campaignFromApi(Map<String, dynamic> json) {
    final periodJson = json['period'] as Map<String, dynamic>?;
    final bankInfoJson = json['bankInfo'] as Map<String, dynamic>?;

    final startDate = _parseDate(
      periodJson?['startDate'] ??
          json['startedDonationAt'] ??
          json['startedDistributionAt'] ??
          json['createdAt'],
    );
    final endDate = _parseDate(
      periodJson?['endDate'] ??
          json['finishedDistributionAt'] ??
          json['finishedDonationAt'] ??
          periodJson?['startDate'] ??
          json['createdAt'],
    );

    return CharityCampaign(
      id: (json['id'] ?? json['campaignId'] ?? '').toString(),
      organizedBy: _nullableString(json['organizedBy']),
      checkedBy: _nullableString(json['checkedBy']),
      name: (json['name'] ?? json['campaignName'] ?? 'Unnamed campaign')
          .toString(),
      benefactorName:
          (json['benefactorName'] ?? json['organizerName'] ?? 'Unknown')
              .toString(),
      purpose: (json['purpose'] ?? '').toString(),
      charityObject: (json['charityObject'] ?? '').toString(),
      status: CampaignStatus.fromString(
        (json['state'] ?? json['status'] ?? '').toString(),
      ),
      bankInfo: BankInfo(
        accountNumber:
            (bankInfoJson?['accountNumber'] ?? json['bankAccountNumber'] ?? '')
                .toString(),
        bankName: (bankInfoJson?['bankName'] ?? json['bankName'] ?? '')
            .toString(),
        accountHolder: _nullableString(
          bankInfoJson?['accountHolder'] ?? json['bankAccountName'],
        ),
      ),
      bankStatementFileUrl: _nullableString(json['bankStatementFileUrl']),
      requestedAt: _parseOptionalDate(json['requestedAt']),
      respondedAt: _parseOptionalDate(json['respondedAt']),
      createdAt: _parseOptionalDate(json['createdAt']),
      noteByAuthority: _nullableString(json['noteByAuthority']),
      startedDonationAt: _parseOptionalDate(json['startedDonationAt']),
      finishedDonationAt: _parseOptionalDate(json['finishedDonationAt']),
      startedDistributionAt: _parseOptionalDate(json['startedDistributionAt']),
      finishedDistributionAt: _parseOptionalDate(json['finishedDistributionAt']),
      reliefLocation: (json['reliefLocation'] ?? json['destination'] ?? '')
          .toString(),
      period: DateRange(startDate: startDate, endDate: endDate),
      announcements: _parseAnnouncements(json['announcements']),
      purchasedSupplies: _parseSupplies(json['purchasedSupplies']),
      donations: _parseDonations(json['donations']),
    );
  }

  static List<Donation> donationsFromApiList(List<Map<String, dynamic>> items) {
    return _parseDonations(items);
  }

  static Map<String, dynamic> mutationPayloadFromCampaign(
    CharityCampaign campaign,
  ) {
    return {
      'campaignName': campaign.name,
      'purpose': campaign.purpose,
      'destination': campaign.reliefLocation,
      'charityObject': campaign.charityObject,
      'bankAccountNumber': campaign.bankInfo.accountNumber,
      'bankName': campaign.bankInfo.bankName,
      'bankAccountName': campaign.bankInfo.accountHolder,
      'bankStatementFileUrl': campaign.bankStatementFileUrl,
      'startedDonationAt': campaign.startedDonationAt?.toIso8601String(),
      'finishedDonationAt': campaign.finishedDonationAt?.toIso8601String(),
      'startedDistributionAt': campaign.startedDistributionAt?.toIso8601String(),
      'finishedDistributionAt': campaign.finishedDistributionAt?.toIso8601String(),
    };
  }

  static List<CampaignAnnouncement> _parseAnnouncements(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(
          (item) => CampaignAnnouncement(
            text: (item['text'] ?? item['textContent'] ?? item['content'] ?? '')
                .toString(),
            imageUrl: _nullableString(item['imageUrl']),
            date: _parseDate(item['date'] ?? item['createdAt']),
          ),
        )
        .toList(growable: false);
  }

  static List<PurchasedSupply> _parseSupplies(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(
          (item) => PurchasedSupply(
            productName: (item['productName'] ?? item['supplyName'] ?? '')
                .toString(),
            vendor: (item['vendor'] ?? item['supplier'] ?? '').toString(),
            quantity: _parseInt(item['quantity']),
            unitPrice: _parseDouble(item['unitPrice']),
          ),
        )
        .toList(growable: false);
  }

  static List<Donation> _parseDonations(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(
          (item) => Donation(
            amount: _parseDouble(item['amount'] ?? item['transferAmount']),
            donorName: (item['donorName'] ?? item['transferBy'] ?? 'Anonymous')
                .toString(),
            date: _parseDate(item['date'] ?? item['donateAt']),
            message: _nullableString(item['message']),
          ),
        )
        .toList(growable: false);
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.now();
  }

  static DateTime? _parseOptionalDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return _parseDate(value);
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nullableString(dynamic value) {
    final stringValue = value?.toString();
    if (stringValue == null || stringValue.trim().isEmpty) {
      return null;
    }
    return stringValue;
  }
}