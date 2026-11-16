import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lowStockCount = state.lowStockProducts.length + state.outOfStockProducts.length;

    final navItems = [
      _NavItem(Icons.dashboard_rounded, 'Dashboard', 0),
      _NavItem(Icons.point_of_sale_rounded, 'POS / Billing', 1, isPos: true),
      _NavItem(
        Icons.inventory_2_rounded,
        'Inventory & Stock',
        2,
        badgeCount: lowStockCount > 0 ? lowStockCount : null,
      ),
      _NavItem(Icons.receipt_long_rounded, 'Invoices & Sales', 3),
      _NavItem(Icons.people_alt_rounded, 'Customers & Khata', 4),
      _NavItem(Icons.local_shipping_rounded, 'Suppliers', 5),
      _NavItem(Icons.analytics_rounded, 'Reports & GST', 6),
      _NavItem(Icons.settings_rounded, 'Settings', 7),
    ];

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Brand & Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.devices_other_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.settings.shopName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Active Desktop POS',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),
          const SizedBox(height: 12),

          // Quick Action: New Sale
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => onDestinationSelected(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                label: const Text(
                  'Quick Bill (POS)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Nav Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = selectedIndex == item.index;

                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => onDestinationSelected(item.index),
                    borderRadius: BorderRadius.circular(10),
                    hoverColor: const Color(0xFF1E293B),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E293B)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          if (item.badgeCount != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${item.badgeCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom System Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF090D16),
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 18,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GST: ${state.settings.gstin}',
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Offline Fast Database',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String title;
  final int index;
  final int? badgeCount;
  final bool isPos;

  _NavItem(this.icon, this.title, this.index,
      {this.badgeCount, this.isPos = false});
}
