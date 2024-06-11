import 'package:desktop/screens/global.dart';
import 'package:desktop/screens/models/results_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  FlutterTts flutterTts = FlutterTts();
  List<AllResults> results = [];
  final FocusNode _focusNode = FocusNode();
  final FocusNode _backButtonFocusNode = FocusNode();

  void _sendCode() async {
    Response response =
        await Dio().post('http://localhost:4000/result/getPublished',
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer ${paramValue} ',
              },
            ));

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      print(response.data);
      List<dynamic> responseData = response.data as List<dynamic>;
      results = responseData.map<AllResults>((dataItem) {
        return AllResults.fromMap(dataItem as Map<String, dynamic>);
      }).toList();
      setState(() {});
    } else {
      throw Exception(
          'Failed to load questions with status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    flutterTts.stop();
    flutterTts.speak("Your Results page");
    _sendCode();
    _backButtonFocusNode.addListener(_handleBackButtonFocus);
  }

  void _handleBackButtonFocus() {
    if (_backButtonFocusNode.hasFocus) {
      flutterTts.speak("Back");
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _backButtonFocusNode.removeListener(_handleBackButtonFocus);
    _focusNode.dispose();
    _backButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        foregroundColor: Colors.white,
        leading: Focus(
          focusNode: _backButtonFocusNode,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text(
          "Your Results",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF121212),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return Focus(
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              flutterTts.speak(
                                "Your result for ${results[index].examName}, is ${results[index].result}",
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[850],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.all(16.0),
                              ),
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    results[index].examName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    results[index].result.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
