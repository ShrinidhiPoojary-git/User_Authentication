import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/Theme/app_pallete.dart';
import 'package:flutter_application/auth_gradient_button.dart';
import 'package:flutter_application/ble_controller.dart';
import 'package:flutter_application/nav_bar.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, int> menuToTabIndex = {
    'Home': 0,
    'Profile': 1,
    'Map': 2,
    'Bluetooth': 3,
    'Camera': 4,
  };
  late Future<List<dynamic>> _usersFuture;

  var index;
  var id;
  List<Map<String, dynamic>> productData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 3 tabs
    _usersFuture = fetchUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void navigateToTab(String menuTitle) {
    Navigator.pop(context);
    final tabIndex =
        menuToTabIndex[menuTitle];
    if (tabIndex != null) {
      _tabController.animateTo(tabIndex);
    }
  }

  Future<List<dynamic>> fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> addProduct(List<Map<String, dynamic>> productData) async {
    print("1 : ${DateTime.now().second}");
    final apiUrl = "https://api.restful-api.dev/objects";
    final newData = await _showAddProductDialog();
    if (newData == null) return;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newData),
      );
      print("2 : ${DateTime.now().second}");
      if (response.statusCode == 200) {
        print("3 : ${DateTime.now().second}");
        print(response.body);
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.isNotEmpty) {
          id = responseData['id'];
          print("id: $id");
          setState(() {
            productData.insert(
                0, responseData);
          });
          print('Product added successfully');
        } else {
          print('No data returned from API');
        }
      } else {
        print('Failed to add product');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>?> _showAddProductDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController yearController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController cpuModelController = TextEditingController();
    final TextEditingController hardDiskSizeController =
        TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AlertDialog(
              title: const Text("Add New Product"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Product Name"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: yearController,
                    decoration:
                        const InputDecoration(labelText: "Product Year"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    decoration:
                        const InputDecoration(labelText: "Product Price"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: cpuModelController,
                    decoration:
                        const InputDecoration(labelText: "Product CPU Model"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: hardDiskSizeController,
                    decoration: const InputDecoration(
                        labelText: "Product Hard disk size"),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    final newProduct = {
                      'name': nameController.text,
                      'data': {
                        'year': int.tryParse(yearController.text) ?? 0,
                        'price': double.tryParse(priceController.text) ?? 0.0,
                        'CPU model': cpuModelController.text,
                        'Hard disk size': hardDiskSizeController.text,
                      }
                    };
                    Navigator.of(context)
                        .pop(newProduct);
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // API is throwing error 405
  Future<void> updateProduct(
      String productId, Map<String, dynamic> updatedData) async {
    final apiUrl = "https://api.restful-api.dev/objects/$productId";

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          int index = productData.indexWhere((item) => item['id'] == productId);
          print(index);
          if (index != -1) {
            productData[index] = responseData;
          }
        });

        print('Product updated successfully');
      } else {
        print('Failed to update product');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> showUpdateProductDialog(String productId) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController yearController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController cpuModelController = TextEditingController();
    final TextEditingController hardDiskSizeController =
        TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Update Product"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Product Name"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: "Product Year"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Product Price"),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: cpuModelController,
                  decoration:
                      const InputDecoration(labelText: "Product CPU Model"),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: hardDiskSizeController,
                  decoration: const InputDecoration(
                      labelText: "Product Hard disk size"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final updatedData = {
                    'name': nameController.text,
                    'data': {
                      'year': int.tryParse(yearController.text) ?? 0,
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'CPU model': cpuModelController.text,
                      'Hard disk size': hardDiskSizeController.text,
                    }
                  };

                  Navigator.of(context).pop(); // Close the dialog
                  showLoadingIndicator();
                  updateProduct(productId, updatedData).then((_) {
                    hideLoadingIndicator();
                  });
                },
                child: const Text("Update"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  void showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void hideLoadingIndicator() {
    Navigator.of(context).pop(); // Close the loading indicator dialog
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    productData = arguments['productData'] as List<Map<String, dynamic>>;

    return Scaffold(
      drawer: NavBar(navigateToTab: navigateToTab),
      appBar: AppBar(
        title: Text('Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.home),
            ),
            Tab(
              icon: Icon(Icons.person),
            ),
            Tab(
              icon: Icon(Icons.map),
            ),
            Tab(
              icon: Icon(Icons.bluetooth),
            ),
            Tab(
              icon: Icon(Icons.camera),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Stack(
            children: [
              Center(
                child: ListView.builder(
                  itemCount: productData.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(productData[index]['id']
                          .toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        color: Colors.red,
                        child: Icon(Icons.delete,
                            color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Delete Confirmation"),
                            content: Text(
                                "Are you sure you want to delete this item?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text("Delete"),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        // API throws 405 error
                        print("status code 1 ${productData[index]['id']}");
                        final response = await http.delete(
                          Uri.parse(
                              'https://api.restful-api.dev/objects/${productData[index]['id']}'),
                        );

                        if (response.statusCode == 200) {
                          print("status code 1 ${response.statusCode}");
                          setState(() {
                            productData.removeAt(index);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Item deleted")),
                          );
                        } else {
                          print("status code 2 ${response.statusCode}");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to delete item")),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 60, 36, 36)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppPallete.gradient2,
                            child: Text(
                              productData[index]['name'][0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          title: Text(productData[index]['name']),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Choose an action"),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                showLoadingIndicator();
                                await addProduct(productData);
                                hideLoadingIndicator();
                              },
                              child: const Text("Add"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                final productId = '5';
                                showLoadingIndicator();
                                await showUpdateProductDialog(productId);
                                hideLoadingIndicator();
                              },
                              child: const Text("Update"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(Icons.add),
                  backgroundColor:
                      AppPallete.gradient2,
                ),
              ),
            ],
          ),
          FutureBuilder<List<dynamic>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No users found'));
              } else {
                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final name = user['name'] ?? 'Unknown Name';
                    return Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppPallete.gradient2,
                          child: Text(
                            user['name'][0].toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        title: Text(name),
                        titleTextStyle: TextStyle(color: Colors.black),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return UserDetailDialog(user: user);
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
          //const Center(child: Text('Content for Maps')),
          MapPage(),
          //const Center(child: Text('Content for Bluetooth')),
          GetBuilder<BleController>(
            init: BleController(),
            builder: (BleController controller) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: StreamBuilder<List<ScanResult>>(
                        stream: controller.scanResults,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final data = snapshot.data![index];
                                return Card(
                                    elevation: 2,
                                    child: ListTile(
                                      title: Text(data.device.name.isNotEmpty
                                          ? data.device.name
                                          : 'Unknown Device'),
                                      subtitle: Text(data.device.id.id),
                                      trailing:
                                          Text('RSSI: ${data.rssi.toString()}'),
                                    ));
                              },
                            );
                          } else {
                            return Center(
                              child: Text("No Devices Found"),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AuthGradientButton(
                          buttonText: 'SCAN',
                          onPressed: () async {
                            await controller.scanBleDevices();
                          }),
                    )
                  ],
                ),
              );
            },
          ),
          //const Center(child: Text('Content for Camera')),
          UploadImagePage(),
        ],
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController? googleMapController;
  LatLng currenPosition = const LatLng(27.7172, 85.3240);
  Set<Marker> marker = {};

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        myLocationButtonEnabled: false,
        markers: marker,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: currenPosition,
          zoom: 14,
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          Position position = await getCurrentLocation();
          googleMapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14,
              ),
            ),
          );
          marker.clear();
          marker.add(
            Marker(
                markerId: const MarkerId("This is my location"),
                position: LatLng(position.latitude, position.longitude)),
          );
          setState(() {});
        },
        child: const Icon(Icons.my_location, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  String? _imageUrl;
  XFile? file;
  ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    void showLoadingIndicator() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );
    }

    void hideLoadingIndicator() {
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(title: Text("Upload Image")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageUrl != null)
              Image.network(
                _imageUrl!,
                height: 520,
              )
            else
              Text("No Image to Upload"),
            SizedBox(
              height: 20,
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Choose any one of the Option"),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            file = await imagePicker.pickImage(
                                source: ImageSource.camera);
                            showLoadingIndicator();
                            await uploadImage(file);
                            hideLoadingIndicator();
                          },
                          child: const Text("Camera"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            file = await imagePicker.pickImage(
                                source: ImageSource.gallery);
                            showLoadingIndicator();
                            await uploadImage(file);
                            hideLoadingIndicator();
                          },
                          child: const Text("Gallery"),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.camera_alt),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> uploadImage(XFile? file) async {
    if (file == null) {
      print("null");
      return;
    }
    print("shrinidhi");
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await referenceImageToUpload.putFile(File(file.path));
      String imageUrl = await referenceImageToUpload.getDownloadURL();
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (error) {
      print("Some error occured");
    }
  }
}

class UserDetailDialog extends StatelessWidget {
  final dynamic user;

  const UserDetailDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text(
        user['name'],
        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Username', user['username']),
            _buildDetailRow('Email', user['email']),
            _buildDetailRow('Phone', user['phone']),
            _buildDetailRow('Website', user['website']),
            const SizedBox(height: 10),
            _buildDetailHeader('Address'),
            Text('${user['address']['street']}, ${user['address']['suite']}'),
            Text('${user['address']['city']}, ${user['address']['zipcode']}'),
            Text(
                'Geo: Lat ${user['address']['geo']['lat']}, Lng ${user['address']['geo']['lng']}'),
            const SizedBox(height: 10),
            _buildDetailHeader('Company'),
            Text('${user['company']['name']}'),
            Text('Catch Phrase: ${user['company']['catchPhrase']}'),
            Text('BS: ${user['company']['bs']}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent),
      ),
    );
  }
}
