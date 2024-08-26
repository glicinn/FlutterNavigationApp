import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Магазин продуктов Mandelnyam',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 138, 33, 243),
        hintColor: Color.fromARGB(255, 98, 59, 197),
        fontFamily: 'Avenir',
        textTheme: TextTheme(
          bodyText1: TextStyle(fontFamily: 'Avenir'),
          bodyText2: TextStyle(fontFamily: 'Avenir'),
          headline6: TextStyle(fontFamily: 'Avenir', fontSize: 20.0),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class Product {
  final String name;
  final String category;
  final String image;

  Product(this.name, this.category, this.image);
}

class ProductCard extends StatefulWidget {
  final Product product;

  ProductCard(this.product);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isCheck = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: InkWell(
        onTap: () {
          isCheck = !isCheck;
          setState(() {});
        },
        child: Card(
          margin: EdgeInsets.all(8.0),
          elevation: 4.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150.0,
                width: double.infinity,
                child: Image.asset(
                  widget.product.image,
                  height: 150.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              ListTile(
                title: Text(
                  widget.product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(widget.product.category),
              ),
            ],
          ),
        ),
      ),
      secondChild: InkWell(
        onTap: () {
          isCheck = !isCheck;
          setState(() {});
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Text(
            '${widget.product.name} (i)',
            style: TextStyle(
              fontFamily: 'Avenir',
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      crossFadeState:
          isCheck ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 400),
    );
  }
}


class CustomSearchDelegate extends SearchDelegate<String> {
  final List<Product> products;

  CustomSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Product> searchResults = products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return searchResults.isEmpty
        ? Center(
            child: Text(
              'Нет результатов для запроса "$query"',
              style: TextStyle(fontSize: 16.0),
            ),
          )
        : ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(searchResults[index].name),
                subtitle: Text(searchResults[index].category),
                onTap: () {
                  print('Выбран товар: ${searchResults[index].name}');
                },
              );
            },
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Product> suggestionList = products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return suggestionList.isEmpty
        ? Center(
            child: Text(
              'Нет предложений для запроса "$query"',
              style: TextStyle(fontSize: 16.0),
            ),
          )
        : ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(suggestionList[index].name),
                subtitle: Text(suggestionList[index].category),
                onTap: () {
                  query = suggestionList[index].name;
                  showResults(context);
                },
              );
            },
          );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedCategory = 'Все';
  bool showFilteredResults = false;

  List<String> categories = ['Все', 'Овощи', 'Фрукты', 'Цитрусы'];

  List<Product> products = [
    Product('Яблоки', 'Фрукты', 'assets/apples.png'),
    Product('Бананы', 'Фрукты', 'assets/bananas.png'),
    Product('Lemons', 'Цитрусы', 'assets/lemons.png'),
    // Добавьте еще товаров по аналогии
  ];

  List<Product> getFilteredProducts() {
    if (selectedCategory == 'Все') {
      return products;
    } else {
      return products.where((product) => product.category == selectedCategory).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    // Обновляем состояние при инициализации
    setState(() {
      showFilteredResults = categories[0] == selectedCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text('Магазин продуктов Mandelnyam'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Открываем корзину'),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              String? result = await showSearch(
                context: context,
                delegate: CustomSearchDelegate(products),
              );
              if (result != null && result.isNotEmpty) {
                setState(() {
                  selectedCategory = 'Все';
                  showFilteredResults = true;
                });
              }
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Опция 1'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Выбрана опция 1'),
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: Text('Опция 2'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Выбрана опция 2'),
                      ),
                    );
                  },
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Меню',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Избранное'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Открываем Избранное'),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Профиль'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Открываем Профиль'),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Открываем Настройки'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(''),
              background: Image.asset(
                'assets/shop_header.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Категории',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: categories.map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? category : 'Все';
                            showFilteredResults = true;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Вместо AnimatedCrossFade используем Visibility
          Visibility(
            visible: showFilteredResults,
            child: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ProductCard(filteredProducts[index]);
                },
                childCount: filteredProducts.length,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Акции',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Открываем Корзину'),
              ),
            );
          }
        },
      ),
    );
  }
}
