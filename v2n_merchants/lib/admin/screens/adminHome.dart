import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:v2n_merchants/data.dart';
import 'package:v2n_merchants/models/merchant.dart';
import 'package:v2n_merchants/admin/screens/new_merchant.dart';
import 'package:v2n_merchants/admin/widgets/admin_drawer.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({
    super.key,
    this.token,
  });

  final String? token;

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<FetchMerchants> _merchants = [];
  var _isLoading = true;
  bool _isFirstPage = false;
  bool _isLastPage = false;

  String? _error;
  int _currentPage = 1;
  late double _totalPages;
  int pageSize = 10;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _loadItmes();
    _loadData(_currentPage);
    setButtons(_currentPage);
  }

  void setButtons(int page) {
    if (page == (_totalPages.toInt()) + 1) {
      setState(() {
        _isLastPage = true;
      });
      return;
    }
    if (page == 1) {
      print(page);
      setState(() {
        _isFirstPage = true;
      });
      return;
    }
    setState(() {
      _isFirstPage = false;
      _isLastPage = false;
    });
  }

  void _loadData(int page) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    //load the data from the API
    _loadMerchants(page);
  }

  void _loadMerchants(int page) async {
    final url2 = Uri.parse(
        'http://132.226.206.68/vaswrapper/jsdev/clientmanager/fetch-merchants?page=$page&perPage=$pageSize');
    Map<String, String> headers = {
      "Authorization": 'Bearer ${widget.token}',
    };
    final response2 = await http.get(
      url2,
      headers: headers,
    );

    print(response2.statusCode);

    if (response2.statusCode == 200) {
      final body = jsonDecode(response2.body);
      final merchants = body['message']['merchants'];
      setState(() {
        _totalPages = body['totalCount'] / pageSize;
      });
      print(merchants);

      final List<FetchMerchants> loadedMerchants = [];

      for (final merchant in merchants) {
        print(merchant);
        loadedMerchants.add(
          FetchMerchants(
            id: merchant['id'],
            name: merchant['name'],
            username: merchant['username'],
            role: merchant['role'],
            parentId: merchant['parentId'],
            airtimeId: merchant['airtimeId'],
            dataId: merchant['dataId'],
            b2bId: merchant['b2bId'],
            portalId: merchant['portalId'],
            status: merchant['status'],
          ),
        );
      }
      setState(() {
        _merchants = loadedMerchants;
        _isLoading = false;
        // _isLoadingPage = false;
      });
    } else {
      setState(() {
        _error = "Failed to fetch data. Please try again later.";
      });
    }
  }

  void _loadNextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      _loadData(_currentPage);
      setButtons(_currentPage);
    }
  }

  void _loadPreviousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      _loadData(_currentPage);
      setButtons(_currentPage);
    }
  }

  // void _loadItmes() async {
  //   final url = Uri.parse(
  //       'https://v2n-merchant-default-rtdb.firebaseio.com/merchants.json?page=10');
  //   ;

  //   try {
  //     final response = await http.get(url);
  //     setState(() {
  //       if (response.statusCode >= 400) {
  //         _error = "Failed to fetch data. Please try again later.";
  //       }
  //     });

  //     if (response.body == 'null') {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       return;
  //     }
  //     final List<Merchant> loadedMerchants = [];

  //     final Map<String, dynamic> listMerchant = json.decode(response.body);

  //     for (final merchant in listMerchant.entries) {
  //       loadedMerchants.add(
  //         Merchant(
  //           id: merchant.key,
  //           name: merchant.value['name'],
  //           email: merchant.value['email'],
  //           password: merchant.value['password'],
  //           airtimeId: merchant.value['airtimeId'],
  //           dataId: merchant.value['dataId'],
  //           b2bId: merchant.value['b2bId'],
  //           portalId: merchant.value['portalId'],
  //           portalPassword: merchant.value['portalPassword'],
  //           isActive: merchant.value['active'],
  //         ),
  //       );
  //     }
  //     setState(() {
  //       _merchants = loadedMerchants;
  //       // ref
  //       //     .read(MerchantHandlerProvider.notifier)
  //       //     .loadMerchants(loadedMerchants);
  //       _isLoading = false;
  //     });
  //   } catch (err) {
  //     setState(() {
  //       _error = "Something went wrong. Please try again later.";
  //     });
  //   }
  // }

  // void _addMerchant() async {
  //   final newMerchant = await Navigator.push<Merchant>(
  //     context,
  //     MaterialPageRoute(
  //       builder: (ctx) => NewMerchant(),
  //     ),
  //   );
  //   if (newMerchant == null) {
  //     return;
  //   }
  //   // setState(() {
  //   //   _merchants.add(newMerchant);
  //   // });
  //   _loadItmes();
  // }

  // void deleteMerchant(Merchant merchant) async {
  //   final merchantIndex = _merchants.indexOf(merchant);

  //   // Check if the merchant was found in the list.
  //   if (merchantIndex != -1) {
  //     setState(() {
  //       _merchants.removeAt(merchantIndex);
  //     });
  //   } else {
  //     // Handle the case where the merchant was not found.
  //     print("Merchant not found: ${merchant.name}");
  //     return;
  //   }

  //   final url = Uri.https('v2n-merchant-default-rtdb.firebaseio.com',
  //       'merchants/${merchant.id}.json');
  //   final response = await http.delete(url);
  //   if (response.statusCode == 200) {
  //     ScaffoldMessenger.of(context).clearSnackBars();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         duration: const Duration(seconds: 3),
  //         content: Text(
  //           "${merchant.name} Deleted",
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).clearSnackBars();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         duration: Duration(seconds: 3),
  //         content: Text(
  //           "Invalid URL",
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //     );
  //     setState(() {
  //       _merchants.insert(merchantIndex, merchant);
  //     });
  //   }
  //   _loadItmes();
  // }

  // void editMerchant(Merchant merchant) async {
  //   final merchantIndex = _merchants.indexOf(merchant);
  //   final edittedMerchant = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => NewMerchant(merchant: merchant),
  //     ),
  //   );

  //   if (edittedMerchant == null) {
  //     return;
  //   }

  //   setState(() {
  //     _merchants
  //         .replaceRange(merchantIndex, merchantIndex + 1, [edittedMerchant]);
  //   });
  // }

  // void changeActiveStatus(Merchant merchant) async {
  //   final url = Uri.https('v2n-merchant-default-rtdb.firebaseio.com',
  //       'merchants/${merchant.id}.json');
  //   await http.patch(
  //     url,
  //     body: json.encode(
  //       {
  //         'active': merchant.isActive,
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   _merchants = ref.watch(MerchantHandlerProvider);
    // });
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You got no items yet',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 15),
          Text(
            'Add an item with the add icon by the top right',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        ],
      ),
    );

    Widget controlButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _loadPreviousPage,
          child: Text('Previous Page'),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: _loadNextPage,
          child: Text('Next Page'),
        ),
      ],
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_isFirstPage) {
      controlButtons = Center(
        child: ElevatedButton(
          onPressed: _loadNextPage,
          child: Text('Next Page'),
        ),
      );
    }

    if (_isLastPage) {
      controlButtons = Center(
        child: ElevatedButton(
          onPressed: _loadPreviousPage,
          child: Text('Previous Page'),
        ),
      );
    }

    if (_error != null) {
      content = Center(
          child: Text(
        _error!,
        style: const TextStyle(
          color: Colors.black,
        ),
      ));
    }

    if (_merchants.isNotEmpty && !_isLoading) {
      content = Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Card(
                    child: Expanded(
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          prefixIconColor: logoColors[1],
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            color: logoColors[1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text(
                      'Search',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: _merchants.length,
                  itemBuilder: (context, index) {
                    final merchant = _merchants[index];
                    return Column(
                      children: [
                        Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${merchant.name}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(color: Colors.black),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            // editMerchant(merchant);
                                          },
                                          color: Colors.black,
                                          icon: const Icon(
                                            Icons.edit,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () {
                                            // deleteMerchant(merchant);
                                          },
                                          color: Colors.black,
                                          icon: const Icon(
                                            Icons.delete,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      merchant.username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(color: Colors.black),
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          // merchant.isActive = !merchant.isActive;
                                          // changeActiveStatus(merchant);
                                        });
                                      },
                                      icon: Icon(
                                          (merchant.status == "ACTIVE")
                                              ? Icons.thumb_up
                                              : Icons.block,
                                          color: Colors.black),
                                      label: Text(
                                        (merchant.status == "ACTIVE")
                                            ? 'Active'
                                            : 'Disabled',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                                color: (merchant.status ==
                                                        "ACTIVE")
                                                    ? Color.fromARGB(
                                                        255, 50, 205, 50)
                                                    : Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            Container(
              padding: const EdgeInsets.only(
                top: 6.0,
                bottom: 6.0,
                left: 6.0,
                right: 40.0,
              ),
              // color: Colors.black26,
              child: controlButtons,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      // backgroundColor: logoColors[2],
      // backgroundColor: const Color.fromARGB(255, 220, 220, 220),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'VasAdmin',
        ),
        backgroundColor: logoColors[1]!.withOpacity(0.9),
      ),
      drawer: const AdminDrawer(),
      body: content,
      floatingActionButton: FloatingActionButton(
        elevation: 5,
        backgroundColor: Colors.white,
        foregroundColor: logoColors[1],
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}


// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:v2n_merchants/data.dart';
// import 'package:v2n_merchants/models/merchant.dart';
// import 'package:v2n_merchants/admin/screens/new_merchant.dart';
// import 'package:v2n_merchants/admin/widgets/admin_drawer.dart';

// class AdminHomeScreen extends StatefulWidget {
//   const AdminHomeScreen({
//     super.key,
//     this.token,
//   });

//   final String? token;

//   @override
//   State<AdminHomeScreen> createState() => _AdminHomeScreenState();
// }

// class _AdminHomeScreenState extends State<AdminHomeScreen> {
//   List<Merchant> _merchants = [];
//   var _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _loadItmes();
//     _loadMerchants();
//   }

//   void _loadMerchants() async {
//     final url2 = Uri.parse(
//         'http://132.226.206.68/vaswrapper/jsdev/clientmanager/fetch-merchants?page=1&perPage=10');
//     Map<String, String> headers = {
//       "Authorization": 'Bearer ${widget.token}',
//     };
//     final response2 = await http.get(
//       url2,
//       headers: headers,
//     );

//     print(response2.statusCode);

//     if (response2.statusCode == 200) {
//       final body = jsonDecode(response2.body);
//       final merchants = body['message']['merchants'][0];
//       print(merchants);
//     }
//   }

//   void _loadItmes() async {
//     final url = Uri.parse(
//         'https://v2n-merchant-default-rtdb.firebaseio.com/merchants.json?page=10');
//     ;

//     try {
//       final response = await http.get(url);
//       setState(() {
//         if (response.statusCode >= 400) {
//           _error = "Failed to fetch data. Please try again later.";
//         }
//       });

//       if (response.body == 'null') {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }
//       final List<Merchant> loadedMerchants = [];

//       final Map<String, dynamic> listMerchant = json.decode(response.body);

//       for (final merchant in listMerchant.entries) {
//         loadedMerchants.add(
//           Merchant(
//             id: merchant.key,
//             name: merchant.value['name'],
//             email: merchant.value['email'],
//             password: merchant.value['password'],
//             airtimeId: merchant.value['airtimeId'],
//             dataId: merchant.value['dataId'],
//             b2bId: merchant.value['b2bId'],
//             portalId: merchant.value['portalId'],
//             portalPassword: merchant.value['portalPassword'],
//             isActive: merchant.value['active'],
//           ),
//         );
//       }
//       setState(() {
//         _merchants = loadedMerchants;
//         // ref
//         //     .read(MerchantHandlerProvider.notifier)
//         //     .loadMerchants(loadedMerchants);
//         _isLoading = false;
//       });
//     } catch (err) {
//       setState(() {
//         _error = "Something went wrong. Please try again later.";
//       });
//     }
//   }

//   void _addMerchant() async {
//     final newMerchant = await Navigator.push<Merchant>(
//       context,
//       MaterialPageRoute(
//         builder: (ctx) => NewMerchant(),
//       ),
//     );
//     if (newMerchant == null) {
//       return;
//     }
//     // setState(() {
//     //   _merchants.add(newMerchant);
//     // });
//     _loadItmes();
//   }

//   void deleteMerchant(Merchant merchant) async {
//     final merchantIndex = _merchants.indexOf(merchant);

//     // Check if the merchant was found in the list.
//     if (merchantIndex != -1) {
//       setState(() {
//         _merchants.removeAt(merchantIndex);
//       });
//     } else {
//       // Handle the case where the merchant was not found.
//       print("Merchant not found: ${merchant.name}");
//       return;
//     }

//     final url = Uri.https('v2n-merchant-default-rtdb.firebaseio.com',
//         'merchants/${merchant.id}.json');
//     final response = await http.delete(url);
//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).clearSnackBars();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           duration: const Duration(seconds: 3),
//           content: Text(
//             "${merchant.name} Deleted",
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).clearSnackBars();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           duration: Duration(seconds: 3),
//           content: Text(
//             "Invalid URL",
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//       setState(() {
//         _merchants.insert(merchantIndex, merchant);
//       });
//     }
//     _loadItmes();
//   }

//   void editMerchant(Merchant merchant) async {
//     final merchantIndex = _merchants.indexOf(merchant);
//     final edittedMerchant = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => NewMerchant(merchant: merchant),
//       ),
//     );

//     if (edittedMerchant == null) {
//       return;
//     }

//     setState(() {
//       _merchants
//           .replaceRange(merchantIndex, merchantIndex + 1, [edittedMerchant]);
//     });
//   }

//   void changeActiveStatus(Merchant merchant) async {
//     final url = Uri.https('v2n-merchant-default-rtdb.firebaseio.com',
//         'merchants/${merchant.id}.json');
//     await http.patch(
//       url,
//       body: json.encode(
//         {
//           'active': merchant.isActive,
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // setState(() {
//     //   _merchants = ref.watch(MerchantHandlerProvider);
//     // });
//     Widget content = Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'You got no items yet',
//             style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                   fontSize: 24,
//                 ),
//           ),
//           const SizedBox(height: 15),
//           Text(
//             'Add an item with the add icon by the top right',
//             style: Theme.of(context).textTheme.labelMedium!.copyWith(
//                   fontSize: 18,
//                   color: Theme.of(context).colorScheme.secondary,
//                 ),
//           ),
//         ],
//       ),
//     );

//     if (_isLoading) {
//       content = const Center(child: CircularProgressIndicator());
//     }

//     if (_error != null) {
//       content = Center(child: Text(_error!));
//     }

//     if (_merchants.isNotEmpty) {
//       content = Center(
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 30, bottom: 30),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Card(
//                     child: Expanded(
//                       child: TextField(
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 20,
//                         ),
//                         decoration: InputDecoration(
//                           prefixIcon: const Icon(Icons.search),
//                           prefixIconColor: logoColors[1],
//                           hintText: 'Username',
//                           hintStyle: TextStyle(
//                             color: logoColors[1],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {},
//                     child: const Text(
//                       'Search',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                   itemCount: _merchants.length,
//                   itemBuilder: (context, index) {
//                     final merchant = _merchants[index];
//                     return Card(
//                       // color: merchant.isActive
//                       //     ? Color.fromARGB(194, 7, 162, 56)
//                       //     : Color.fromARGB(118, 255, 0, 0),
//                       color: Colors.white,
//                       // color: Color.fromARGB(118, 255, 0, 0),
//                       // color: Theme.of(context).colorScheme.onBackground,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 15),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   "${merchant.name}",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleLarge!
//                                       .copyWith(color: Colors.black),
//                                 ),
//                                 const Spacer(),
//                                 Row(
//                                   children: [
//                                     IconButton(
//                                       onPressed: () {
//                                         editMerchant(merchant);
//                                       },
//                                       color: Colors.black,
//                                       icon: const Icon(
//                                         Icons.edit,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     IconButton(
//                                       onPressed: () {
//                                         deleteMerchant(merchant);
//                                       },
//                                       color: Colors.black,
//                                       icon: const Icon(
//                                         Icons.delete,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Text(
//                                   merchant.email,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium!
//                                       .copyWith(color: Colors.black),
//                                 ),
//                                 const Spacer(),
//                                 TextButton.icon(
//                                   onPressed: () {
//                                     setState(() {
//                                       merchant.isActive = !merchant.isActive;
//                                       changeActiveStatus(merchant);
//                                     });
//                                   },
//                                   icon: Icon(
//                                       merchant.isActive
//                                           ? Icons.thumb_up
//                                           : Icons.block,
//                                       color: Colors.black),
//                                   label: Text(
//                                     merchant.isActive ? 'Active' : 'Disabled',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleLarge!
//                                         .copyWith(
//                                             color: merchant.isActive
//                                                 ? Color.fromARGB(
//                                                     255, 50, 205, 50)
//                                                 : Colors.red),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//             ),
//           ],
//         ),
//       );
//     }

//     return Scaffold(
//       // backgroundColor: logoColors[2],
//       // backgroundColor: const Color.fromARGB(255, 220, 220, 220),
//       appBar: AppBar(
//         foregroundColor: Colors.white,
//         title: const Text(
//           'VasAdmin',
//         ),
//         backgroundColor: logoColors[1]!.withOpacity(0.9),
//       ),
//       drawer: const AdminDrawer(),
//       body: content,
//       floatingActionButton: FloatingActionButton(
//         elevation: 5,
//         backgroundColor: Colors.white,
//         foregroundColor: logoColors[1],
//         onPressed: _addMerchant,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }