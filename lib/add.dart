import 'package:blind/edit.dart';
import 'package:blind/medicine.dart';
import 'package:blind/medicine_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class MyAdd extends StatefulWidget{
  final Medicine medicine;
  MyAdd([this.medicine]);
  @override
  _MyAddState createState()=>new _MyAddState();
}
class _MyAddState extends State<MyAdd>{

  final nameController= TextEditingController();
  final usageController=TextEditingController();
  final quantityController=TextEditingController();

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
  }
  @override
  Widget build(BuildContext context){
   final medicineProvider=Provider.of<MedicineProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.brown[700], title: Text('Add medicines'),
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
                   onPressed: (){
                     medicineProvider.toSave();
                      Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context)=>MyEdit()
                        )
                    );
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
      }}