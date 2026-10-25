enum ShopType {
  spaza,
  liquor;

  String get id => name;

  String get label => this == ShopType.spaza ? 'My Spaza Shop' : 'My Liquor Shop';

  String get shortLabel => this == ShopType.spaza ? 'Spaza Shop' : 'Liquor Shop';

  String get subtitle => this == ShopType.spaza
      ? 'Bread, milk, household goods & daily essentials'
      : 'Beverages, crates & bottle returns';
}
