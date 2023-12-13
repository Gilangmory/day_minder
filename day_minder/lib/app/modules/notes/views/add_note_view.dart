import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/notes_controller.dart';
import '../../../data/note_model.dart';

class AddNoteView extends GetView<NotesController> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  var id = null;

  AddNoteView({Key? key}) : super(key: key) {
    // Menangkap argumen dan memasukkannya ke dalam controller
    final Note? note = Get.arguments as Note?;
    if (note != null) {
      id = note.id;
      _titleController.text = note.title;
      _descriptionController.text = note.description;
      // Jika Anda juga ingin mengatur selectedDate di controller, Anda bisa melakukannya di sini
      controller.selectedDate.value =
          DateFormat('yyyy-MM-dd').parse(note.dueDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Add New Note' : 'Edit Note',
            style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInputField(
                label: 'Title',
                controller: _titleController,
                theme: theme,
              ),
              SizedBox(height: 16),
              _buildTextArea(
                label: 'Description',
                controller: _descriptionController,
                theme: theme,
              ),
              SizedBox(height: 16),
              _buildDatePicker(context, theme),
              SizedBox(height: 24),
              _buildSubmitButton(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.note, color: theme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, ThemeData theme) {
    return Obx(() => ListTile(
          title: Text(
              'Due Date: ${DateFormat('yyyy-MM-dd').format(controller.selectedDate.value)}',
              style: TextStyle(color: theme.primaryColor)),
          trailing: Icon(Icons.calendar_today, color: theme.primaryColor),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: controller.selectedDate.value,
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
              // Tambahkan tema khusus untuk DatePicker di sini
            );
            if (picked != null && picked != controller.selectedDate.value) {
              controller.selectedDate.value = picked;
            }
          },
        ));
  }

  Widget _buildSubmitButton(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: theme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: TextStyle(fontSize: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Colors.white),
          SizedBox(width: 8),
          Text(id == null ? 'Add Note' : 'Edit Note',
              style: TextStyle(color: Colors.white)),
        ],
      ),
      onPressed: () {
        // Menambahkan note baru ke controller
        controller.addNote(
            _titleController.text, _descriptionController.text, id);

        // Opsional: Kembali ke halaman sebelumnya setelah menambahkan note
        Get.back();
      },
    );
  }
}
