// ignore_for_file: unnecessary_this, unnecessary_new, prefer_collection_literals, file_names

class Votes {
  int? id;
  String? name;
  String? imageUrl;
  String? gender;
  int? totalVotes;
  DateTime? time;

  Votes(
      {this.id,
      this.name,
      this.imageUrl,
      this.gender,
      this.totalVotes,
      this.time});

  Votes.fromJson(Map<String, dynamic> json) {
    id = json['nomination_id'];
    name = json['nomination_name'];
    imageUrl =
        'http://localhost/whoshot/lib/api/images/${json['nomination_imageUrl']}';
    gender = json['nomination_gender'];
    totalVotes = json['total_votes'];
    time = DateTime.parse(json['nomination_time']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['gender'] = this.gender;
    data['totalVotes'] = this.totalVotes;
    data['time'] = this.time;
    return data;
  }
}
