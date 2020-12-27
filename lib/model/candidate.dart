import 'package:pps/constant.dart';

class Candidate {
  final int id;
  final String name;
  final String image;
  final int order;
  final int totalVote;
  final dynamic percentage;

  Candidate(this.id, this.name, this.image, this.order, this.totalVote,
      this.percentage);

  Candidate.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        image = imageUrl(json['image']),
        order = json['order'],
        totalVote = json['total_vote'],
        percentage = json['percentage'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'order': order,
        'total_vote': totalVote,
        'percentage': percentage
      };
}

String imageUrl(val) {
  return val != null
      ? "$API_ENDPOINT$val"
      : "$API_ENDPOINT/image/default-user.jpg";
}
