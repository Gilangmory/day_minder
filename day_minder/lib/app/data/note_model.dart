class Note {
  static const int STATUS_ON = 0;
  static const int STATUS_OFF = 1;

  int? id;
  String title;
  String description;
  String dueDate;
  int status; // Misalnya, 0 untuk belum selesai, 1 untuk selesai

  Note({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
  });

  // Membuat objek Note dari Map (biasanya digunakan saat membaca data dari database)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'],
      status: map['status'],
    );
  }

  // Mengonversi objek Note menjadi Map (untuk menyimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'status': status,
    };
  }
}
