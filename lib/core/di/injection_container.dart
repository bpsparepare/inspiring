import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Repository
  // sl.registerSingleton<Repository>(RepositoryImpl());

  // Use cases
  // sl.registerSingleton<UseCase>(UseCase(sl()));

  // BLoC
  // sl.registerFactory<MyBloc>(() => MyBloc(sl()));
}
