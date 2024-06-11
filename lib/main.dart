import 'package:desktop/auth/login.dart';
import 'package:desktop/screens/firstpage.dart';
import 'package:desktop/url_protocol/api.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:desktop/screens/global.dart';
import 'package:flutter/services.dart';

final FocusNode _focusNode = FocusNode();
const kWindowsScheme = 'brihan';
final Uri _url = Uri.parse('http://localhost:8000');
void main() {
  _registerWindowsProtocol();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _launchUrl() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  String route = "";

  @override
  void initState() {
    super.initState();
    initDeepLinks();

    _launchUrl();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
    _focusNode.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.keyQ)) {
      // Exit the app when 'Ctrl + Q' (or 'Cmd + Q' on macOS) is pressed
      SystemNavigator.pop();
    }
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('onAppLink: $uri');

      extractUriValues(uri.toString());

      print('Route: $route');
      print('Param Value: $paramValue');
      print('paramerter: ${uri.fragment}');
      openAppLink(uri);
    });
  }

  void extractUriValues(String uriString) {
    final Uri uri = Uri.parse(uriString);
    final String route = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    paramValue = uri.queryParameters['param'] ?? '';

    paramValue = paramValue.split("accessToken=")[1];

    print('Extracted Route: $route');
    print('Extracted Param Value: $paramValue');
  }

  void openAppLink(Uri uri) {
    final route = uri.path; // Get the path from the URI
    final queryParams =
        uri.queryParameters; // Get the query parameters from the URI

    _navigatorKey.currentState?.pushNamed(route, arguments: queryParams);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FMainpage(),
        onGenerateRoute: (settings) {
          final Uri uri = Uri.parse(settings.name ?? '');

          switch (uri.path) {
            case '/firstpage':
              return MaterialPageRoute(
                builder: (context) => FMainpage(),
              );
            case '/secondpage':
              return MaterialPageRoute(
                builder: (context) => Login(),
              );

            // Add other routes here
            default:
              return MaterialPageRoute(
                builder: (context) =>
                    MyHomePage(title: 'Flutter Demo Home Page'),
              );
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter',
                style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _registerWindowsProtocol() {
  if (!kIsWeb) {
    if (Platform.isWindows) {
      registerProtocolHandler(kWindowsScheme);
    }
  }
}

// class FMainpage extends StatelessWidget {
//   final Map<String, dynamic>? arguments;

//   FMainpage({Key? key, this.arguments}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Use the arguments passed from the deep link
//     final String? param = arguments?['param'];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('First Page'),
//       ),
//       body: Center(
//         child: Text('Parameter: $param'),
//       ),
//     );
//   }
// }
