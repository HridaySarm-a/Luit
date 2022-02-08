import 'package:get_it/get_it.dart';
import 'package:luit/dynamicLink.dart';

GetIt locator = GetIt.instance;

void setupLocator() 
{
	locator.registerLazySingleton(() => DynamicLinkService());
}