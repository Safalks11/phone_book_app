import 'package:flutter/material.dart';

import '../../../../core/utils/contact_utils.dart';

class ContactSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String query;
  final SortOption currentSort;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onSortPressed;

  const ContactSearchBar({
    super.key,
    required this.searchController,
    required this.query,
    required this.currentSort,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: SearchBar(
              controller: searchController,
              hintText: 'Search contacts...',
              onChanged: onSearchChanged,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: const Icon(Icons.search),
              ),
              trailing: [
                if (query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClearSearch,
                    tooltip: 'Clear search',
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: _getSortTooltip(currentSort),
            onPressed: onSortPressed,
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
    );
  }

  String _getSortTooltip(SortOption option) {
    switch (option) {
      case SortOption.name:
        return 'Sorted by Name';
      case SortOption.recent:
        return 'Sorted by Recent';
      case SortOption.favorites:
        return 'Sorted by Favorites';
    }
  }
}
