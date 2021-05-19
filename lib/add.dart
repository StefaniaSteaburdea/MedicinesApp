import 'dart:convert';
import 'dart:typed_data';

import 'package:blind/edit.dart';
import 'package:blind/medicine.dart';
import 'package:blind/medicine_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

class MyAdd extends StatefulWidget{
  final Medicine medicine;
  final BluetoothDevice server;
  MyAdd([this.medicine,this.server]);
  @override
  _MyAddState createState()=>new _MyAddState();
}
class _MyAddState extends State<MyAdd>{

  MedicineProvider x;
  int sw=0;
  List<Medicine> newList;
  final nameController= TextEditingController();
  final usageController=TextEditingController();
  final quantityController=TextEditingController();
  FlutterTts tts = FlutterTts();
  BluetoothConnection connection;
  String _messageBuffer = '';
  String code='';
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
  void dispose()
  {
    nameController.dispose();
    usageController.dispose();
    quantityController.dispose();
    super.dispose();
  }
  @override
  void initState(){
    if(widget.medicine==null){
      nameController.text="";
      usageController.text="";
      quantityController.text="";
       new Future.delayed(Duration.zero,(){
            final medicineProvider=Provider.of<MedicineProvider>(context,listen: false);
            medicineProvider.loadValues(Medicine());
      });
    }
    else {
      
      nameController.text=widget.medicine.name;
      usageController.text=widget.medicine.usage;
      quantityController.text=widget.medicine.quantity;

      new Future.delayed(Duration.zero,(){
            final medicineProvider=Provider.of<MedicineProvider>(context,listen: false);
            medicineProvider.loadValues(widget.medicine);
      });
    }
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
    }
  }
  void _onDataReceived(Uint8List data) async{
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
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    //read the first command
      //runTextToSpeech(_messageBuffer, 1.2);
      code = _messageBuffer;
      _messageBuffer = '';
      if(sw==1&&code!=''){
        runTextToSpeech('code received', 1.2);
        //verific daca exista deja in baza de date.
        if(valid(code,newList)!=0){
             x.changeProductID(code);
        x.toSave();
        if(connection!=null)
                     {await connection.finish();
                     setState(() {
                       isConnecting = false;
                       isDisconnecting = true;
                     });}
        Navigator.of(context)
            .push(
            MaterialPageRoute(
                builder: (context)=>MyEdit(widget.server)
            )
        );
        }
        else
        runTextToSpeech("This tag is already written. Please delete the medicine or choose another tag.", 1.2);
      }
    }

  @override
  Widget build(BuildContext context){
   final medicineProvider=Provider.of<MedicineProvider>(context);
   final medicines=Provider.of<List<Medicine>>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[700], title: Text('Add medicines'),
        automaticallyImplyLeading : false,
        actions:  <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: IconButton(
                   icon: Icon( Icons.arrow_back,),
                    onPressed:()async{
                      if(connection!=null)
                     {await connection.finish();
                     setState(() {
                       isConnecting = false;
                       isDisconnecting = true;
                     });}
                    Navigator.of(context)
                      .push(
                       MaterialPageRoute(
                         builder: (context)=>MyEdit(widget.server)
                          )
                          );
                          }),
            )

        ]
      ),
      body:Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(32),

             children:<Widget>[
               Text('\n'),
               Image(
                      image: AssetImage('assets/pills-background.png'),
                      height: 80),
               Text('\n'),
               TextField(
                 keyboardType: TextInputType.text,
                 onChanged:(value){
                   medicineProvider.changeName(value);
                 },
                 controller: nameController,
                 decoration: InputDecoration(
                   
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                   hintText: 'Name',
                   filled: true,
                   fillColor: Colors.grey[200])
               ),
               Text('\n'),
               TextField(
                 keyboardType: TextInputType.multiline,
                 maxLines: 6,
                 onChanged:(value){
                    medicineProvider.changeUsage(value);
                 },
                 controller: usageController,
                 decoration: InputDecoration(
                   
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                   hintText: 'Usage',
                   filled: true,
                   fillColor: Colors.grey[200])
               ),
               Text('\n'),
               TextField(
                 keyboardType: TextInputType.multiline,
                 maxLines: 2,
                 onChanged:(value){
                    medicineProvider.changeQuantity(value);
                   
                 },
                 controller: quantityController,
                 decoration: InputDecoration(
                   
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                   hintText: 'Quantity',
                   filled: true,
                   fillColor: Colors.grey[200])
               ),
               Text('\n'),
               Container(
                 width:60,
               child:MaterialButton(
                   height: 50,
                   minWidth: 60,
                   onPressed: ()async{
                     
                       if(widget.medicine==null&&code!='') {
                         if(valid(code,medicines)!=0){
                         medicineProvider.changeProductID(code);
                         medicineProvider.toSave();
                         if(connection!=null)
                     {await connection.finish();
                     setState(() {
                       isConnecting = false;
                       isDisconnecting = true;
                     });}
                         Navigator.of(context)
                             .push(
                             MaterialPageRoute(
                                 builder: (context)=>MyEdit(widget.server)
                             )
                         );}
                         else
                         runTextToSpeech("This tag is already written. Please delete the medicine or choose another tag.", 1.2);
                        }
                       else
                       if(widget.medicine!=null){
                         medicineProvider.toSave();
                         if(connection!=null)
                     {await connection.finish();
                     setState(() {
                       isConnecting = false;
                       isDisconnecting = true;
                     });}
                         Navigator.of(context)
                             .push(
                             MaterialPageRoute(
                                 builder: (context)=>MyEdit(widget.server)
                             )
                         );
                       }
                       else
                       {
                         runTextToSpeech('Please add a tag', 1.2);
                         sw=1;
                         x=medicineProvider;
                         newList=medicines;
                       }
                   },
                   splashColor: Colors.brown[600],
                   color: Colors.brown[700],
                   child: Text(
                        'Add',
                        style: TextStyle(fontSize: 22.0, color: Colors.white),
                
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
               )
      )
      
             ]
           ),
        )
      );
      }
    int valid(String code, List<Medicine> medicines){
       int i;
       for(i=0;i<medicines.length;i++)
       if(medicines[i].productId==code)
       return 0;
       return 1;
    }
}