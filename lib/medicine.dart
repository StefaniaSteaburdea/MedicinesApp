class Medicine{
  final String productId;
  final String name;
  final String usage;
  final String quantity;

  Medicine({this.productId,this.name,this.usage,this.quantity});

  Map<String,dynamic>toMap(){
    return{
      'productId': productId,
      'name': name,
      'usage': usage,
      'quantity': quantity
    };
  }
   
   Medicine.fromFirestore( Map<String,dynamic> f)
    :productId=f['productId'],
     name=f['name'],
     usage=f['usage'],
     quantity=f['quantity'];
  
}