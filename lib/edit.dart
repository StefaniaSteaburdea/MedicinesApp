import 'package:blind/medicine.dart';
import 'package:blind/medicine_provider.dart';
import 'package:flutter/material.dart';
import 'package:blind/add.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

class MyEdit extends StatefulWidget{
  final BluetoothDevice server;
  MyEdit([this.server]);
  @override
  _MyEditState createState()=>new _MyEditState();
}
class _MyEditState extends State<MyEdit>{
  @override
  Widget build(BuildContext context){
    final medicines=Provider.of<List<Medicine>>(context);
    final medicineProvider=Provider.of<MedicineProvider>(context);
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.brown[700], title: Text('Edit medicines'),),
      bottomNavigationBar: Container(
        height: 100,
        child: IconButton(
        icon:Icon(
           Icons.add_circle,
           size:80,
        ),
        color: Colors.brown[700],
        alignment: Alignment.center,
        onPressed: (){
          Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context)=>MyAdd(null,widget.server)
                        )
                    );
        },
        ),),
      body: (medicines!=null)
      ?ListView.builder(
      itemCount:medicines.length,
      itemBuilder: (context,index){

      return Container(
                  width: (MediaQuery.of(context).size.height * 3 / 4),
                  height: (MediaQuery.of(context).size.height * 4 / 5),
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Row(
                          children: [
                            Text("\nScroll to edit/delete --->\n",style: TextStyle(fontSize: 20),)
                          ],
                        ),
                        Container(
                            width: 300,
                            height:
                                (MediaQuery.of(context).size.height * 3/ 4),
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  Container(
                                    width: 500,
                                  child:DataTable(
                                    headingRowColor:
                                        MaterialStateColor.resolveWith((state) {
                                      return Colors.red[300];
                                    }),
                                    headingTextStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    columns: 
                                    <DataColumn>[
                                      DataColumn(
                                          label: Container(
                                            alignment: Alignment.center,
                                            width:70,
                                            child:Text('Name',textAlign: TextAlign.center,)),
                                          numeric: false),
                                      DataColumn(
                                          label: Container(
                                            width:70,
                                            child:Text('Usage',textAlign: TextAlign.center,)),
                                          numeric: false),
                                      DataColumn(
                                          label: Container(
                                            width:70,
                                            child:Text('Quantity',textAlign: TextAlign.center,)),
                                          numeric: false),
                                      DataColumn(
                                          label: Container(
                                            width:70,
                                            child:Text('    ',textAlign: TextAlign.center,)),
                                          numeric: false),
                                    ],
                                    rows: List<DataRow>.generate(
                                          medicines.length,
                                          (index) => DataRow(cells: <DataCell>[
                                        DataCell(Text(medicines[index].name)),
                                        DataCell(
                                            Text(medicines[index].usage)),
                                        DataCell(Text(medicines[index].quantity)),
                                        DataCell(
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit),
                                                   onPressed:(){
                                                      Navigator.of(context)
                                                      .push(
                                                        MaterialPageRoute(
                                                          builder: (context)=>MyAdd(medicines[index],widget.server)
                                                          )
                                                      );
                                                   }),
                                                IconButton(
                                                  icon: Icon(Icons.delete),
                                                   onPressed:(){
                                                     String ID=medicines[index].productId;
                                                     medicineProvider.deleteMed(ID);
                                                     Navigator.of(context)
                                                      .push(
                                                        MaterialPageRoute(
                                                          builder: (context)=>MyEdit(widget.server)
                                                        ));
                                                   }),
                                            ],
                                          )
                                          
                                        ),
                                      ])
                                  ),
                                  )
                        )]))
                      ])); 
                      }): Center(child: CircularProgressIndicator())
      
        );
        
  }
}