import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blind/medicine.dart';

class FirestoreService {
  
  FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void> medAdd(Medicine medicine){

   return _db.collection('Medicines').doc(medicine.productId).set(medicine.toMap());
  }
  Stream<List<Medicine>>getMedicine(){
    return _db.collection('Medicines').snapshots().map((snapshot) => snapshot.docs.map((document)=>Medicine.fromFirestore(document.data())).toList());
  }
  Future<void>removeMed(String prodId){
    return _db.collection('Medicines').doc(prodId).delete();
  }
  }