enum DriverOrderTab { newOrders, ongoing, completed }

extension DriverOrderTabLabel on DriverOrderTab {
  String get label {
    switch (this) {
      case DriverOrderTab.newOrders:
        return 'طلبات جديدة';
      case DriverOrderTab.ongoing:
        return 'طلباتي الجارية';
      case DriverOrderTab.completed:
        return 'المكتملة';
    }
  }
}
