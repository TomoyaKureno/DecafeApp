import 'dart:async';
import 'package:decafe_app/model/dataModel.dart';
import 'package:decafe_app/model/apiUtils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class CheckoutPage extends StatefulWidget {
  final List<Categories> categories;
  final List<OrderMenu> orders;
  final int subTotal;
  const CheckoutPage(
      {Key? key,
      required this.categories,
      required this.orders,
      required this.subTotal})
      : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with TickerProviderStateMixin {
  final formatter = intl.NumberFormat.decimalPattern();
  TabController? _tabDineIn;
  TabController? _tabCategory;
  int grandTotal = 0;
  int subTotalCheckOut = 0;
  int tax = 0;
  Timer? _timer;
  final TextEditingController _notes = TextEditingController(text: "");
  @override
  void initState() {
    super.initState();
    _tabCategory = TabController(length: widget.categories.length, vsync: this);
    _tabDineIn = TabController(length: 2, vsync: this);
    subTotalCheckOut = widget.subTotal;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notes.dispose();
    _tabDineIn?.dispose();
    _tabCategory?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tax = (subTotalCheckOut * (10 / 100)).toInt();
    grandTotal = subTotalCheckOut + tax;
    return PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final checkoutContent = Row(
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
                              physics: NeverScrollableScrollPhysics(),
                              enableFeedback: false,
                              onTap: (index) {
                                setState(() {
                                  _tabCategory!.index = 0;
                                });
                              },
                              controller: _tabCategory,
                              indicator: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              tabs: tabCategories(widget.categories),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 10,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        32, 16, 32, MediaQuery.of(context).padding.bottom + 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "Checkout",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Row(
                            children: [
                              Expanded(
                                child: Material(
                                  borderRadius: BorderRadius.circular(
                                    5,
                                  ),
                                  elevation: 3,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        5,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: ListView.builder(
                                      itemCount: widget.orders.length,
                                      itemBuilder: ((context, index) =>
                                          cardCheckoutModel(
                                              widget.orders[index])),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 24,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Material(
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                        elevation: 3,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 7,
                                                  child: FractionallySizedBox(
                                                    widthFactor: 1,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        FractionallySizedBox(
                                                          widthFactor: 1,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                ),
                                                              ),
                                                            ),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 24,
                                                            ),
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            height: 60,
                                                            child: Text(
                                                              "Payment Receipt",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 28),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                              FractionallySizedBox(
                                                            widthFactor: 1,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          24,
                                                                      vertical:
                                                                          12),
                                                              child: ListView
                                                                  .builder(
                                                                itemCount: widget
                                                                    .orders
                                                                    .length,
                                                                itemBuilder: ((context,
                                                                        index) =>
                                                                    paymentProductList(
                                                                      widget.orders[
                                                                          index],
                                                                    )),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        top: BorderSide(
                                                          width: 1,
                                                          color: Colors
                                                              .grey.shade400,
                                                        ),
                                                      ),
                                                      // color: Colors.red,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 24,
                                                              vertical: 12,
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      "Subtotal",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            147,
                                                                            147,
                                                                            147,
                                                                            1),
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      "Rp. " +
                                                                          formatter
                                                                              .format(subTotalCheckOut),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            147,
                                                                            147,
                                                                            147,
                                                                            1),
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          "Taxes ",
                                                                          style:
                                                                              TextStyle(
                                                                            color: Color.fromRGBO(
                                                                                147,
                                                                                147,
                                                                                147,
                                                                                1),
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "(10%)",
                                                                          style:
                                                                              TextStyle(
                                                                            color: Color.fromRGBO(
                                                                                147,
                                                                                147,
                                                                                147,
                                                                                1),
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Text(
                                                                      "Rp. " +
                                                                          formatter
                                                                              .format(tax),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            147,
                                                                            147,
                                                                            147,
                                                                            1),
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 55,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border(
                                                              top: BorderSide(
                                                                width: 1,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                              ),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        24),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Grand Total",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            147,
                                                                            147,
                                                                            147,
                                                                            1),
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "Rp. " +
                                                                      formatter
                                                                          .format(
                                                                              grandTotal),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ]),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: switchDineIn(),
                                          ),
                                          SizedBox(
                                            height: 14,
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Material(
                                              elevation: 3,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      148, 180, 159, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        try {
                                                          final postOrder = Order(
                                                            isDinein:
                                                                _tabDineIn!
                                                                        .index !=
                                                                    1,
                                                            listOrder: widget
                                                                .orders
                                                                .map((e) =>
                                                                    e.toJson())
                                                                .toList(),
                                                          );

                                                          await PostData.post(
                                                            postOrder.toJson(),
                                                          );
                                                          if (!mounted) return;

                                                          widget.orders.clear();
                                                          await showOrderAccept();
                                                          if (!mounted) return;

                                                          Navigator.pop(
                                                              context,
                                                              widget.orders);
                                                        } catch (error) {
                                                          if (!mounted) return;
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  "Server order tidak tersedia. Order dijalankan mode lokal."),
                                                            ),
                                                          );
                                                          widget.orders.clear();
                                                          await showOrderAccept();
                                                          if (!mounted) return;
                                                          Navigator.pop(
                                                              context,
                                                              widget.orders);
                                                        }
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      child: Center(
                                                        child: Text(
                                                          "Order Food",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Material(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  onTap: () {
                                                    Navigator.pop(
                                                        context, widget.orders);
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      "Cancel Order",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  ],
                );

                if (constraints.maxWidth < 1100) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1100,
                      height: constraints.maxHeight,
                      child: checkoutContent,
                    ),
                  );
                }

                return checkoutContent;
              },
            ),
          ),
        ));
  }

  List<Widget> tabCategories(List<Categories> dataCategory) {
    return dataCategory.map((e) => categoryModel(e.icon)).toList();
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

  Widget switchDineIn() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(50),
        color: Color.fromRGBO(193, 193, 193, 1),
      ),
      child: TabBar(
        labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        labelColor: Color.fromRGBO(131, 157, 140, 1),
        unselectedLabelColor: Color.fromRGBO(164, 164, 164, 1),
        controller: _tabDineIn,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        tabs: [
          Tab(
            text: "Dine In",
          ),
          Tab(
            text: "Takeaway",
          )
        ],
      ),
    );
  }

  Widget cardCheckoutModel(OrderMenu order) {
    return Card(
      elevation: 3,
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Image.network(
                      order.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
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
                            FractionallySizedBox(
                              widthFactor: 0.55,
                              child: Text(
                                order.description,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
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
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              maxLines: 1,
                              order.notes == null ? "" : order.notes!,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Row(
                            children: [
                              buttonCheckoutEdit(order),
                              SizedBox(
                                width: 8,
                              ),
                              buttonAddMinOrder(order),
                            ],
                          ),
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

  Widget buttonCheckoutEdit(OrderMenu order) {
    return Card(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () async {
            _notes.text = order.notes ?? "";
            await giveNote();
            if (!mounted) return;
            setState(() {
              final trimmedNotes = _notes.text.trim();
              order.notes = trimmedNotes.isEmpty ? null : trimmedNotes;
            });
            _notes.clear();
          },
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(
                Icons.edit,
                color: Color.fromRGBO(85, 206, 55, 1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget paymentProductList(OrderMenu order) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    order.qty.toString() + "x ",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(147, 147, 147, 1),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Rp. " + formatter.format(order.price),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(147, 147, 147, 1),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                "Rp. " + formatter.format((order.price * order.qty)),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(147, 147, 147, 1),
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
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
                        subTotalCheckOut -= orderQty.price;
                      } else {
                        widget.orders.removeWhere(
                            (element) => element.menuId == orderQty.menuId);
                        subTotalCheckOut -= orderQty.price * orderQty.qty;
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
                        subTotalCheckOut += orderQty.price;
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

  Future<void> showOrderAccept() => showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          _timer?.cancel();
          _timer = Timer(const Duration(seconds: 4), () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
          return AlertDialog(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.fromLTRB(70, 20, 70, 24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/orderAccept.png'),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Order Success",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  children: [
                    Container(
                      width: 250,
                      child: Text(
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        "Please kindly wait for your order to be served",
                        style: TextStyle(
                          color: Color.fromRGBO(173, 173, 173, 1),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Color.fromRGBO(10, 155, 14, 1),
                        ),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 40),
                        ),
                      ),
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      );

  Future<void> giveNote() => showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Notes",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 500,
                    child: TextFormField(
                      style: TextStyle(fontSize: 24),
                      controller: _notes,
                      maxLines: 3,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Color.fromRGBO(85, 206, 55, 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Color.fromRGBO(148, 180, 159, 1),
                        ),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 40),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
