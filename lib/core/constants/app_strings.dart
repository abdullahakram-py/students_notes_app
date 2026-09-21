/// UI text strings used across the application
class AppStrings {
  AppStrings._();

  static const String appName = 'Student Notes';
  static const String searchHint = 'Search notes, subjects, topics...';
  static const String subjectsTitle = 'Subjects';
  static const String recentNotesTitle = 'Recent Notes';
  static const String bookmarksTitle = 'Bookmarks';
  static const String searchTitle = 'Search Notes';
  static const String settingsTitle = 'Settings';

  // Actions
  static const String addSubject = 'Add Subject';
  static const String editSubject = 'Edit Subject';
  static const String deleteSubject = 'Delete Subject';
  static const String addNote = 'Add Note';
  static const String editNote = 'Edit Note';
  static const String deleteNote = 'Delete Note';
  static const String saveNote = 'Save Note';
  static const String autoSaved = 'Saved automatically';
  static const String saving = 'Saving...';
  static const String exportToPdf = 'Export to PDF';
  static const String openDiagram = 'Diagram Canvas';

  // Attachments
  static const String attachFile = 'Attach File';
  static const String takePhoto = 'Take Photo';
  static const String chooseGallery = 'Upload Image';
  static const String choosePdf = 'Attach PDF Document';
  static const String removeAttachment = 'Remove Attachment';
  static const String fileTooLarge = 'File exceeds maximum allowed size of 20MB.';

  // Empty states
  static const String noSubjectsYet = 'No subjects added yet';
  static const String noSubjectsSubtitle = 'Create your courses (e.g. Physics, History, Biology) to organize your notes.';
  static const String noNotesYet = 'No notes in this subject';
  static const String noNotesSubtitle = 'Tap the + button to capture lecture notes, attachments, and diagrams.';
  static const String noBookmarksYet = 'No bookmarked notes';
  static const String noBookmarksSubtitle = 'Tap the star icon on any note to bookmark it for quick exam revision.';
  static const String noSearchResults = 'No matching notes found';
  static const String noSearchResultsSubtitle = 'Try searching with a different keyword or removing active filters.';
}
