import 'dart:convert';
import 'package:decafe_app/model/dataModel.dart';
import 'package:http/http.dart' as http;

class Categories {
  String id;
  String name;
  String description;
  String icon;
  List<Menu> menus;

  Categories({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.menus,
  });

  static const _baseUrl = "decafe-admin.herokuapp.com";
  static final Uri _categoriesUri = Uri.https(_baseUrl, "/api/v1/category");

  static Future<List<Categories>> fetchCategories() async {
    try {
      final response = await http.get(_categoriesUri).timeout(
            const Duration(seconds: 15),
          );
      if (response.statusCode != 200) {
        return _fallbackCategories();
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) {
        return _fallbackCategories();
      }

      return _mapCategories(decoded);
    } catch (_) {
      return _fallbackCategories();
    }
  }

  static List<Categories> _mapCategories(List<dynamic> data) {
    return data.map(
      (e) {
        final dataMenus = e['menus'] as List;
        final tempMenus = dataMenus
            .map((d) => Menu(
                  id: d['id'],
                  name: d['name'],
                  description: d['description'],
                  image: d['image'],
                  price: d['price'],
                  UpdatedAt: DateTime.parse(d['updated_at']),
                  categoryId: d['category_id'],
                  createdAt: DateTime.parse(d['created_at']),
                  isAvailable: d['is_available'],
                ))
            .toList();

        return Categories(
          id: e['id'].toString(),
          name: e['name'],
          description: e['description'],
          icon: e['icon'],
          menus: tempMenus,
        );
      },
    ).toList();
  }

  static List<Categories> _fallbackCategories() {
    final now = DateTime.now();
    return [
      Categories(
        id: "1",
        name: "Coffee",
        description: "Hot and iced coffee menu",
        icon: "https://via.placeholder.com/120.png?text=Coffee",
        menus: [
          Menu(
            id: 101,
            name: "Caffe Latte",
            price: 28000,
            UpdatedAt: now,
            categoryId: 1,
            createdAt: now,
            description: "Espresso with steamed milk",
            image: "https://via.placeholder.com/600x400.png?text=Latte",
            isAvailable: true,
          ),
          Menu(
            id: 102,
            name: "Americano",
            price: 22000,
            UpdatedAt: now,
            categoryId: 1,
            createdAt: now,
            description: "Espresso with hot water",
            image: "https://via.placeholder.com/600x400.png?text=Americano",
            isAvailable: true,
          ),
        ],
      ),
      Categories(
        id: "2",
        name: "Food",
        description: "Quick bites and meals",
        icon: "https://via.placeholder.com/120.png?text=Food",
        menus: [
          Menu(
            id: 201,
            name: "Chicken Sandwich",
            price: 34000,
            UpdatedAt: now,
            categoryId: 2,
            createdAt: now,
            description: "Toasted bread with chicken",
            image: "https://via.placeholder.com/600x400.png?text=Sandwich",
            isAvailable: true,
          ),
          Menu(
            id: 202,
            name: "French Fries",
            price: 19000,
            UpdatedAt: now,
            categoryId: 2,
            createdAt: now,
            description: "Crispy potato fries",
            image: "https://via.placeholder.com/600x400.png?text=Fries",
            isAvailable: true,
          ),
        ],
      ),
    ];
  }
}

class PostData {
  static final Uri _orderUri =
      Uri.https("decafe-admin.herokuapp.com", "/api/v1/order");

  static Future<http.Response> post(Map<String, dynamic> dataOrder) async {
    final result = await http
        .post(
      _orderUri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(dataOrder),
    )
        .timeout(const Duration(seconds: 15));

    if (result.statusCode < 200 || result.statusCode >= 300) {
      throw Exception("Failed to submit order (status: ${result.statusCode})");
    }

    return result;
  }
}
