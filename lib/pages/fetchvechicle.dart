import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project7/pages/uploadvehicle.dart';
import 'package:project7/widgets/Top_Bar.dart';

class VehicleDetailsPage extends StatefulWidget {
  @override
  _VehicleDetailsPageState createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Vehicle Details',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          labelColor: Colors.black,
          dividerColor: Colors.black,
          unselectedLabelColor: Colors.black26,
          controller: _tabController,
          tabs: [
            Tab(text: 'Car'),
            Tab(text: 'Bike'),
          ],
        ),
      ),
      drawer: NavBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          VehicleList(vehicleType: 'Car'),
          VehicleList(vehicleType: 'Bike'),
        ],
      ),
  floatingActionButton: Container(
  width: double.infinity,
  padding: EdgeInsets.only(left: 35, right: 5),
  child: Material(
    elevation: 4.0,
    borderRadius: BorderRadius.circular(0), // Set to 0 for no round corners
    color: Colors.blue, // Use your desired background color
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VehicleForm()),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0,),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 8.0),
            Text(
              "Add Vehicle",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10,),
            Icon(Icons.add_circle_outline_rounded, color: Colors.white),
          ],
        ),
      ),
    ),
  ),
),
    );
  }
}

class VehicleList extends StatelessWidget {
  final String vehicleType;

  VehicleList({required this.vehicleType});

  final CollectionReference vehiclesCollection =
      FirebaseFirestore.instance.collection('your_firestore_collection_name');

  Future<void> _deleteVehicle(BuildContext context, String documentId) async {
    await vehiclesCollection.doc(documentId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vehicle deleted successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: vehiclesCollection
          .where('vehicleType', isEqualTo: vehicleType)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        if (documents.isEmpty) {
          return Center(
            child: Text(
              'No vehicles added for $vehicleType',
              style: TextStyle(fontSize: 20.0),
            ),
          );
        }

        return ListView.builder(
          itemCount: documents.length + 1, // Add 1 for the last card
          itemBuilder: (context, index) {
            if (index == documents.length) {
              // Last item, show the "Add Vehicle" container
              return Container(
                width: double.infinity,
                padding: EdgeInsets.only( bottom: 16.0),
                child: Material(
                  // elevation: 4.0,
                  borderRadius: BorderRadius.circular(0),
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                     
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 25.0),
                          
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            DocumentSnapshot document = documents[index];
            return Card(
              elevation: 4.0,
              margin: EdgeInsets.all(12.0),
              child: ListTile(
                title: Text(
                  "Vehicle Number: ${document['vehicleNumber']}",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Type: $vehicleType',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Brand: ${document['brandType']}',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Fuel: ${document['fuelType']}',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.cancel_outlined,),
                  onPressed: () {
                    _deleteVehicle(context, document.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
