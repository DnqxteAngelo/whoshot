// ignore_for_file: unnecessary_this, unnecessary_new, prefer_collection_literals, file_names, non_constant_identifier_names

class Session {
  DateTime? nomination_start;
  DateTime? nomination_end;
  DateTime? voting_start;
  DateTime? voting_end;

  Session(
      {this.nomination_start,
      this.nomination_end,
      this.voting_start,
      this.voting_end});

  Session.fromJson(Map<String, dynamic> json) {
    nomination_start = DateTime.parse(json['nomination_start']);
    nomination_end = DateTime.parse(json['nomination_end']);
    voting_start = DateTime.parse(json['voting_start']);
    voting_end = DateTime.parse(json['voting_end']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomination_start'] = this.nomination_start;
    data['nomination_end'] = this.nomination_end;
    data['voting_start'] = this.voting_start;
    data['voting_end'] = this.voting_end;
    return data;
  }
}
