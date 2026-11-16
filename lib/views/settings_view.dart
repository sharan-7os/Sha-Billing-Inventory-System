import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/shop_settings.dart';
import '../providers/app_state.dart';
import '../widgets/header_bar.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _shopNameCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _gstinCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _stateCodeCtrl;

  late TextEditingController _bankNameCtrl;
  late TextEditingController _accountNumberCtrl;
  late TextEditingController _ifscCtrl;
  late TextEditingController _upiIdCtrl;

  late TextEditingController _invoicePrefixCtrl;
  late TextEditingController _nextInvoiceNumCtrl;
  late TextEditingController _termsCtrl;
  late bool _isInterState;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppState>().settings;
    _shopNameCtrl = TextEditingController(text: settings.shopName);
    _taglineCtrl = TextEditingController(text: settings.tagline);
    _addressCtrl = TextEditingController(text: settings.address);
    _phoneCtrl = TextEditingController(text: settings.phone);
    _emailCtrl = TextEditingController(text: settings.email);
    _gstinCtrl = TextEditingController(text: settings.gstin);
    _stateCtrl = TextEditingController(text: settings.state);
    _stateCodeCtrl = TextEditingController(text: settings.stateCode);

    _bankNameCtrl = TextEditingController(text: settings.bankName);
    _accountNumberCtrl = TextEditingController(text: settings.accountNumber);
    _ifscCtrl = TextEditingController(text: settings.ifscCode);
    _upiIdCtrl = TextEditingController(text: settings.upiId);

    _invoicePrefixCtrl = TextEditingController(text: settings.invoicePrefix);
    _nextInvoiceNumCtrl =
        TextEditingController(text: settings.nextInvoiceNumber.toString());
    _termsCtrl = TextEditingController(text: settings.termsAndConditions);
    _isInterState = settings.isInterState;
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _taglineCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _gstinCtrl.dispose();
    _stateCtrl.dispose();
    _stateCodeCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCtrl.dispose();
    _upiIdCtrl.dispose();
    _invoicePrefixCtrl.dispose();
    _nextInvoiceNumCtrl.dispose();
    _termsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          HeaderBar(
            title: 'Shop Configuration & Profile',
            subtitle:
                'Update business details, GSTIN credentials, bank accounts and invoice templates',
            actions: [
              ElevatedButton.icon(
                onPressed: () => _saveSettings(state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Settings'),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Section 1: Business Identity & Contact
                  _buildSectionCard(
                    title: 'Shop Identity & GST Registration',
                    subtitle:
                        'These details appear on the header of all printed A4 Tax Invoices',
                    icon: Icons.storefront_rounded,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _shopNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Shop / Business Name *',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _taglineCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Tagline / Slogan',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _gstinCtrl,
                              decoration: const InputDecoration(
                                labelText: 'GSTIN Number (15 Digits) *',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _stateCtrl,
                              decoration: const InputDecoration(
                                labelText: 'State Name',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _stateCodeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'State Code (e.g. 27)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _phoneCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Support Phone / Mobile *',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Business Email',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Complete Shop Address (with Pincode)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Bank Details & UPI (Printed on Bill)
                  _buildSectionCard(
                    title: 'Bank & UPI Payment Information',
                    subtitle:
                        'Printed on the invoice footer for customer bank transfers & digital payments',
                    icon: Icons.account_balance_rounded,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _bankNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Bank Name (e.g. HDFC Bank)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _accountNumberCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Current / Savings Account No.',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ifscCtrl,
                              decoration: const InputDecoration(
                                labelText: 'IFSC Code',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _upiIdCtrl,
                              decoration: const InputDecoration(
                                labelText: 'UPI ID / VPA (for GPay/PhonePe)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Billing & Terms
                  _buildSectionCard(
                    title: 'Invoice Formatting & Terms',
                    subtitle:
                        'Sequence numbering and legal terms printed on every bill',
                    icon: Icons.receipt_long_rounded,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _invoicePrefixCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Invoice Prefix (e.g. SHA-2026-)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _nextInvoiceNumCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Next Invoice Number',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _termsCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Terms & Conditions',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 4: Data Backup & Restore
                  _buildSectionCard(
                    title: 'Database Backup & Restore',
                    subtitle:
                        'Keep your inventory, invoices, and customer records safe with instant JSON backup',
                    icon: Icons.cloud_sync_rounded,
                    children: [
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _exportBackup(context, state),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Export Database Backup (JSON)'),
                          ),
                          const SizedBox(width: 14),
                          OutlinedButton.icon(
                            onPressed: () => _importBackup(context, state),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            icon: const Icon(Icons.upload_rounded, size: 18),
                            label: const Text('Import / Restore Backup'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 5: Reset & Clear All Data
                  _buildSectionCard(
                    title: 'Reset Store & Clear All Data (Fresh Start)',
                    subtitle:
                        'Delete all products, invoices, and customer balances to start entering your real shop data',
                    icon: Icons.delete_forever_rounded,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.red, size: 28),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Clear All Sample / Existing Data',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'This wipes all products, stock counts, invoices, and customer transaction history so you can start with a 100% clean database.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              onPressed: () =>
                                  _confirmClearAllData(context, state),
                              icon: const Icon(Icons.delete_sweep_rounded,
                                  size: 18),
                              label: const Text('Clear All Data Now'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 28),
          ...children,
        ],
      ),
    );
  }

  void _saveSettings(AppState state) {
    final nextNum = int.tryParse(_nextInvoiceNumCtrl.text) ?? 1001;
    final updated = ShopSettings(
      shopName: _shopNameCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gstin: _gstinCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      stateCode: _stateCodeCtrl.text.trim(),
      bankName: _bankNameCtrl.text.trim(),
      accountNumber: _accountNumberCtrl.text.trim(),
      ifscCode: _ifscCtrl.text.trim(),
      upiId: _upiIdCtrl.text.trim(),
      invoicePrefix: _invoicePrefixCtrl.text.trim(),
      nextInvoiceNumber: nextNum,
      termsAndConditions: _termsCtrl.text.trim(),
      isInterState: _isInterState,
    );

    state.updateSettings(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shop settings and invoice profile saved successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _exportBackup(BuildContext context, AppState state) async {
    final jsonStr = await state.exportBackup();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Full Database Backup JSON'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Copy and save this JSON backup string safely. You can restore your entire inventory, customers, and invoices anytime.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: jsonStr),
                maxLines: 8,
                readOnly: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup JSON copied to clipboard!'),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy to Clipboard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _importBackup(BuildContext context, AppState state) {
    final importCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Database from Backup'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paste your backup JSON below to restore inventory, customers, and invoice records:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: importCtrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Paste backup JSON here...',
                  border: OutlineInputBorder(),
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
            onPressed: () async {
              final ok = await state.importBackup(importCtrl.text.trim());
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Database restored successfully!'
                      : 'Invalid backup JSON format!'),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllData(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Confirm Reset & Clear Data?'),
          ],
        ),
        content: const SizedBox(
          width: 440,
          child: Text(
            'Are you sure you want to delete all products, invoices, and clear all sample data?\n\n'
            'This action cannot be undone. Your shop will be 100% clean and ready for your fresh real inventory.',
            style: TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await state.clearAllData();
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'All data has been cleared! You can now add your fresh inventory.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Yes, Clear Everything'),
          ),
        ],
      ),
    );
  }
}
