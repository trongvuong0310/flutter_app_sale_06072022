import '../../common/bases/base_repository.dart';

class OrderRepository extends BaseRepository{
  Future getOrders() {
    return apiRequest.getOrders();
  }
}