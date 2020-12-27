class Room {
  final int id;
  final String name;
  final String description;
  final String code;
  final String status;
  int validVote;
  int invalidVote;
  int totalVote;

  Room(this.id, this.name, this.description, this.code, this.status,
      this.validVote, this.invalidVote, this.totalVote);

  Room.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['room_name'],
        description = json['description'],
        code = json['code'],
        status = json['status'],
        validVote = json['valid_vote'],
        invalidVote = json['invalid_vote'],
        totalVote = json['total_vote'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'code': code,
        'status': status
      };
}
