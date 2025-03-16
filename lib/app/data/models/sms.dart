class SMS {
  final String id;
  final String body;
  final String sender;
  final DateTime date;

  SMS({
    required this.id,
    required this.body,
    required this.sender,
    required this.date,
  });

  factory SMS.fromJson(Map<String, dynamic> json) {
    return SMS(
      id: json['id'] ?? '',
      body: json['body'] ?? '',
      sender: json['sender'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(json['date'].toString()) ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'sender': sender,
      'date': date.millisecondsSinceEpoch,
    };
  }
}
