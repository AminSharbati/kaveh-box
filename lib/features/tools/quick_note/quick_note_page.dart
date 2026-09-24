import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class QuickNotePage extends StatefulWidget {
  const QuickNotePage({super.key});

  @override
  State<QuickNotePage> createState() => _QuickNotePageState();
}

class _QuickNotePageState extends State<QuickNotePage> {
  static const String _notesKey = 'kaveh_notes';

  final TextEditingController _controller = TextEditingController();

  List<_NoteItem> _notes = [];
  _NoteItem? _editingNote;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotes = prefs.getStringList(_notesKey) ?? [];

    final notes = <_NoteItem>[];

    for (final item in savedNotes) {
      try {
        final json = jsonDecode(item);

        if (json is Map<String, dynamic>) {
          notes.add(_NoteItem.fromJson(json));
        }
      } catch (_) {
        // Ignore invalid old data.
      }
    }

    notes.sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
    );

    if (!mounted) return;

    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final values = _notes
        .map((note) => jsonEncode(note.toJson()))
        .toList();

    await prefs.setStringList(_notesKey, values);
  }

  Future<void> _saveNote() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      _showMessage('اول متن یادداشت را بنویس');
      return;
    }

    final now = DateTime.now();

    if (_editingNote == null) {
      final note = _NoteItem(
        id: now.microsecondsSinceEpoch.toString(),
        text: text,
        createdAt: now,
        updatedAt: now,
      );

      setState(() {
        _notes.insert(0, note);
        _controller.clear();
      });

      await _saveNotes();

      if (!mounted) return;
      _showMessage('یادداشت ذخیره شد');
    } else {
      final editingId = _editingNote!.id;

      final index = _notes.indexWhere(
            (note) => note.id == editingId,
      );

      if (index == -1) {
        return;
      }

      final updatedNote = _NoteItem(
        id: _editingNote!.id,
        text: text,
        createdAt: _editingNote!.createdAt,
        updatedAt: now,
      );

      setState(() {
        _notes[index] = updatedNote;
        _editingNote = null;
        _controller.clear();
      });

      _sortNotes();

      await _saveNotes();

      if (!mounted) return;
      _showMessage('یادداشت ویرایش شد');
    }
  }

  void _editNote(_NoteItem note) {
    setState(() {
      _editingNote = note;
      _controller.text = note.text;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      FocusScope.of(context).requestFocus();
    });
  }

  Future<void> _deleteNote(_NoteItem note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف یادداشت'),
            content: const Text(
              'مطمئنی می‌خوای این یادداشت رو حذف کنی؟',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('انصراف'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _notes.removeWhere(
            (item) => item.id == note.id,
      );

      if (_editingNote?.id == note.id) {
        _editingNote = null;
        _controller.clear();
      }
    });

    await _saveNotes();

    if (!mounted) return;
    _showMessage('یادداشت حذف شد');
  }

  Future<void> _copyNote(_NoteItem note) async {
    await Clipboard.setData(
      ClipboardData(text: note.text),
    );

    _showMessage('یادداشت کپی شد');
  }

  void _newNote() {
    setState(() {
      _editingNote = null;
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      FocusScope.of(context).requestFocus();
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingNote = null;
      _controller.clear();
    });
  }

  void _sortNotes() {
    _notes.sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
    );
  }

  String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} - $hour:$minute';
  }

  String _previewText(String text) {
    final cleanText = text.replaceAll('\n', ' ').trim();

    if (cleanText.length <= 100) {
      return cleanText;
    }

    return '${cleanText.substring(0, 100)}...';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('یادداشت‌ها'),
          actions: [
            if (_editingNote != null)
              IconButton(
                onPressed: _cancelEditing,
                tooltip: 'لغو ویرایش',
                icon: const Icon(
                  Icons.close_rounded,
                ),
              ),
            IconButton(
              onPressed: _newNote,
              tooltip: 'یادداشت جدید',
              icon: const Icon(
                Icons.add_rounded,
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
          ),
        )
            : SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              24,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                Text(
                  _editingNote == null
                      ? 'یادداشت جدید 📝'
                      : 'ویرایش یادداشت ✏️',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                Text(
                  _editingNote == null
                      ? 'یادداشتت رو بنویس و ذخیره کن.'
                      : 'تغییراتت رو اعمال کن و دوباره ذخیره کن.',
                  style:
                  AppTypography.bodySecondary,
                ),
                const SizedBox(height: 18),

                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                    BorderRadius.circular(20),
                    border: Border.all(
                      color: _editingNote != null
                          ? AppColors.gold
                          : AppColors.border,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textDirection:
                    TextDirection.rtl,
                    textAlign: TextAlign.right,
                    textAlignVertical:
                    TextAlignVertical.top,
                    style: AppTypography.body,
                    decoration:
                    const InputDecoration(
                      hintText:
                      'یادداشتت رو اینجا بنویس...',
                      hintStyle:
                      AppTypography.bodySecondary,
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.all(18),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _saveNote,
                    icon: Icon(
                      _editingNote == null
                          ? Icons.save_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(
                      _editingNote == null
                          ? 'ذخیره یادداشت'
                          : 'ذخیره تغییرات',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      AppColors.gold,
                      foregroundColor:
                      Colors.black,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'یادداشت‌های قبلی',
                        style:
                        AppTypography.subtitle,
                      ),
                    ),
                    Text(
                      '${_notes.length} یادداشت',
                      style:
                      AppTypography.caption,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_notes.isEmpty)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    decoration:
                    BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                      border: Border.all(
                        color:
                        AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 42,
                          color:
                          AppColors.textDisabled,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'هنوز یادداشتی ذخیره نکردی',
                          style:
                          AppTypography.body,
                          textAlign:
                          TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'اولین یادداشتت رو همین بالا بنویس.',
                          style:
                          AppTypography
                              .bodySecondary,
                          textAlign:
                          TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ..._notes.map(
                        (note) => Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: _NoteCard(
                        note: note,
                        preview:
                        _previewText(
                          note.text,
                        ),
                        date:
                        _formatDate(
                          note.updatedAt,
                        ),
                        onEdit: () =>
                            _editNote(note),
                        onDelete: () =>
                            _deleteNote(note),
                        onCopy: () =>
                            _copyNote(note),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteItem {
  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  const _NoteItem({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory _NoteItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return _NoteItem(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt:
      DateTime.parse(json['createdAt'] as String),
      updatedAt:
      DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final _NoteItem note;
  final String preview;
  final String date;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const _NoteCard({
    required this.note,
    required this.preview,
    required this.date,
    required this.onEdit,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          Text(
            preview,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  date,
                  style: AppTypography.caption,
                ),
              ),
              IconButton(
                onPressed: onCopy,
                tooltip: 'کپی',
                visualDensity:
                VisualDensity.compact,
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 19,
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'ویرایش',
                visualDensity:
                VisualDensity.compact,
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 19,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'حذف',
                visualDensity:
                VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}