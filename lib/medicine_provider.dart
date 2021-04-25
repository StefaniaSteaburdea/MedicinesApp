import 'package:blind/firestore_service.dart';
import 'package:blind/medicine.dart';
import 'package:flutter/material.dart';

class MedicineProvider with ChangeNotifier{
   String _productId;
   String _name;
   String _usage;
   String _quantity;
   final firestoreService=FirestoreService();
   //Getters
   String get productId=>_productId;
   String get name=>_name;
   String get usage=>_usage;
   String get quantity=>_quantity;

   //Setters
   changeName(String value){
     _name=value;
     notifyListeners();
   }
   changeUsage(String value){
     _usage=value;
     notifyListeners();
   }
   changeQuantity(String value){
     _quantity=value;
     notifyListeners();
   }
   changeProductID(String value){
     _productId=value;
     notifyListeners();
   }
   toSave(){
     if(_productId==null){
       var newProduct=Medicine(name:name,usage:usage,quantity:quantity,productId:productId);
       firestoreService.medAdd(newProduct);
     }
     else
     {
       var updatedProduct=Medicine(name:_name,usage:_usage,quantity:_quantity,productId:_productId);
       firestoreService.medAdd(updatedProduct);
     }
   }
   loadValues(Medicine medicine){
     _name=medicine.name;
     _usage=medicine.usage;
     _quantity=medicine.quantity;
     _productId=medicine.productId;
   }
   deleteMed(String productId){
     firestoreService.removeMed(productId);
   }
}