import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/note_model.dart';
import '../../../data/notes_service.dart';

class NotesController extends GetxController {
  final NotesService _notesService = Get.put(NotesService());
  var selectedDate = DateTime.now().obs;
  var notes = <Note>[].obs;

  @override
  void onInit() {
    super.onInit();
    getAllNotes();
  }

  Future<void> getAllNotes() async {
    await _notesService.getNotes();
    notes.value = _notesService.notes;
  }

  void showSnackbar(bool isSuccess, String message) {
    Get.snackbar(
      isSuccess ? "Berhasil" : "Gagal",
      message,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 5),
    );
  }

  void addNote(String title, String description, int? id) async {
    Note newNote = Note(
      title: title,
      description: description,
      dueDate: DateFormat('yyyy-MM-dd').format(selectedDate.value),
      status: Note.STATUS_ON,
    );
    if (id == null) {
      await _notesService.addNote(newNote);
      showSnackbar(true, "Catatan berhasil ditambahkan");
      print("Tambah Data Berhasil");
    } else {
      newNote.id = id;
      await _notesService.updateNote(newNote);
      showSnackbar(true, "Catatan berhasil diperbarui");
      print("Edit Data Berhasil");
    }
    await getAllNotes();
  }

  void deleteNote(int? id) async {
    if (id != null) {
      await _notesService.deleteNote(id);
      showSnackbar(true, "Catatan berhasil dihapus");
      print("Delete Data Berhasil");
    } else {
      showSnackbar(false, "Gagal menghapus catatan");
      print("Delete Data Gagal");
    }
  }
}
