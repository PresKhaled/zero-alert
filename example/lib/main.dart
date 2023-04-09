import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:simple_alert/simple_alert.dart';

void main() {
  SimpleAlertPreferences(
    // duration: SimpleAlertDuration.day,
    icons: const SimpleAlertIcons(
      normal: FluentIcons.chat_24_regular,
      success: FluentIcons.checkmark_circle_24_regular,
      info: FluentIcons.info_24_regular,
      warning: FluentIcons.warning_24_regular,
      danger: FluentIcons.error_circle_24_regular,
    ),
  );

  runApp(const SimpleAlertExample());
}

class SimpleAlertExample extends StatelessWidget {
  const SimpleAlertExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextStyle titleStyle = const TextStyle(fontSize: 18.0);
  final double spacing = 5.0;
  final List<SimpleAlertType> alertTypes = [
    SimpleAlertType.normal,
    SimpleAlertType.success,
    SimpleAlertType.info,
    SimpleAlertType.warning,
    SimpleAlertType.danger,
  ];
  ValueNotifier<bool> dataReceived = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 5),
      () {
        dataReceived.value = true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple alert'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Light theme',
                style: titleStyle,
              ),
              Wrap(
                spacing: spacing,
                children: <Widget>[
                  // Alert types.
                  ...List.generate(
                    alertTypes.length,
                    (int index) => ElevatedButton(
                      onPressed: () => SimpleAlert(
                        context: context,
                        type: alertTypes[index],
                        brightness: Brightness.light,
                        title: 'Simple alert title',
                        description: 'Some words describe the work performed',
                        closeOnPress: false,
                        withClose: true,
                      ),
                      child: Text(
                        alertTypes[index].toString().split('.').last, // .toUpperCase(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),
              Text(
                'Dark theme',
                style: titleStyle,
              ),
              Wrap(
                spacing: spacing,
                children: <Widget>[
                  // Alert types.
                  ...List.generate(
                    alertTypes.length,
                    (int index) => ElevatedButton(
                      onPressed: () => SimpleAlert(
                        context: context,
                        type: alertTypes[index],
                        brightness: Brightness.dark,
                        title: 'Simple alert title',
                        description: 'Some words describe the work performed',
                        closeOnPress: false,
                        withClose: true,
                      ),
                      child: Text(
                        alertTypes[index].toString().split('.').last,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),
              Text(
                'Other',
                style: titleStyle,
              ),
              Wrap(
                spacing: spacing,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => SimpleAlert(
                      context: context,
                      title: 'Simple alert title',
                      description: 'Some words describe the work performed',
                    ),
                    child: Text('Close on press'),
                  ),
                  ElevatedButton(
                    onPressed: () => SimpleAlert(
                      context: context,
                      title: 'Simple alert title',
                      description: 'Some words describe the work performed',
                      closeOnPress: false,
                      withClose: true,
                      withProgressBar: true,
                    ),
                    child: Text('Progress bar'),
                  ),
                  ElevatedButton(
                    onPressed: () => SimpleAlert(
                      context: context,
                      title: 'Simple alert title',
                      duration: SimpleAlertDuration.day,
                      removalSignal: dataReceived,
                    ),
                    child: Text('Removal signal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
