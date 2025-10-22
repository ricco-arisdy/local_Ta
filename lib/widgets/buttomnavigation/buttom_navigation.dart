// lib/widgets/custom_bottom_navbar.dart
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF4CAF50),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            index: 0,
            isActive: currentIndex == 0,
          )),
          Flexible(
              child: _buildNavItem(
            icon: Icons.local_activity_outlined,
            label: 'Lahan',
            index: 1,
            isActive: currentIndex == 1,
          )),
          Flexible(
              child: _buildNavItem(
            icon: Icons.agriculture_outlined,
            label: 'Panen',
            index: 2,
            isActive: currentIndex == 2,
          )),
          Flexible(
              child: _buildNavItem(
            icon: Icons.grass_outlined,
            label: 'Perawatan',
            index: 3,
            isActive: currentIndex == 3,
          )),
          Flexible(
              child: _buildNavItem(
            icon: Icons.bar_chart_outlined,
            label: 'Laporan',
            index: 4,
            isActive: currentIndex == 4,
          )),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF4CAF50).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
