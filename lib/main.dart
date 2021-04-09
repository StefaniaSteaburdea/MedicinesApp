import 'package:blind/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:blind/edit.dart';
import 'package:provider/provider.dart';
import 'package:blind/medicine_provider.dart';

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
  @override
  _MyHomePageState createState()=>new _MyHomePageState();

}
class _MyHomePageState extends State<MyHomePage>{
  @override
  Widget build(BuildContext context){
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
               print('e buton');
           },
           )
           ,
           bottomNavigationBar:  Container(
                width: (MediaQuery.of(context).size.width),
                child: MaterialButton(
                   height: 80,
                   minWidth: 150,
                   onPressed:(){
                     Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context)=>MyEdit()
                        )
                    );
                   },
                   splashColor: Colors.brown[700],
                   color: Colors.brown[700],
                   child: Text(
                    'Edit Tag',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
        
             ))),
        );
        
  }
}