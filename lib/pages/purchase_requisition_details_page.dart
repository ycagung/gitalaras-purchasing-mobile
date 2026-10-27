import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspro/bloc/auth/auth_bloc.dart';
import 'package:gspro/bloc/auth/auth_state.dart';
import 'package:gspro/bloc/requisition/requisition_bloc.dart';
import 'package:gspro/bloc/requisition/requisition_event.dart';
import 'package:gspro/bloc/requisition/requisition_state.dart';
import 'package:gspro/models/attachment.dart';
import 'package:gspro/models/detailed_requisition.dart';
import 'package:gspro/models/item.dart';
import 'package:gspro/models/requisition_approver.dart';
import 'package:gspro/theme/app_colors.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;

class PurchaseRequisitionDetailsPage extends StatefulWidget {
  final String? requisitionNumber;

  const PurchaseRequisitionDetailsPage({super.key, this.requisitionNumber});

  @override
  State<PurchaseRequisitionDetailsPage> createState() =>
      _PurchaseRequisitionDetailsPageState();
}

class _PurchaseRequisitionDetailsPageState
    extends State<PurchaseRequisitionDetailsPage> {

  // Helper method to format date string to show only date without time
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

  // Helper method to format date for display (D MMM YYYY format)
  String _formatDisplayDate(DateTime? date) {
    if (date == null) return '-';
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.requisitionNumber != null) {
      context.read<RequisitionBloc>().add(
        RequisitionLoaded(requisitionNumber: widget.requisitionNumber!),
      );
    }
  }



  Widget _buildTopBar(String? prNumber) {
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
              prNumber ?? 'Purchase Requisition Details',
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
      // Approved
      badgeColor = AppColors.green;
    } else if (statusId == 3) {
      // Rejected
      badgeColor = AppColors.red;
    } else if (statusId == 4) {
      // PO created
      badgeColor = AppColors.green;
    } else {
      // Awaiting approval
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pampas,
      body: SafeArea(
        child: BlocConsumer<RequisitionBloc, RequisitionState>(
          listener: (context, state) {
            if (state is RequisitionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is RequisitionLoading) {
              return Column(
                children: [
                  _buildTopBar(null),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            if (state is RequisitionLoadedState) {
              final data = state.detailedRequisition;
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
                            // Info Cards - Horizontal row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    'Date:',
                                    header.createdAt != null
                                        ? _formatDisplayDate(header.createdAt)
                                        : '-',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    'PR No.:',
                                    header.number,
                                  ),
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
                            DefaultTabController(
                              length: 4,
                              child: Card(
                                child: Column(
                                  children: [
                                    TabBar(
                                    isScrollable: true,
                                    tabAlignment: TabAlignment.start,
                                    labelColor: AppColors.alizarinCrimson,
                                    unselectedLabelColor: AppColors.mono70,
                                    indicatorColor: AppColors.alizarinCrimson,
                                    dividerColor: Colors.transparent,
                                    tabs: const [
                                      Tab(text: 'Details'),
                                      Tab(text: 'Item Details'),
                                      Tab(text: 'History'),
                                      Tab(text: 'Attachment'),
                                    ],
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.5,
                                      child: TabBarView(
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
                                                      'Department',
                                                      header.department ?? '-',
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildDetailRow(
                                                      'Project Name',
                                                      header.projectName ?? '-',
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildDetailRow(
                                                      'Required Date',
                                                      header.requiredDate !=
                                                              null
                                                          ? _formatDate(
                                                              header
                                                                  .requiredDate,
                                                            )
                                                          : '-',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 24),
                                              Expanded(
                                                child: _buildDetailRow(
                                                  'Notes',
                                                  header.remarks ?? '-',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Item Details Tab
                                        SingleChildScrollView(
                                          padding: const EdgeInsets.all(24),
                                          child: _buildItemsList(data.items),
                                        ),
                                        // History Tab
                                        _buildHistoryTab(data),
                                        // Attachment Tab
                                        _buildAttachmentTab(state.attachments),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                                context.read<RequisitionBloc>().add(
                                  RequisitionRejected(requisitionId: header.id),
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

            if (state is RequisitionError) {
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
                              if (widget.requisitionNumber != null) {
                                context.read<RequisitionBloc>().add(
                                  RequisitionLoaded(
                                    requisitionNumber:
                                        widget.requisitionNumber!,
                                  ),
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

            // If state is RequisitionsLoadedState (from list page), trigger load
            if (state is RequisitionsLoadedState &&
                widget.requisitionNumber != null) {
              // Trigger load for details page
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<RequisitionBloc>().add(
                  RequisitionLoaded(
                    requisitionNumber: widget.requisitionNumber!,
                  ),
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

  // Helper to format DateTime as "D-MM-YYYY HH:mm"
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

  Widget _buildItemsList(List<Item> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No items.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.mono70),
          ),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.mono30),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name ?? '-',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mono100,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Product ID: ${item.productId}',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.mono70),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildItemQuantity('Qty', item.qty.toString()),
                  _buildItemQuantity(
                    'Approved',
                    item.approvedQty?.toString() ?? '-',
                  ),
                  _buildItemQuantity('Unit', item.uom),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItemQuantity(String label, String value, [String? unit]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.mono60,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            text: value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mono100,
            ),
            children: [
              TextSpan(
                text: unit != null ? ' $unit' : '',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mono70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentTab(List<Attachment> attachments) {
    if (attachments.isEmpty) {
      return Center(
        child: Text(
          'No attachments found.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.mono70,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        final doc = attachments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.mono30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.pampas,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.mono70,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mono100,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(doc.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.mono70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.download),
                color: AppColors.alizarinCrimson,
                onPressed: () async {
                  if (doc.presignedUrl != null &&
                      doc.presignedUrl!.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading ${doc.name}...')),
                    );
                    try {
                      final uri = Uri.parse(doc.presignedUrl!);
                      final response = await http.get(uri);
                      if (response.statusCode == 200) {
                        final ext = doc.name.contains('.') ? doc.name.split('.').last : '';
                        final nameWithoutExt = doc.name.contains('.')
                            ? doc.name.substring(0, doc.name.lastIndexOf('.'))
                            : doc.name;

                        final savedPath = await FileSaver.instance.saveAs(
                          name: nameWithoutExt,
                          bytes: response.bodyBytes,
                          ext: ext,
                          mimeType: MimeType.other,
                          customMimeType: doc.mimeType,
                        );

                        if (context.mounted) {
                          if (savedPath != null && savedPath.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Download complete')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Download cancelled')),
                            );
                          }
                        }
                      } else {
                        throw Exception('Failed to download: HTTP ${response.statusCode}');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Download link not available for ${doc.name}',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(DetailedRequisition data) {
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
                    // Status icon
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

  Widget _buildApprovalIcon(RequisitionApprover approval) {
    if (approval.approved == true) {
      return const Icon(Symbols.check_circle, size: 16, color: AppColors.green);
    } else if (approval.approved == false) {
      return const Icon(Symbols.cancel, size: 16, color: AppColors.red);
    } else {
      // Pending — neutral circle
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

  void _showApproveDialog(
    BuildContext context,
    String requisitionId,
    List<Item> items,
  ) {
    // Local list to hold current qty values for each item
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
              title: const Text('Approve Requisition Items'),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name ?? '-',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mono100,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Product ID: ${item.productId}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.mono70,
                                  ),
                                ),
                              ],
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
                    // Build the required list of maps
                    final itemsPayload = <Map<String, dynamic>>[];
                    for (int i = 0; i < items.length; i++) {
                      itemsPayload.add({
                        'itemId': items[i].id,
                        'approvedQty': approvedQuantities[i],
                      });
                    }

                    // Dispatch event
                    context.read<RequisitionBloc>().add(
                      RequisitionApproved(
                        requisitionId: requisitionId,
                        items: itemsPayload,
                      ),
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
