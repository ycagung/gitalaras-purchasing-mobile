import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspro/bloc/requisition/requisition_bloc.dart';
import 'package:gspro/bloc/requisition/requisition_event.dart';
import 'package:gspro/bloc/requisition/requisition_state.dart';
import 'package:gspro/models/requisition.dart';
import 'package:gspro/pages/purchase_requisition_details_page.dart';
import 'package:gspro/theme/app_colors.dart';
import 'package:material_symbols_icons/symbols.dart';

class PurchaseRequisitionListPage extends StatefulWidget {
  const PurchaseRequisitionListPage({super.key});

  @override
  State<PurchaseRequisitionListPage> createState() =>
      _PurchaseRequisitionListPageState();
}

class _PurchaseRequisitionListPageState
    extends State<PurchaseRequisitionListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  List<Requisition> _filteredRequisitions = [];
  bool _hasLoadedOnce = false;

  // Status mapping - adjust these based on your actual status IDs
  final Map<int, String> _statusMap = {
    1: 'Awaiting approval',
    2: 'Approved',
    3: 'Rejected',
    4: 'PO created',
  };

  final Map<int, Color> _statusColorMap = {
    1: AppColors.yellow, // Awaiting approval
    2: AppColors.green, // Approved
    3: AppColors.red, // Rejected
    4: AppColors.infoBlue, // PO created
  };

  final Map<int, Color> _statusBackgroundColorMap = {
    1: AppColors.lightYellow, // Awaiting approval
    2: AppColors.lightGreen, // Approved
    3: AppColors.lightRed, // Rejected
    4: AppColors.lightBlue, // PO created
  };

  String _getStatusName(int statusId) {
    // Debug: Log when statusId is not found in map
    if (!_statusMap.containsKey(statusId)) {
      print(
        'DEBUG: statusId $statusId not found in map. Available keys: ${_statusMap.keys.toList()}',
      );
    }
    return _statusMap[statusId] ?? 'Unknown';
  }

  // Helper method to format date string to show only date without time
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';

    try {
      // Try to parse as DateTime
      final dateTime = DateTime.parse(dateString);
      // Format as YYYY-MM-DD
      final year = dateTime.year.toString();
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    } catch (e) {
      // If parsing fails, try to extract just the date part if it contains time
      if (dateString.contains(' ')) {
        return dateString.split(' ')[0];
      }
      // If it's already just a date, return as is
      return dateString;
    }
  }

  Color _getStatusColor(int statusId) {
    return _statusColorMap[statusId] ?? AppColors.mono70;
  }

  Color _getStatusBackgroundColor(int statusId) {
    return _statusBackgroundColorMap[statusId] ?? AppColors.mono10;
  }

  void _filterRequisitions(List<Requisition> requisitions) {
    setState(() {
      _filteredRequisitions = requisitions.where((req) {
        // Search filter
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch =
            searchText.isEmpty || req.number.toLowerCase().contains(searchText);

        // Status filter
        final matchesStatus =
            _selectedStatus == null ||
            req.statusId.toString() == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    // Check if data is already loaded
    final currentState = context.read<RequisitionBloc>().state;
    if (currentState is RequisitionsLoadedState) {
      _filterRequisitions(currentState.requisitions);
      _hasLoadedOnce = true;
    } else {
      context.read<RequisitionBloc>().add(const RequisitionsLoaded());
    }
    _searchController.addListener(() {
      final state = context.read<RequisitionBloc>().state;
      if (state is RequisitionsLoadedState) {
        _filterRequisitions(state.requisitions);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTopBar() {
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
              'Purchase Requisitions',
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

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for PR number',
          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.mono60),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AppColors.mono30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AppColors.mono30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AppColors.alizarinCrimson, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          prefixIcon: Icon(Symbols.search, color: AppColors.mono60, size: 20),
        ),
        style: GoogleFonts.inter(fontSize: 14),
      ),
    );
  }

  Widget _buildStatusChip(String label, String? statusId, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = isSelected ? null : statusId;
        });
        final state = context.read<RequisitionBloc>().state;
        if (state is RequisitionsLoadedState) {
          _filterRequisitions(state.requisitions);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.alizarinCrimson : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.alizarinCrimson : AppColors.mono30,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.mono100,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Symbols.tune, color: AppColors.mono70, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip(
                    'Awaiting approval',
                    '1',
                    _selectedStatus == '1',
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip('Approved', '2', _selectedStatus == '2'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Rejected', '3', _selectedStatus == '3'),
                  const SizedBox(width: 8),
                  _buildStatusChip('PO created', '4', _selectedStatus == '4'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCount() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        'Total: ${_filteredRequisitions.length}',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.mono70,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int statusId) {
    final statusName = _getStatusName(statusId);
    final statusColor = _getStatusColor(statusId);
    final backgroundColor = _getStatusBackgroundColor(statusId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusName,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildRequisitionItem(Requisition requisition) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PurchaseRequisitionDetailsPage(
                requisitionNumber: requisition.number,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      requisition.number,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono100,
                      ),
                    ),
                  ),
                  _buildStatusBadge(requisition.statusId),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Symbols.business, size: 16, color: AppColors.mono60),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      requisition.department ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.mono70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Symbols.folder, size: 16, color: AppColors.mono60),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      requisition.projectName ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.mono70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Symbols.calendar_today,
                    size: 16,
                    color: AppColors.mono60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(requisition.requestDate),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.mono70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (requisition.approvalCount != null ||
                  requisition.approvalScore != null)
                Row(
                  children: [
                    Icon(
                      Symbols.verified_user,
                      size: 16,
                      color: AppColors.mono60,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Score: ${requisition.approvalScore ?? 0} (${requisition.approvalCount ?? 0} Approvals)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.mono70,
                      ),
                    ),
                  ],
                ),
              if (requisition.approvalCount != null ||
                  requisition.approvalScore != null)
                const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Symbols.person, size: 16, color: AppColors.mono60),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      requisition.requesterName ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.mono70,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pampas,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchField(),
            _buildFilterRow(),
            _buildDataCount(),
            Expanded(
              child: BlocConsumer<RequisitionBloc, RequisitionState>(
                listener: (context, state) {
                  if (state is RequisitionsLoadedState) {
                    _filterRequisitions(state.requisitions);
                    _hasLoadedOnce = true;
                  } else if (state is RequisitionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // If state is RequisitionLoadedState (from details page) and we've loaded before,
                  // show the last filtered list instead of reloading (to avoid affecting details page)
                  if (state is RequisitionLoadedState && _hasLoadedOnce) {
                    if (_filteredRequisitions.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<RequisitionBloc>().add(
                            const RequisitionsLoaded(),
                          );
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  'No purchase requisitions found',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.mono70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<RequisitionBloc>().add(
                          const RequisitionsLoaded(),
                        );
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredRequisitions.length,
                        itemBuilder: (context, index) {
                          return _buildRequisitionItem(
                            _filteredRequisitions[index],
                          );
                        },
                      ),
                    );
                  }

                  if (state is RequisitionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RequisitionsLoadedState) {
                    if (_filteredRequisitions.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<RequisitionBloc>().add(
                            const RequisitionsLoaded(),
                          );
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  'No purchase requisitions found',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.mono70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<RequisitionBloc>().add(
                          const RequisitionsLoaded(),
                        );
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredRequisitions.length,
                        itemBuilder: (context, index) {
                          return _buildRequisitionItem(
                            _filteredRequisitions[index],
                          );
                        },
                      ),
                    );
                  }

                  if (state is RequisitionError) {
                    return Center(
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
                              context.read<RequisitionBloc>().add(
                                const RequisitionsLoaded(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
