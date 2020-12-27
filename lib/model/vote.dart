class Vote {
  final int roomId;
  final int candidateId;
  int total;

  Vote(this.roomId, this.candidateId, this.total);

  Vote.fromJson(Map<String, dynamic> json)
      : roomId = json['room_id'],
        candidateId = json['candidate_id'],
        total = json['total'];

  Map<String, dynamic> toJson() =>
      {'room_id': roomId, 'candidate_id': candidateId, 'total': total};
}
