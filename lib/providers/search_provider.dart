import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/note_model.dart';
import '../data/models/subject_model.dart';
import 'note_provider.dart';
import 'subject_provider.dart';

enum SearchDateFilter {
  all,
  today,
  thisWeek,
  thisMonth,
}

class SearchFilterState {
  final String query;
  final String? selectedSubjectId;
  final SearchDateFilter dateFilter;
  final bool onlyBookmarked;

  const SearchFilterState({
    this.query = '',
    this.selectedSubjectId,
    this.dateFilter = SearchDateFilter.all,
    this.onlyBookmarked = false,
  });

  SearchFilterState copyWith({
    String? query,
    String? Function()? selectedSubjectId,
    SearchDateFilter? dateFilter,
    bool? onlyBookmarked,
  }) {
    return SearchFilterState(
      query: query ?? this.query,
      selectedSubjectId: selectedSubjectId != null ? selectedSubjectId() : this.selectedSubjectId,
      dateFilter: dateFilter ?? this.dateFilter,
      onlyBookmarked: onlyBookmarked ?? this.onlyBookmarked,
    );
  }
}

class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  SearchFilterNotifier() : super(const SearchFilterState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setSubjectFilter(String? subjectId) {
    state = state.copyWith(selectedSubjectId: () => subjectId);
  }

  void setDateFilter(SearchDateFilter dateFilter) {
    state = state.copyWith(dateFilter: dateFilter);
  }

  void toggleBookmarkedOnly() {
    state = state.copyWith(onlyBookmarked: !state.onlyBookmarked);
  }

  void clearFilters() {
    state = const SearchFilterState();
  }
}

final searchFilterProvider = StateNotifierProvider<SearchFilterNotifier, SearchFilterState>((ref) {
  return SearchFilterNotifier();
});

/// Combined search results provider
final searchResultsProvider = Provider<List<SearchResultItem>>((ref) {
  final filter = ref.watch(searchFilterProvider);
  final notesAsync = ref.watch(notesProvider);
  final subjectsAsync = ref.watch(subjectsProvider);

  final notes = notesAsync.valueOrNull ?? [];
  final subjects = subjectsAsync.valueOrNull ?? [];
  final subjectsMap = {for (var s in subjects) s.id: s};

  final query = filter.query.trim().toLowerCase();
  final now = DateTime.now();

  return notes.where((note) {
    final subject = subjectsMap[note.subjectId];
    final subjectName = subject?.name.toLowerCase() ?? '';

    // 1. Text Query Filter
    if (query.isNotEmpty) {
      final matchesTitle = note.title.toLowerCase().contains(query);
      final matchesBody = note.plainText.toLowerCase().contains(query);
      final matchesSubject = subjectName.contains(query);

      if (!matchesTitle && !matchesBody && !matchesSubject) {
        return false;
      }
    }

    // 2. Subject Filter
    if (filter.selectedSubjectId != null && note.subjectId != filter.selectedSubjectId) {
      return false;
    }

    // 3. Bookmark Filter
    if (filter.onlyBookmarked && !note.isBookmarked) {
      return false;
    }

    // 4. Date Range Filter
    if (filter.dateFilter != SearchDateFilter.all) {
      final diff = now.difference(note.updatedAt);
      switch (filter.dateFilter) {
        case SearchDateFilter.today:
          if (diff.inDays > 0 || note.updatedAt.day != now.day) return false;
          break;
        case SearchDateFilter.thisWeek:
          if (diff.inDays > 7) return false;
          break;
        case SearchDateFilter.thisMonth:
          if (diff.inDays > 30) return false;
          break;
        case SearchDateFilter.all:
          break;
      }
    }

    return true;
  }).map((note) {
    final subject = subjectsMap[note.subjectId] ?? Subject.uncategorized;
    return SearchResultItem(
      note: note,
      subject: subject,
      snippet: _generateSnippet(note.plainText, query),
    );
  }).toList();
});

class SearchResultItem {
  final Note note;
  final Subject subject;
  final String snippet;

  const SearchResultItem({
    required this.note,
    required this.subject,
    required this.snippet,
  });
}

String _generateSnippet(String fullText, String query) {
  if (fullText.isEmpty) return 'No text preview';
  if (query.isEmpty) {
    return fullText.length > 90 ? '${fullText.substring(0, 90)}...' : fullText;
  }

  final lower = fullText.toLowerCase();
  final index = lower.indexOf(query);
  if (index == -1) {
    return fullText.length > 90 ? '${fullText.substring(0, 90)}...' : fullText;
  }

  final start = (index - 25).clamp(0, fullText.length);
  final end = (index + query.length + 55).clamp(0, fullText.length);
  final prefix = start > 0 ? '...' : '';
  final suffix = end < fullText.length ? '...' : '';

  return '$prefix${fullText.substring(start, end)}$suffix';
}
