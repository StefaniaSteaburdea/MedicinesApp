import 'dart:convert';
import 'dart:typed_data';

import 'package:blind/BluetoothEnable.dart';
import 'package:blind/firestore_service.dart';
import 'package:blind/medicine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:blind/edit.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:blind/medicine_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
     final firestoreService=FirestoreService();
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create:(context)=>MedicineProvider()),
          StreamProvider(create: (context)=>firestoreService.getMedicine()),
        ],
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: new MyHomePage(),
        ));
      
  }
}

class MyHomePage extends StatefulWidget{
  final BluetoothDevice server;
   MyHomePage([this.server]);
  @override
  _MyHomePageState createState()=>new _MyHomePageState();

}
class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}
class _MyHomePageState extends State<MyHomePage>{
   FlutterTts tts = FlutterTts();
  BluetoothConnection connection;
  List<_Message> messages = [];
  String _messageBuffer = '';
  String sw="2";
  String code='';
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
   Future<void> runTextToSpeech(String currentTtsString, double currentSpeechRate) async {
  FlutterTts flutterTts;
  flutterTts = new FlutterTts();
  await flutterTts.awaitSpeakCompletion(true);
  await flutterTts.setLanguage("en-GB");
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
  await flutterTts.isLanguageAvailable("en-GB");
  await flutterTts.setSpeechRate(1.0);
  await flutterTts.speak(currentTtsString);
}
  @override
  void initState() {
    super.initState();
    if(widget.server!=null)
    {
    BluetoothConnection.toAddress(widget.server.address).then((_connection) async {
      runTextToSpeech('Connected to the device'+widget.server.name,1.2);
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      connection.output.add(utf8.encode('Hello!'));
      await connection.output.allSent;
      connection.input.listen(_onDataReceived).onDone(() {

        if (isDisconnecting) {
          runTextToSpeech("Disconnecting locally!",1.2);
        } else {
          runTextToSpeech("Disconnected remotely!",1.2);
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      runTextToSpeech('Cannot connect, exception occured',1.2);
      print(error);
    });
  }}

   void _sendMessage(String text) async {
     //text = text.trim();
     textEditingController.clear();
     if (text.length > 0) {
       try {
         connection.output.add(utf8.encode(text + "\r\n"));
         await connection.output.allSent;
         Future.delayed(Duration(milliseconds: 333)).then((_) {
           listScrollController.animateTo(
               listScrollController.position.maxScrollExtent,
               duration: Duration(milliseconds: 333),
               curve: Curves.easeOut);
         });
       } catch (e) {
         // Ignore error, but notify state
         setState(() {});
       }
     }}
void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;
    print("Buffer"+bufferIndex.toString());

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
    print(buffer);

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    //read the first command
   // runTextToSpeech(_messageBuffer, 1.2);

              
                 if(_messageBuffer=="twirl"){
                    sw="2";
                    _messageBuffer='';
                    runTextToSpeech("Usage", 1.2);
                    }
                 else
                 if(_messageBuffer=="left-right"){
                    sw="3";
                    _messageBuffer='';
                    runTextToSpeech("Dose", 1.2);
                    }
                 else{
                     code=_messageBuffer;
                     _messageBuffer='';
                     runTextToSpeech("Code", 1.2);
                 }
            
  }
  @override
  Widget build(BuildContext context){
        String readName(List<Medicine> med, String uid){
          int i;
          for(i=0;i<med.length;i++)
          {
            if(med[i].productId==uid)
              return med[i].name;
          }
          return "Not found";
        }
        String readUsage(List<Medicine> med, String uid){
          int i;
          for(i=0;i<med.length;i++)
          {
            if(med[i].productId==uid)
              return med[i].name+" "+med[i].usage;
          }
          return "Not found";
        }
        String readDose(List<Medicine> med, String uid){
          int i;
          for(i=0;i<med.length;i++)
          {
            if(med[i].productId==uid)
              return med[i].name+" "+med[i].quantity;
          }
          return "Not found";
        }
    final medicines=Provider.of<List<Medicine>>(context);
    return new Scaffold(
      backgroundColor: Colors.red[300],
      body:
       MaterialButton(
        minWidth:  (MediaQuery.of(context).size.width),
        height: (MediaQuery.of(context).size.height),
        child: Container(
            width: (MediaQuery.of(context).size.width),
            height: (MediaQuery.of(context).size.height),
             child:
                Icon(
                    Icons.volume_up,
                    size:80,
                    color: Colors.white,
                  )
                ),   
           
           onPressed: (){
                 
                   if(sw=="2"){
                    //runTextToSpeech(readName(medicines,code),1.2);
                    runTextToSpeech(readUsage(medicines,code),1.2);
                    }
                    else 
                      if(sw=="3"){
                        // runTextToSpeech(readName(medicines,code),1.2);
                         runTextToSpeech(readDose(medicines,code),1.2);
                      }
            } ,
           )
           ,
           bottomNavigationBar:  Container(
                width: (MediaQuery.of(context).size.width),
                child:Row(children: [
                 MaterialButton(
                   height: 80,
                   minWidth: (MediaQuery.of(context).size.width*1/2),
                   onPressed:()async{
                     if(connection!=null)
                     {await connection.finish();
                     setState(() {
                       isConnecting = false;
                       isDisconnecting = true;
                     });}
                     runTextToSpeech("Medicines management", 1.2);
                    Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context)=>MyEdit(widget.server)
                        )
                    );
                   },
                   splashColor: Colors.brown[700],
                   color: Colors.brown[700],
                   child: Text(
                    'Medicines\n management',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
        
             )),
              MaterialButton(
                   height: 80,
                   minWidth: (MediaQuery.of(context).size.width*1/2),
                   onPressed:(){
                     runTextToSpeech("Bluetooth connection", 1.2);
                     Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context)=>MyBluetoothEnable()
                        )
                    );
                   },
                   splashColor: Colors.brown[700],
                   color: Colors.brown[700],
                   child: Text(
                    'Bluetooth\n connection',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
        
             )),
                ],) )
        );
  }
}

