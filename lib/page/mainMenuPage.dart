import 'package:decafe_app/model/dataModel.dart';
import 'package:decafe_app/model/apiUtils.dart';
import 'package:decafe_app/page/checkoutPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  int idx = 0;
  final formatter = intl.NumberFormat.decimalPattern();
  late Future<List<Categories>> dataAfterFetch;
  final TextEditingController _searchProduct = TextEditingController();
  TabController? _tabController;
  List<OrderMenu> orders = [];
  int subTotal = 0;
  List<Categories>? categories;
  List<List<Menu>>? menu;
  List<List<Menu>>? categoriesToMenu;

  void _onTabChanged() {
    if (_tabController == null || idx == _tabController!.index) {
      return;
    }
    setState(() {
      idx = _tabController!.index;
    });
  }

  @override
  void initState() {
    super.initState();
    dataAfterFetch = fetchData();
    dataAfterFetch.then((value) {
      if (!mounted) return;
      _tabController?.removeListener(_onTabChanged);
      _tabController?.dispose();
      if (value.isEmpty) {
        _tabController = null;
        setState(() {});
        return;
      }
      _tabController = TabController(length: value.length, vsync: this)
        ..addListener(_onTabChanged);
      setState(() {});
    });
  }

  Future<List<Categories>> fetchData() {
    return Categories.fetchCategories();
  }

  @override
  void dispose() {
    _searchProduct.dispose();
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Categories>>(
      future: dataAfterFetch,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _dataErrorState();
        }

        final fetchedCategories = snapshot.data;
        if (fetchedCategories == null) {
          return _dataErrorState();
        }

        if (fetchedCategories.isEmpty) {
          return _dataEmptyState();
        }

        if (_tabController == null ||
            _tabController!.length != fetchedCategories.length) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        categories = fetchedCategories;
        final selectedCategoryIndex =
            idx < categories!.length ? idx : categories!.length - 1;
        categoriesToMenu = categories!.map((e) => e.menus).toList();
        if (_searchProduct.text == "") {
          menu = categoriesToMenu;
        } else {
          menu = categoriesToMenu!
              .map((e) => e
                  .where((element) => element.name
                      .toLowerCase()
                      .contains(_searchProduct.text.toLowerCase()))
                  .toList())
              .toList();
        }

        return Scaffold(
                resizeToAvoidBottomInset: false,
                body: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final menuContent = GestureDetector(
                        onTap: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        child: Row(
                          children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          color: Color.fromRGBO(242, 242, 242, 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Image.asset('assets/Logo.png'),
                              ),
                              Expanded(
                                flex: 7,
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    tabs: tabCategories(categories!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 6,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              categories![selectedCategoryIndex]
                                                  .name,
                                              style: TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Expanded(
                                            child: Text(
                                              categories![selectedCategoryIndex]
                                                  .description,
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        width: 300,
                                        height: 35,
                                        child: TextFormField(
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                          cursorColor:
                                              Color.fromRGBO(85, 206, 55, 1),
                                          textAlignVertical:
                                              TextAlignVertical.bottom,
                                          controller: _searchProduct,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.search,
                                            ),
                                            hintText: "Search",
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.grey.shade400,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 2,
                                                color: Color.fromRGBO(
                                                    85, 206, 55, 1),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: TabBarView(
                                controller: _tabController,
                                children: generateMenu(menu!),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16,
                              MediaQuery.of(context).padding.bottom + 16),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 11,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 22),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Orders",
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      orders.clear();
                                                    });
                                                    subTotal = 0;
                                                  },
                                                  child: Text("Clear"),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 8,
                                            child: ListView.builder(
                                              itemCount: orders.length,
                                              itemBuilder: (context, index) =>
                                                  cardOrderModel(orders[index]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Subtotal:",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "Rp. " +
                                                      formatter
                                                          .format(subTotal),
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Expanded(
                                            child: Material(
                                              elevation: 3,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      148, 180, 159, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: orders.isEmpty
                                                        ? null
                                                        : () async {
                                                            final returnOrders =
                                                                await Navigator.of(
                                                                        context)
                                                                    .push<List<OrderMenu>>(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    ((context) =>
                                                                        CheckoutPage(
                                                                          categories:
                                                                              categories!,
                                                                          orders:
                                                                              orders,
                                                                          subTotal:
                                                                              subTotal,
                                                                        )),
                                                              ),
                                                            );
                                                            if (!mounted ||
                                                                returnOrders ==
                                                                    null) {
                                                              return;
                                                            }

                                                            setState(() {
                                                              orders =
                                                                  returnOrders;
                                                              subTotal = orders
                                                                  .fold(
                                                                0,
                                                                (total, item) =>
                                                                    total +
                                                                    (item.price *
                                                                        item.qty),
                                                              );
                                                            });
                                                          },
                                                    child: Center(
                                                      child: Text(
                                                        "Checkout",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                          ],
                        ),
                      );

                      if (constraints.maxWidth < 1100) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1100,
                            height: constraints.maxHeight,
                            child: menuContent,
                          ),
                        );
                      }

                      return menuContent;
                    },
                  ),
                ));
      },
    );
  }

  Widget _dataEmptyState() {
    return const Scaffold(
      body: Center(
        child: Text(
          "No menu data",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _dataErrorState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Data Error",
              style: TextStyle(
                color: Colors.red,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> generateMenu(List<List<Menu>> menuCategory) {
    return menuCategory.map((e) => generateCardMenu(e)).toList();
  }

  Widget generateCardMenu(List<Menu> dataMenu) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: dataMenu.isEmpty
          ? Center(
              child: Text(
                "There's no menu",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 32),
              ),
            )
          : GridView.builder(
              itemCount: dataMenu.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  childAspectRatio: 200 / 170, maxCrossAxisExtent: 400),
              itemBuilder: (context, index) =>
                  cardProductModel(dataMenu[index])),
    );
  }

  List<Widget> tabCategories(List<Categories> dataCategory) {
    return dataCategory.map((e) => categoryModel(e.icon)).toList();
  }

  Widget cardProductModel(Menu data) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (!(orders.any((element) => element.menuId == data.id))) {
            orders.add(OrderMenu(
              name: data.name,
              price: data.price,
              description: data.description,
              image: data.image,
              menuId: data.id,
              qty: 1,
            ));
            subTotal += data.price;
          }
        });
      },
      onLongPress: () {
        dialogProductDetail(data);
      },
      child: Card(
        margin: EdgeInsets.all(8),
        child: Container(
          height: 120,
          width: 300,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      child: Image.network(
                        data.image,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400.withAlpha(200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: 30,
                      height: 30,
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            dialogProductDetail(data);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              "i",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    Text(
                      data.description,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                    Text(
                      "Rp. " + formatter.format(data.price),
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget cardOrderModel(OrderMenu order) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Container(
        height: 130,
        width: 300,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: FractionallySizedBox(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Image.network(
                    order.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              order.description,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "Rp. " + formatter.format(order.price),
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: buttonAddMinOrder(order),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryModel(String image) {
    return RotatedBox(
      quarterTurns: -1,
      child: Container(
        width: 100,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Image(image: NetworkImage(image)),
        ),
      ),
    );
  }

  Widget buttonAddMinOrder(OrderMenu orderQty) {
    return Container(
      height: 30,
      child: Row(
        children: [
          Material(
            elevation: 1,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (orderQty.qty > 1) {
                        orderQty.qty--;
                        subTotal -= orderQty.price;
                      } else {
                        orders.removeWhere(
                            (element) => element.menuId == orderQty.menuId);
                        subTotal -= orderQty.price * orderQty.qty;
                      }
                    });
                  },
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.remove,
                        color: Color.fromRGBO(85, 206, 55, 1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Material(
            elevation: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Text(orderQty.qty.toString()),
              ),
            ),
          ),
          Material(
            elevation: 1,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  onTap: () {
                    setState(() {
                      if (orderQty.qty < 100) {
                        orderQty.qty++;
                        subTotal += orderQty.price;
                      }
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.add,
                        color: Color.fromRGBO(85, 206, 55, 1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> dialogProductDetail(Menu data) => showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.fromLTRB(32, 32, 32, 70),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 500,
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        data.image,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Rp. " + formatter.format(data.price),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            data.description,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade500,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
}
