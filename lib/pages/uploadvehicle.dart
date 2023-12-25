import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  String vehicleNumber = '';
  String brandType = '';
  String vehicleType = '';
  String fuelType = '';
}

class VehicleForm extends StatefulWidget {
  @override
  _VehicleFormState createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final Vehicle _vehicle = Vehicle();
  final CollectionReference vehiclesCollection =
      FirebaseFirestore.instance.collection('your_firestore_collection_name');

  final List<String> brandTypes = ['Brand A', 'Brand B', 'Brand C'];
  final List<String> vehicleTypes = ['Car', 'Bike'];
  final List<String> fuelTypes = ['Petrol', 'Diesel'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Vehicle Details',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Vehicle Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the vehicle number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _vehicle.vehicleNumber = value ?? '';
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  items: brandTypes.map((brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Brand Type',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _vehicle.brandType = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the brand type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  items: vehicleTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Vehicle Type',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _vehicle.vehicleType = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the vehicle type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  items: fuelTypes.map((fuel) {
                    return DropdownMenuItem<String>(
                      value: fuel,
                      child: Text(fuel),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Fuel Type',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _vehicle.fuelType = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the fuel type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      // Save to Firestore
                      await vehiclesCollection.add({
                        'vehicleNumber': _vehicle.vehicleNumber,
                        'brandType': _vehicle.brandType,
                        'vehicleType': _vehicle.vehicleType,
                        'fuelType': _vehicle.fuelType,
                      });
                      // Show a snackbar or navigate to a new screen upon successful save
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vehicle details saved successfully!'),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
