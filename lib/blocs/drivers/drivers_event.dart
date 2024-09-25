part of 'drivers_bloc.dart';

@immutable
sealed class DriversEvent {}

final class FetchAllDrivers extends DriversEvent{
  FetchAllDrivers();
}

final class UpdateDriver extends DriversEvent{
  final int id;
  final String newDriverName;
  final String newUniqueId;
  UpdateDriver(this.id, this.newDriverName, this.newUniqueId);
}

final class DeleteDriver extends DriversEvent{
  final int id;
  DeleteDriver(this.id);
}

final class CreateDriver extends DriversEvent{
  final String driverName;
  final String uniqueId;
  CreateDriver( this.driverName, this.uniqueId);
}

final class SearchDriver extends DriversEvent{
  final List<Driver>? drivers;
  final String searchedString;
  SearchDriver(this.drivers,this.searchedString);
}