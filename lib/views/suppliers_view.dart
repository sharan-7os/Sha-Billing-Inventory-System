import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/supplier.dart';
import '../providers/app_state.dart';
import '../widgets/header_bar.dart';

class SuppliersView extends StatefulWidget {
  const SuppliersView({super.key});

  @override
  State<SuppliersView> createState() => _SuppliersViewState();
}

class _SuppliersViewState extends State<SuppliersView> {
  final TextEditingController _searchController = TextEditingController();
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final filtered = state.suppliers.where((s) {
      final q = _searchController.text.toLowerCase();
      return q.isEmpty ||
          s.company.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q) ||
          s.phone.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          HeaderBar(
            title: 'Suppliers & Vendors',
            subtitle:
                'Manage hardware distributors, mobile wholesalers & vendor GSTINs',
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showAddEditSupplierDialog(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add_business_rounded, size: 18),
                label: const Text('Add Supplier'),
              ),
            ],
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    'Search by Distributor Company, Contact Person, Phone...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // Suppliers Table
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Table(
                    border: TableBorder(
                      horizontalInside:
                          BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2.5), // Company
                      1: FlexColumnWidth(2.0), // Contact Person
                      2: FlexColumnWidth(1.6), // Phone
                      3: FlexColumnWidth(2.0), // GSTIN
                      4: FlexColumnWidth(2.5), // Address
                      5: FlexColumnWidth(1.2), // Actions
                    },
                    children: [
                      TableRow(
                        decoration:
                            BoxDecoration(color: Colors.grey.shade100),
                        children: [
                          _buildTh('Company / Distributor Name'),
                          _buildTh('Contact Person'),
                          _buildTh('Phone Number'),
                          _buildTh('Supplier GSTIN'),
                          _buildTh('Address'),
                          _buildTh('Actions', align: TextAlign.center),
                        ],
                      ),
                      ...filtered.map((s) {
                        return TableRow(
                          children: [
                            _buildTd(s.company, isBold: true),
                            _buildTd(s.name),
                            _buildTd(s.phone),
                            _buildTd(s.gstin ?? '-',
                                color: Colors.blueGrey.shade800),
                            _buildTd(s.address ?? '-',
                                color: Colors.grey.shade700),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18),
                                    color: Colors.blue.shade700,
                                    tooltip: 'Edit Supplier',
                                    onPressed: () =>
                                        _showAddEditSupplierDialog(
                                            context, state,
                                            supplier: s),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18),
                                    color: Colors.red.shade600,
                                    tooltip: 'Delete',
                                    onPressed: () {
                                      state.deleteSupplier(s.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditSupplierDialog(
    BuildContext context,
    AppState state, {
    Supplier? supplier,
  }) {
    final isEditing = supplier != null;
    final companyCtrl = TextEditingController(text: supplier?.company ?? '');
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    final gstinCtrl = TextEditingController(text: supplier?.gstin ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Supplier' : 'Add New Supplier'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Company / Business Name *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Person Name *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email Address (Optional)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gstinCtrl,
                decoration: const InputDecoration(
                  labelText: 'Supplier GSTIN',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Office / Warehouse Address',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (companyCtrl.text.trim().isEmpty) return;

              final s = Supplier(
                id: isEditing ? supplier.id : _uuid.v4(),
                company: companyCtrl.text.trim(),
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                gstin: gstinCtrl.text.trim().isEmpty ? null : gstinCtrl.text.trim(),
                address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
              );

              if (isEditing) {
                state.updateSupplier(s);
              } else {
                state.addSupplier(s);
              }
              Navigator.pop(ctx);
            },
            child: Text(isEditing ? 'Save Changes' : 'Add Supplier'),
          ),
        ],
      ),
    );
  }

  static Widget _buildTh(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  static Widget _buildTd(
    String text, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: color ?? const Color(0xFF1E293B),
        ),
      ),
    );
  }
}

