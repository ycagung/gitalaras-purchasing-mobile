import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspro/bloc/auth/auth_bloc.dart';
import 'package:gspro/bloc/auth/auth_state.dart';
import 'package:gspro/bloc/order/order_bloc.dart';
import 'package:gspro/bloc/order/order_event.dart';
import 'package:gspro/bloc/order/order_state.dart';
import 'package:gspro/models/detailed_order.dart';
import 'package:gspro/models/item.dart';
import 'package:gspro/models/order_approver.dart';
import 'package:gspro/theme/app_colors.dart';
import 'package:material_symbols_icons/symbols.dart';

class PurchaseOrderDetailsPage extends StatefulWidget {
  final String? orderNumber;

  const PurchaseOrderDetailsPage({super.key, this.orderNumber});

  @override
  State<PurchaseOrderDetailsPage> createState() =>
      _PurchaseOrderDetailsPageState();
}

class _PurchaseOrderDetailsPageState extends State<PurchaseOrderDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateString);
      final year = dateTime.year.toString();
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    } catch (e) {
      if (dateString.contains(' ')) {
        return dateString.split(' ')[0];
      }
      return dateString;
    }
  }

  String _formatDisplayDate(DateTime? date) {
    if (date == null) return '-';
    final localDate = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    final localDate = date.toLocal();
    final day = localDate.day.toString();
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    return '$day-$month-$year $hour:$minute';
  }

  String _formatDateTimeLong(DateTime? date) {
    if (date == null) return '-';
    final localDate = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = localDate.day.toString();
    final month = months[localDate.month - 1];
    final year = localDate.year.toString();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    return '$day $month $year $hour:$minute';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.orderNumber != null) {
      context.read<OrderBloc>().add(
        OrderLoaded(orderNumber: widget.orderNumber!),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTopBar(String? poNumber) {
    return Container(
      height: 48,
      color: AppColors.alto,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Symbols.arrow_back, color: AppColors.mono100, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              poNumber ?? 'Purchase Order Details',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.mono100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int statusId, String statusName) {
    Color badgeColor;
    Color textColor = Colors.white;

    if (statusId == 2) {
      // Waiting Approval
      badgeColor = AppColors.yellow;
    } else if (statusId == 3) {
      // Rejected
      badgeColor = AppColors.red;
    } else if (statusId == 4) {
      // Approved
      badgeColor = AppColors.green;
    } else {
      // Draft / Other
      badgeColor = AppColors.yellow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusName,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pampas,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.mono70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mono100,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.mono70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.mono100,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable(List<Item> items) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mono30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.alto,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Name',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono100,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono100,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'UOM',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No items.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.mono70,
                  ),
                ),
              ),
            )
          else
            ...List.generate(items.length, (index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: index % 2 == 1 ? AppColors.pampas : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: AppColors.mono30, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.name ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.mono100,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.qty.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.mono100,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.uom,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.mono100,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(DetailedOrder data) {
    final hasChanges = data.changes.isNotEmpty;
    final hasApprovals = data.approvals.isNotEmpty;
    final hasPrints = data.prints.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Changes Section ---
          Text(
            'History',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.alizarinCrimson,
            ),
          ),
          const SizedBox(height: 16),
          if (hasChanges)
            ...data.changes.map(
              (change) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${change.by?.displayName ?? "Unknown"} at ${_formatDateTime(change.at)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mono70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      change.content ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mono100,
                      ),
                    ),
                    if (change.section != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Section: ${change.section}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.mono60,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'No history available',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.mono70),
              ),
            ),

          // --- Approvals Section ---
          if (hasApprovals) ...[
            const SizedBox(height: 16),
            Text(
              'Approvals',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.alizarinCrimson,
              ),
            ),
            const SizedBox(height: 16),
            ...data.approvals.map(
              (approval) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _buildApprovalIcon(approval),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'By: ${approval.approver?.name ?? approval.approver?.email ?? "-"} | Score: ${approval.score}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.mono100,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDateTimeLong(approval.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.mono70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // --- Prints Section ---
          if (hasPrints) ...[
            const SizedBox(height: 16),
            Text(
              'Prints',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.alizarinCrimson,
              ),
            ),
            const SizedBox(height: 16),
            ...data.prints.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Printed at ${_formatDateTimeLong(p.createdAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mono100,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By: ${p.printedById ?? "-"}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.mono70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApprovalIcon(OrderApprover approval) {
    if (approval.approved == true) {
      return const Icon(Symbols.check_circle, size: 16, color: AppColors.green);
    } else if (approval.approved == false) {
      return const Icon(Symbols.cancel, size: 16, color: AppColors.red);
    } else {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.mono60, width: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pampas,
      body: SafeArea(
        child: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return Column(
                children: [
                  _buildTopBar(null),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            if (state is OrderLoadedState) {
              final data = state.detailedOrder;
              final header = data.header;

              // Check if current user already exists in approvers
              final authState = context.read<AuthBloc>().state;
              final currentUserId = authState is AuthAuthenticated
                  ? authState.userId
                  : null;
              final userAlreadyApproved =
                  currentUserId != null &&
                  data.approvals.any((a) => a.approverId == currentUserId);
              final showActionButtons =
                  header.statusId == 1 && !userAlreadyApproved;

              // Calculate total score and approved count from approvers list
              int totalScore = 0;
              int approvedCount = 0;
              for (final approval in data.approvals) {
                if (approval.approved == true) {
                  totalScore += approval.score;
                  approvedCount++;
                }
              }

              // Issuer display name
              final issuerName = data.issuer?.name ?? data.issuer?.email ?? '-';

              return Column(
                children: [
                  _buildTopBar(header.number),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status
                            Row(
                              children: [
                                Text(
                                  'Status:',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.mono100,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusBadge(
                                  header.statusId,
                                  data.status.name,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Info Cards - Row 1
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    'PO No.:',
                                    header.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    'Requisition:',
                                    header.requisitionId ?? '-',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    'Date:',
                                    header.createdAt != null
                                        ? _formatDisplayDate(header.createdAt)
                                        : '-',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Info Cards - Row 2
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    'Issue Date:',
                                    _formatDate(header.issueDate),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard('Issuer:', issuerName),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    'Score:',
                                    '$totalScore ($approvedCount)',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Tabs
                            Card(
                              child: Column(
                                children: [
                                  TabBar(
                                    controller: _tabController,
                                    labelColor: AppColors.alizarinCrimson,
                                    unselectedLabelColor: AppColors.mono70,
                                    indicatorColor: AppColors.alizarinCrimson,
                                    dividerColor: Colors.transparent,
                                    tabs: const [
                                      Tab(text: 'Details'),
                                      Tab(text: 'Item Details'),
                                      Tab(text: 'History'),
                                    ],
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.5,
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        // Details Tab
                                        SingleChildScrollView(
                                          padding: const EdgeInsets.all(24),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildDetailRow(
                                                      'Supplier',
                                                      data.supplier?.name ??
                                                          '-',
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildDetailRow(
                                                      'Delivery Point',
                                                      data.deliveryPointName,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildDetailRow(
                                                      'Delivery Term',
                                                      header.deliveryTerm ??
                                                          '-',
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildDetailRow(
                                                      'Delivery Date',
                                                      header.deliveryDate !=
                                                              null
                                                          ? _formatDate(
                                                              header
                                                                  .deliveryDate,
                                                            )
                                                          : '-',
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildDetailRow(
                                                      'Payment Term',
                                                      header.paymentTermId ??
                                                          '-',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 24),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildDetailRow(
                                                      'Issuer',
                                                      issuerName,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildDetailRow(
                                                      'Issue Date',
                                                      _formatDate(
                                                        header.issueDate,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildDetailRow(
                                                      'Notes',
                                                      header.remarks ?? '-',
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildDetailRow(
                                                      'Created At',
                                                      header.createdAt != null
                                                          ? _formatDateTimeLong(
                                                              header.createdAt,
                                                            )
                                                          : '-',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Item Details Tab
                                        SingleChildScrollView(
                                          padding: const EdgeInsets.all(24),
                                          child: _buildItemsTable(data.items),
                                        ),
                                        // History Tab
                                        _buildHistoryTab(data),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Sticky bottom buttons (hidden if user already approved)
                  if (showActionButtons)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mono30,
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            _buildActionButton(
                              label: 'Reject',
                              icon: Symbols.cancel,
                              color: AppColors.red,
                              onTap: () {
                                context.read<OrderBloc>().add(
                                  OrderRejected(orderId: header.id),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            _buildActionButton(
                              label: 'Approve',
                              icon: Symbols.check_circle,
                              color: AppColors.green,
                              onTap: () {
                                _showApproveDialog(
                                  context,
                                  header.id,
                                  data.items,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }

            if (state is OrderError) {
              return Column(
                children: [
                  _buildTopBar(null),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (widget.orderNumber != null) {
                                context.read<OrderBloc>().add(
                                  OrderLoaded(orderNumber: widget.orderNumber!),
                                );
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // If state is OrdersLoadedState (from list page), trigger load
            if (state is OrdersLoadedState && widget.orderNumber != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<OrderBloc>().add(
                  OrderLoaded(orderNumber: widget.orderNumber!),
                );
              });
              return Column(
                children: [
                  _buildTopBar(null),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildTopBar(null),
                const Expanded(child: Center(child: Text('No data available'))),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showApproveDialog(
    BuildContext context,
    String orderId,
    List<Item> items,
  ) {
    final approvedQuantities = List<int>.generate(
      items.length,
      (i) => items[i].qty,
    );

    showDialog(
      context: context,
      builder: (BuildContext dContext) {
        return StatefulBuilder(
          builder: (stContext, setState) {
            return AlertDialog(
              title: const Text('Approve Order Items'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name ?? '-',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              initialValue: approvedQuantities[index]
                                  .toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              onChanged: (val) {
                                approvedQuantities[index] =
                                    int.tryParse(val) ?? 0;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.uom,
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final itemsPayload = <Map<String, dynamic>>[];
                    for (int i = 0; i < items.length; i++) {
                      itemsPayload.add({
                        'itemId': items[i].id,
                        'approvedQty': approvedQuantities[i],
                      });
                    }

                    context.read<OrderBloc>().add(
                      OrderApproved(orderId: orderId, items: itemsPayload),
                    );
                    Navigator.of(dContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
