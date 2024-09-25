part of 'drivers_bloc.dart';

@immutable
sealed class DriversState {}

final class DriversInitial extends DriversState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DriversLoadSuccess extends DriversState {
  final List<Driver>? drivers;
  DriversLoadSuccess({
    required this.drivers,
  });
}

final class DriversLoadingInProgress extends DriversState {}

final class DriversLoadFailed extends DriversState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class UpdateDriverLoadingInProgress extends DriversState {}

final class UpdateDriverSuccess extends DriversState {
  final int statusCode;
  final List<Driver>? drivers;
  UpdateDriverSuccess({required this.statusCode, required this.drivers});
}

final class UpdateDriverFailed extends DriversState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DeleteDriverLoadingInProgress extends DriversState {}

final class DeleteDriverSuccess extends DriversState {
  final int statusCode;
  final List<Driver>? drivers;
  DeleteDriverSuccess({required this.statusCode, required this.drivers});
}

final class DeleteDriverFailed extends DriversState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class CreateDriverLoadingInProgress extends DriversState {}

final class CreateDriverSuccess extends DriversState {
  final int statusCode;
  final List<Driver>? drivers;
  CreateDriverSuccess({required this.statusCode, required this.drivers});
}

final class CreateDriverFailed extends DriversState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class SearchDriverLoadingInProgress extends DriversState {}

final class SearchDriverSuccess extends DriversState {
  final List<Driver>? drivers;
  SearchDriverSuccess({required this.drivers});
}

final class SearchDriverFailed extends DriversState {}