import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task; // null = add mode, non-null = edit mode

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _selectedDate = widget.task!.date;
      _dateCtrl.text = _formatDate(_selectedDate);
    } else {
      _dateCtrl.text = _formatDate(_selectedDate);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = _formatDate(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      if (_isEditing) {
        final updated = widget.task!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          date: _selectedDate,
        );
        await _firestoreService.updateTask(updated);
      } else {
        final newTask = TaskModel(
          id: '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          date: _selectedDate,
          isDone: false,
          userId: userId,
          createdAt: DateTime.now(),
        );
        await _firestoreService.addTask(newTask);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                Text(
                  _isEditing ? 'Update your task' : 'What do you need to do?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 6),
                const Text(
                  'Fill in the details below to save your task.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMid),
                ),

                const SizedBox(height: 32),

                CustomTextField(
                  controller: _titleCtrl,
                  label: 'Title',
                  hint: 'e.g. Complete project report',
                  prefixIcon: Icons.title_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    if (val.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  hint: 'Add more details about the task...',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 4,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please add a description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _dateCtrl,
                  label: 'Due Date',
                  hint: 'DD/MM/YYYY',
                  prefixIcon: Icons.calendar_today_rounded,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please pick a date';
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                LoadingButton(
                  isLoading: _isLoading,
                  label: _isEditing ? 'Update Task' : 'Add Task',
                  onPressed: _handleSubmit,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
