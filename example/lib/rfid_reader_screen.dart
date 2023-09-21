import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_event_handler.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_rfid_sdk_plugin.dart';

class RfidReaderScreen extends StatefulWidget {
  const RfidReaderScreen({super.key});

  @override
  State<RfidReaderScreen> createState() => _RfidReaderScreenState();
}

class _RfidReaderScreenState extends State<RfidReaderScreen> {
  String? _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Map<String?, RfidData> rfidDataMap = {};
  ReaderConnectionStatus connectionStatus = ReaderConnectionStatus.UnConnection;

  addData(List<RfidData> dataList) async {
    for (var item in dataList) {
      var data = rfidDataMap[item.tagID];
      if (data != null) {
        data.count;
        data.count = data.count + 1;
        data.peakRSSI = item.peakRSSI;
        data.relativeDistance = item.relativeDistance;
      } else {
        rfidDataMap.addAll({item.tagID: item});
      }
    }
    setState(() {});
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ZebraRfidSdkPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status  ${connectionStatus.name}'),
      ),
      bottomSheet:
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        MaterialButton(
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            ZebraRfidSdkPlugin.setEventHandler(ZebraEngineEventHandler(
              readRfidCallback: (dataList) async {
                addData(dataList);
              },
              errorCallback: (err) {
                ZebraRfidSdkPlugin.toast(err.errorMessage);
              },
              connectionStatusCallback: (status) {
                setState(() {
                  connectionStatus = status;
                });
              },
            ));
            ZebraRfidSdkPlugin.connect(hostName: "");
          },
          child: Text("start".toUpperCase()),
        ),
        MaterialButton(
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            setState(() {
              rfidDataMap = {};
            });
          },
          child: Text("clear".toUpperCase()),
        ),
        MaterialButton(
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            ZebraRfidSdkPlugin.disconnect();
          },
          child: Text("stop".toUpperCase()),
        ),
      ]),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            Text('count:${rfidDataMap.length.toString()}'),
            const SizedBox(height: 20),
            Expanded(
                child: Scrollbar(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var key = rfidDataMap.keys.toList()[index];
                  return ListTile(title: Text(rfidDataMap[key]?.tagID ?? 'null'));
                },
                itemCount: rfidDataMap.length,
              ),
            ))
          ],
        ),
      )),
    );
  }
}
