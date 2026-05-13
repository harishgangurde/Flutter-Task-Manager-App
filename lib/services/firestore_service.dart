// services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of tasks for the current user
  Stream<List<TaskModel>> getUserTasks(String userId) {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final tasks = snap.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList();

          // Sort latest tasks first
          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return tasks;
        });
  }

  // Add new task
  Future<void> addTask(TaskModel task) async {
    await _db.collection('tasks').add(task.toMap());
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    await _db.collection('tasks').doc(task.id).update(task.toMap());
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  // Toggle task status
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await _db.collection('tasks').doc(taskId).update({
      'isDone': !currentStatus,
    });
  }
}
