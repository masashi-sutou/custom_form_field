import 'package:custom_form_field/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'Custom Form Field Sample',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  String _title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formState,
      child: CustomFormField(
        value: _title,
        label: '今年の総括',
        maxLines: 1,
        maxLength: 20,
        decoration: InputDecoration(
          hintText: '今年はどんな一年でしたか？🤔',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
          ),
          suffixIcon: Icon(Icons.keyboard_arrow_down),
          suffixIconConstraints: BoxConstraints(),
        ),
        validator: (value) {
          if (value?.isEmpty ?? false) {
            return 'なにか入力してね 😢';
          }
          return null;
        },
        onSaved: (value) {
          setState(() {
            _title = value;
          });
        },
      ),
    );
  }
}
