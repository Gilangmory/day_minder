import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notes_controller.dart';
import '../../../data/note_model.dart';

class NotesView extends GetView<NotesController> {
  const NotesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Notes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Get.toNamed('/add');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.notes.isEmpty) {
            return Center(
              child: Text('No notes available',
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: controller.notes.length,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemBuilder: (context, index) {
              final Note note = controller.notes[index];
              return _buildNoteItem(note, context);
            },
          );
        }),
      ),
    );
  }

  Widget _buildNoteItem(Note note, BuildContext context) {
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showConfirmationDialog(context, note);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _showNoteDetails(context, note),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple, Colors.deepPurple.shade300],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(note.title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 8),
              Text('Due Date: ${note.dueDate}',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
              SizedBox(height: 8),
              Align(
                  alignment: Alignment.bottomRight,
                  child: _buildStatusBadge(context, note)),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context, Note note) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            'Confirm Action',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple),
          ),
          content: Text(
            'Choose your action for this note.',
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Edit', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop(false);
                Get.toNamed('/add', arguments: note);
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(context)
                    .pop(false); // Jika dikonfirmasi, dismiss item
                // Tampilkan dialog konfirmasi penghapusan
                await _showDeleteConfirmationDialog(context, note.id);
              },
            ),
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(false); // Jangan dismiss item
              },
            ),
          ],
        );
      },
    );

    return result ?? false; // Jika result adalah null, kembalikan false
  }

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, int? id) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text(
                  'Are you sure you want to delete this note? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Jangan hapus item
                  },
                ),
                TextButton(
                  child:
                      Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    controller.deleteNote(id);
                    Navigator.of(context).pop(true); // Hapus item
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Jika result adalah null, kembalikan false
  }

  void _showNoteDetails(BuildContext context, Note note) {
    final dueDate = DateTime.parse(note.dueDate);
    final today = DateTime.now();
    // Mengatur waktu hari ini ke awal hari untuk perbandingan yang akurat
    final todayStart = DateTime(today.year, today.month, today.day);
    final daysLeft = dueDate.difference(todayStart).inDays;

    String badgeText;
    Color badgeColor;

    if (dueDate.isBefore(todayStart)) {
      badgeText = 'Passed';
      badgeColor = Colors.red;
    } else {
      badgeText = daysLeft > 0 ? '$daysLeft days left' : 'Today';
      badgeColor = daysLeft > 0 ? Colors.green : Colors.orange;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Mengatur ukuran modal
          child: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title:',
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  Text(note.title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text('Description:',
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Text(note.description, style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 20),
                  Text('Due Date:',
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  Text(note.dueDate, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(badgeText,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, Note note) {
    final dueDate = DateTime.parse(note.dueDate);
    final today = DateTime.now();
    // Mengatur waktu hari ini ke awal hari untuk perbandingan yang akurat
    final todayStart = DateTime(today.year, today.month, today.day);
    final daysLeft = dueDate.difference(todayStart).inDays;

    String statusText;
    Color badgeColor;

    if (dueDate.isBefore(todayStart)) {
      statusText = 'Passed';
      badgeColor = Colors.red;
    } else {
      statusText = daysLeft > 0 ? '$daysLeft days left' : 'Today';
      badgeColor = daysLeft > 0 ? Colors.green : Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(statusText,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }
}
