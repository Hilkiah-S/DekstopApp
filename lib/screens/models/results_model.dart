import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AllResults {
  final int resultId;
  final String examName;
  final int result;
  AllResults({
    required this.resultId,
    required this.examName,
    required this.result,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'resultId': resultId,
      'examName': examName,
      'result': result,
    };
  }

  factory AllResults.fromMap(Map<String, dynamic> map) {
    return AllResults(
      resultId: map['resultId'] as int,
      examName: map['examName'] as String,
      result: map['result'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory AllResults.fromJson(String source) => AllResults.fromMap(json.decode(source) as Map<String, dynamic>);
}
