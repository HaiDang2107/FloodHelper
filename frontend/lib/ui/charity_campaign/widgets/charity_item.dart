import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/common/widgets/bottom_sheet.dart';
import '../../../domain/models/charity_campaign.dart';
import 'bottom_sheet/allocation_view.dart';
import 'bottom_sheet/transaction_list_view.dart';
import 'bottom_sheet/detail_view/detail_view.dart';

// Defines the views inside the bottom sheet
enum _SheetView { details, supplies, transactions }

class CharityItem extends StatelessWidget {
  final CharityCampaign campaign;
  final bool isOwner;
  final Future<CharityCampaign> Function(String campaignId)? onLoadCampaignDetail;
  final Future<List<Donation>> Function(String campaignId)? onLoadCampaignTransactions;
  final Future<void> Function(String campaignId, String text)? onPostAnnouncement;
  final Future<void> Function(CharityCampaign campaign)? onUpdateCampaign;
  final Future<void> Function(String campaignId)? onSendCampaignRequest;
  final Future<void> Function(
    String campaignId,
    double latitude,
    double longitude,
  )?
  onFocusCampaignLocation;
  final Future<void> Function(
    String campaignId,
    double latitude,
    double longitude,
  )?
  onCheckInLocation;

  const CharityItem({
    super.key,
    required this.campaign,
    this.isOwner = false,
    this.onLoadCampaignDetail,
    this.onLoadCampaignTransactions,
    this.onPostAnnouncement,
    this.onUpdateCampaign,
    this.onSendCampaignRequest,
    this.onFocusCampaignLocation,
    this.onCheckInLocation,
  });

  Future<void> _showDetailsBottomSheet(BuildContext context) async {
    await CharityItem.showDetailsBottomSheet(
      context,
      campaign: campaign,
      isOwner: isOwner,
      onLoadCampaignDetail: onLoadCampaignDetail,
      onLoadCampaignTransactions: onLoadCampaignTransactions,
      onPostAnnouncement: onPostAnnouncement,
      onUpdateCampaign: onUpdateCampaign,
      onSendCampaignRequest: onSendCampaignRequest,
      onFocusCampaignLocation: onFocusCampaignLocation,
      onCheckInLocation: onCheckInLocation,
    );
  }

  static Future<void> showDetailsBottomSheet(
    BuildContext context, {
    required CharityCampaign campaign,
    bool isOwner = false,
    Future<CharityCampaign> Function(String campaignId)? onLoadCampaignDetail,
    Future<List<Donation>> Function(String campaignId)? onLoadCampaignTransactions,
    Future<void> Function(String campaignId, String text)? onPostAnnouncement,
    Future<void> Function(CharityCampaign campaign)? onUpdateCampaign,
    Future<void> Function(String campaignId)? onSendCampaignRequest,
    Future<void> Function(
      String campaignId,
      double latitude,
      double longitude,
    )?
    onFocusCampaignLocation,
    Future<void> Function(
      String campaignId,
      double latitude,
      double longitude,
    )?
    onCheckInLocation,
  }) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(rootNavigator.context);
    final loadCampaignDetail = onLoadCampaignDetail;
    final mediaQuery = MediaQuery.of(context);
    const snackBarHeight = 56.0;
    final snackBottomMargin =
      (mediaQuery.size.height - mediaQuery.viewPadding.top - snackBarHeight - 8)
        .clamp(16.0, mediaQuery.size.height - snackBarHeight)
        .toDouble();

    void showTopSnackBar(String message, {required bool isError}) {
      if (!rootNavigator.context.mounted) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: snackBottomMargin,
            ),
          ),
        );
    }

    Future<Position> resolveCurrentPosition() async {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied permanently');
      }

      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    }

    var detailCampaign = campaign;
    if (loadCampaignDetail != null) {
      try {
        detailCampaign = await loadCampaignDetail(campaign.id);
      } catch (_) {
        detailCampaign = campaign;
      }
    }

    if (!context.mounted) {
      return;
    }

    var currentView = _SheetView.details;
    var transactionItems = detailCampaign.donations;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          Widget buildBackButton(VoidCallback onPressed) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
            );
          }

          Widget content;

          switch (currentView) {
            // currentView quyết định nội dung nào sẽ được hiển thị
            case _SheetView.supplies:
              content = Column(
                key: const ValueKey('supplies'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PurchasedSuppliesView(
                    campaignId: detailCampaign.id,
                    supplies: detailCampaign.purchasedSupplies,
                    financialSupports: detailCampaign.financialSupports,
                    isOwner: isOwner,
                    onClose: () => setSheetState(() => currentView = _SheetView.details),
                    onAllocationSaved: (supplies, financialSupports) {
                      setSheetState(() {
                        detailCampaign = detailCampaign.copyWith(
                          purchasedSupplies: supplies,
                          financialSupports: financialSupports,
                        );
                      });
                    },
                  ),
                ],
              );
              break;
            case _SheetView.transactions:
              content = Column(
                key: const ValueKey('transactions'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBackButton(
                    () => setSheetState(() => currentView = _SheetView.details),
                  ),
                  TransactionListView(
                    transactions: transactionItems,
                    isOwner: isOwner,
                    campaignStatus: detailCampaign.status,
                  ),
                ],
              );
              break;
            case _SheetView.details:
              final postAnnouncement = onPostAnnouncement;
              final updateCampaign = onUpdateCampaign;
              final sendCampaignRequest = onSendCampaignRequest;

              content = DetailView(
                key: const ValueKey('details'),
                campaign: detailCampaign,
                isOwner: isOwner,
                onPurchasedSupplies: () =>
                    setSheetState(() => currentView = _SheetView.supplies),
                onTransaction: () async {
                      final loadTransactions = onLoadCampaignTransactions;
                      if (loadTransactions != null) {
                        try {
                          final transactions = await loadTransactions(
                            detailCampaign.id,
                          );
                          setSheetState(() {
                            transactionItems = transactions;
                            currentView = _SheetView.transactions;
                          });
                          return;
                        } catch (_) {
                          showTopSnackBar(
                            'Cannot load transactions now.',
                            isError: true,
                          );
                        }
                      }

                      setSheetState(() => currentView = _SheetView.transactions);
                    },
                onPostAnnouncement: postAnnouncement == null
                    ? null
                    : (text) => postAnnouncement(detailCampaign.id, text),
                onUpdateInformation: updateCampaign == null
                    ? null
                    : () async {
                        try {
                          await updateCampaign(detailCampaign);
                          if (loadCampaignDetail != null) {
                            final refreshed = await loadCampaignDetail(
                              detailCampaign.id,
                            );
                            setSheetState(() => detailCampaign = refreshed);
                          }
                          showTopSnackBar(
                            'Campaign updated successfully.',
                            isError: false,
                          );
                        } catch (error) {
                          showTopSnackBar(
                            'Update failed: $error',
                            isError: true,
                          );
                        }
                      },
                onSendRequest: sendCampaignRequest == null
                    ? null
                    : () async {
                        try {
                          await sendCampaignRequest(detailCampaign.id);
                          if (loadCampaignDetail != null) {
                            final refreshed = await loadCampaignDetail(
                              detailCampaign.id,
                            );
                            setSheetState(() => detailCampaign = refreshed);
                          }
                          showTopSnackBar(
                            'Campaign request sent successfully.',
                            isError: false,
                          );
                        } catch (_) {
                          showTopSnackBar(
                            'Cannot send request. Please verify timeline and campaign information.',
                            isError: true,
                          );
                        }
                      },
                onCheckInLocation: onCheckInLocation == null
                    ? null
                    : () async {
                        try {
                          final position = await resolveCurrentPosition();
                          await onCheckInLocation(
                            detailCampaign.id,
                            position.latitude,
                            position.longitude,
                          );

                          if (loadCampaignDetail != null) {
                            final refreshed = await loadCampaignDetail(
                              detailCampaign.id,
                            );
                            setSheetState(() => detailCampaign = refreshed);
                          }

                          showTopSnackBar(
                            'Campaign location check-in successful.',
                            isError: false,
                          );
                        } catch (error) {
                          showTopSnackBar(
                            'Check-in failed: $error',
                            isError: true,
                          );
                        }
                      },
                onFocusCampaignLocation: onFocusCampaignLocation == null
                    ? null
                    : () async {
                        final latitude = detailCampaign.latitude;
                        final longitude = detailCampaign.longitude;
                        if (latitude == null || longitude == null) {
                          showTopSnackBar(
                            'Campaign location is not available yet.',
                            isError: true,
                          );
                          return;
                        }

                        await onFocusCampaignLocation(
                          detailCampaign.id,
                          latitude,
                          longitude,
                        );
                      },
              );
              break;
          }

          return CustomBottomSheet(
            title: campaign.name,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailsBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campaign.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    campaign.benefactorName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
