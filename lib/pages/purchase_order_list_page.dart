import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspro/bloc/order/order_bloc.dart';
import 'package:gspro/bloc/order/order_event.dart';
import 'package:gspro/bloc/order/order_state.dart';
import 'package:gspro/models/order.dart';
import 'package:gspro/pages/purchase_order_details_page.dart';
import 'package:gspro/theme/app_colors.dart';
import 'package:material_symbols_icons/symbols.dart';

class PurchaseOrderListPage extends StatefulWidget {
  const PurchaseOrderListPage({super.key});

  @override
  State<PurchaseOrderListPage> createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  bool _hasLoadedOnce = false;

  // Status mapping — adjust based on actual status IDs
  final Map<int, String> _statusMap = {
    1: 'Draft',
    2: 'Waiting Approval',
    3: 'Approved',
    4: 'Rejected',
  };

  final Map<int, Color> _statusColorMap = {
    1: AppColors.mono70, // Draft
    2: AppColors.yellow, // Waiting Approval
    3: AppColors.green, // Approved
    4: AppColors.red, // Rejected
  };

  final Map<int, Color> _statusBackgroundColorMap = {
    1: AppColors.mono10, // Draft
    2: AppColors.lightYellow, // Waiting Approval
    3: AppColors.lightGreen, // Approved
    4: AppColors.lightRed, // Rejected
  };

  String _getStatusName(int statusId) {
    return _statusMap[statusId] ?? 'Unknown';
  }

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

  Color _getStatusColor(int statusId) {
    return _statusColorMap[statusId] ?? AppColors.mono70;
  }

  Color _getStatusBackgroundColor(int statusId) {
    return _statusBackgroundColorMap[statusId] ?? AppColors.mono10;
  }

  void _filterOrders([List<Order>? orders]) {
    final ordersToFilter = orders ?? _allOrders;
    setState(() {
      _filteredOrders = ordersToFilter.where((order) {
        // Search filter
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch =
            searchText.isEmpty ||
            order.number.toLowerCase().contains(searchText);

        // Status filter
        final matchesStatus =
            _selectedStatus == null ||
            order.statusId.toString() == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    // Check if data is already loaded
    final currentState = context.read<OrderBloc>().state;
    if (currentState is OrdersLoadedState) {
      _allOrders = currentState.orders;
      _filterOrders(_allOrders);
      _hasLoadedOnce = true;
    } else {
      context.read<OrderBloc>().add(const OrdersLoaded());
    }
    _searchController.addListener(() {
      _filterOrders();
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
              'Purchase Orders',
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
          hintText: 'Search for PO number',
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
        _filterOrders();
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
                  _buildStatusChip('Draft', '1', _selectedStatus == '1'),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    'Waiting Approval',
                    '2',
                    _selectedStatus == '2',
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip('Approved', '3', _selectedStatus == '3'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Rejected', '4', _selectedStatus == '4'),
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
        'Total: ${_filteredOrders.length}',
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

  Widget _buildOrderItem(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PurchaseOrderDetailsPage(orderNumber: order.number),
            ),
          ).then((_) {
            // Reload the list when returning to ensure we have the latest status
            context.read<OrderBloc>().add(const OrdersLoaded());
          });
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
                      order.number,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono100,
                      ),
                    ),
                  ),
                  _buildStatusBadge(order.statusId),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Symbols.receipt_long, size: 16, color: AppColors.mono60),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Requisition: ${order.requisitionId ?? "-"}',
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
                    order.createdAt != null
                        ? _formatDisplayDate(order.createdAt)
                        : '-',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.mono70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Symbols.event, size: 16, color: AppColors.mono60),
                  const SizedBox(width: 8),
                  Text(
                    'Issue: ${_formatDate(order.issueDate)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.mono70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Symbols.local_shipping,
                    size: 16,
                    color: AppColors.mono60,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Delivery: ${_formatDate(order.deliveryDate)}',
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
              child: BlocConsumer<OrderBloc, OrderState>(
                listener: (context, state) {
                  if (state is OrdersLoadedState) {
                    _allOrders = state.orders;
                    _filterOrders(_allOrders);
                    _hasLoadedOnce = true;
                  } else if (state is OrderError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // If state is OrderLoadedState (from details page) or OrderLoading,
                  // and we've loaded before, show the last filtered list instead of reloading
                  if ((state is OrderLoadedState || state is OrderLoading) &&
                      _hasLoadedOnce) {
                    if (_filteredOrders.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<OrderBloc>().add(const OrdersLoaded());
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  'No purchase orders found',
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
                        context.read<OrderBloc>().add(const OrdersLoaded());
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderItem(_filteredOrders[index]);
                        },
                      ),
                    );
                  }

                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is OrdersLoadedState) {
                    if (_filteredOrders.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<OrderBloc>().add(const OrdersLoaded());
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  'No purchase orders found',
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
                        context.read<OrderBloc>().add(const OrdersLoaded());
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderItem(_filteredOrders[index]);
                        },
                      ),
                    );
                  }

                  if (state is OrderError) {
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
                              context.read<OrderBloc>().add(
                                const OrdersLoaded(),
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
