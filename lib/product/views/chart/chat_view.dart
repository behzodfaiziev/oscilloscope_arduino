import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'chart_model.dart';

class ChartView extends StatefulWidget {
  final BluetoothDevice server;

  const ChartView({super.key, required this.server});

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  BluetoothConnection? connection;
  String _messageBuffer = '';

  bool isConnecting = true;
  bool isDisconnecting = false;

  bool get isConnected => connection != null && connection!.isConnected;

  List<ChartModel> signalData = [];
  ChartSeriesController? _analogChartController;
  ChartSeriesController? _digitalChartController;
  ChartSeriesController? _analogReferenceChartController;
  int time = 0;
  int frequenceValue = 100;
  bool isHighValue = false;

  @override
  void initState() {
    super.initState();

    time = frequenceValue;
    for (int i = 0; i <= frequenceValue; i++) {
      signalData.add(ChartModel(time: i, digitalSignal: 0, analogSignal: 0));
    }

    BluetoothConnection.toAddress(widget.server.address).then((newConnection) {
      print('Connected to the device');
      connection = newConnection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection?.input?.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting!');
        } else {
          print('Disconnected!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('An error occurred');
      print(error);
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Mobile Oscilloscope"),
          automaticallyImplyLeading: true),
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 24, bottom: 12),
                child: const Text(
                  'Analog signal',
                  style: TextStyle(color: Colors.white),
                )),
            SfCartesianChart(
              backgroundColor: Theme.of(context).cardColor,
              series: [
                LineSeries<ChartModel, int>(
                  legendItemText: "Analog",
                  isVisibleInLegend: true,
                  xAxisName: 'Time',
                  color: Colors.blue,
                  onRendererCreated: (ChartSeriesController controller) {
                    _analogChartController = controller;
                  },
                  dataSource: signalData,
                  xValueMapper: (ChartModel data, _) =>
                      data.time! - frequenceValue,
                  yValueMapper: (ChartModel data, _) => data.analogSignal,
                ),
                LineSeries<ChartModel, int>(
                  color: Colors.red,
                  onRendererCreated: (ChartSeriesController controller) {
                    _analogReferenceChartController = controller;
                  },
                  dataSource: signalData,
                  yValueMapper: (ChartModel data, _) => data.analogRefSignal,
                  xValueMapper: (ChartModel data, _) =>
                      data.time! - frequenceValue,
                ),
              ],
            ),
            Container(
                margin: const EdgeInsets.only(top: 24, bottom: 12),
                child: const Text(
                  'Digital signal',
                  style: TextStyle(color: Colors.white),
                )),
            SfCartesianChart(
              backgroundColor: Theme.of(context).cardColor,
              series: [
                LineSeries<ChartModel, int>(
                  color: Colors.orange,
                  onRendererCreated: (ChartSeriesController controller) {
                    _digitalChartController = controller;
                  },
                  dataSource: signalData,
                  xValueMapper: (ChartModel data, _) =>
                      data.time! - frequenceValue,
                  yValueMapper: (ChartModel data, _) => data.digitalSignal,
                  // yValueMapper: (ChartModel data, _) {
                  //   isHighValue = data.analogSignal! > reference ? true : false;
                  //   return data.analogSignal! > reference ? 1 : 0;
                  // },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);

    if (~index != 0) {
      String gottenData = backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index);

      List<String> parsedListOfString = gottenData.split(',');

      int parsedAnalogValue = int.tryParse(parsedListOfString[0]) ?? 0;
      int parsedDigitalValue = int.tryParse(parsedListOfString[1]) ?? 0;
      int parsedAnalogRefValue = int.tryParse(parsedListOfString[2]) ?? 0;

      int roundedAnalogValue = (parsedAnalogValue / 10).round();
      int roundedAnalogRefValue = (parsedAnalogRefValue / 10).round();

      setState(() {
        signalData.add(ChartModel(
          time: time++,
          analogSignal: roundedAnalogValue,
          analogRefSignal: roundedAnalogRefValue,
          digitalSignal: parsedDigitalValue,
        ));
        signalData.removeAt(0);
        _messageBuffer = dataString.substring(index);
      });

      if (_analogChartController != null) {
        _analogChartController!.updateDataSource(
            addedDataIndex: signalData.length - 1, removedDataIndex: 0);
      }

      if (_analogReferenceChartController != null) {
        _analogReferenceChartController!.updateDataSource(
            addedDataIndex: signalData.length - 1, removedDataIndex: 0);
      }
      if (_digitalChartController != null) {
        _digitalChartController!.updateDataSource(
            addedDataIndex: signalData.length - 1, removedDataIndex: 0);
      }
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
