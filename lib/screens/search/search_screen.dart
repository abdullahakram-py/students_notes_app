import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/search_provider.dart';
import '../../providers/subject_provider.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../note_editor/note_editor_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final filterState = ref.watch(searchFilterProvider);
    final filterNotifier = ref.read(searchFilterProvider.notifier);
    final searchResults = ref.watch(searchResultsProvider);
    final subjectsState = ref.watch(subjectsProvider);
    final subjects = subjectsState.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.searchTitle),
        actions: [
          if (filterState.query.isNotEmpty ||
              filterState.selectedSubjectId != null ||
              filterState.dateFilter != SearchDateFilter.all ||
              filterState.onlyBookmarked)
            TextButton(
              onPressed: () {
                _searchController.clear();
                filterNotifier.clearFilters();
              },
              child: const Text('Reset'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search title, content, or subject...',
              onChanged: (val) => filterNotifier.setQuery(val),
              onClear: () {
                _searchController.clear();
                filterNotifier.setQuery('');
              },
            ),
          ),

          // Filter Controls Carousel
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Bookmarked Only Filter Chip
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filterState.onlyBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 16,
                        color: filterState.onlyBookmarked ? AppColors.starActive : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      const SizedBox(width: 4),
                      const Text('Bookmarked'),
                    ],
                  ),
                  selected: filterState.onlyBookmarked,
                  selectedColor: primaryColor.withValues(alpha: 0.25),
                  checkmarkColor: primaryColor,
                  onSelected: (_) => filterNotifier.toggleBookmarkedOnly(),
                ),
                const SizedBox(width: 8),

                // Subject Filter Dropdown Chip
                PopupMenuButton<String?>(
                  tooltip: 'Filter by Subject',
                  onSelected: (subjectId) => filterNotifier.setSubjectFilter(subjectId),
                  itemBuilder: (context) => [
                    const PopupMenuItem<String?>(
                      value: null,
                      child: Text('All Subjects'),
                    ),
                    ...subjects.map(
                      (sub) => PopupMenuItem<String?>(
                        value: sub.id,
                        child: Row(
                          children: [
                            Icon(sub.icon, size: 16, color: sub.color),
                            const SizedBox(width: 8),
                            Text(sub.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: filterState.selectedSubjectId != null
                          ? primaryColor.withValues(alpha: 0.2)
                          : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: filterState.selectedSubjectId != null
                            ? primaryColor
                            : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filterState.selectedSubjectId != null
                              ? subjects.firstWhere((s) => s.id == filterState.selectedSubjectId, orElse: () => subjects.first).name
                              : 'Subject: All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Date Filter Chips
                ...SearchDateFilter.values.where((d) => d != SearchDateFilter.all).map((dateFilter) {
                  final isSelected = filterState.dateFilter == dateFilter;
                  final label = dateFilter == SearchDateFilter.today
                      ? 'Today'
                      : dateFilter == SearchDateFilter.thisWeek
                          ? 'This Week'
                          : 'This Month';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: primaryColor.withValues(alpha: 0.25),
                      checkmarkColor: primaryColor,
                      onSelected: (selected) {
                        filterNotifier.setDateFilter(selected ? dateFilter : SearchDateFilter.all);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Results List
          Expanded(
            child: searchResults.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: AppStrings.noSearchResults,
                    subtitle: AppStrings.noSearchResultsSubtitle,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: searchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = searchResults[index];
                      final note = item.note;
                      final subject = item.subject;

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditorScreen(note: note),
                              ),
                            );
                          },
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: subject.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  subject.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  note.title.isNotEmpty ? note.title : 'Untitled Note',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ),
                              if (note.isBookmarked)
                                const Icon(Icons.star_rounded, size: 18, color: AppColors.starActive),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.snippet,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Modified: ${DateFormatter.formatNoteDate(note.updatedAt)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
