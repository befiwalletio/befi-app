import 'package:logger/logger.dart';

class Console{
  static Console _instance = Console.create();
  factory Console()=>_instance;

  static Logger logger;
  Console.create(){
    logger = Logger(
      printer: PrettyPrinter(),
    );
  }

  debug(dynamic message){
    logger.d(message);
  }
  info(dynamic message){
    logger.i(message);
  }
  warn(dynamic message){
    logger.w(message);
  }
  error(dynamic message){
    logger.e(message);
  }

  static d(dynamic message){
    Console();
    logger.d(message);
  }
  static i(dynamic message){
    Console();
    logger.i(message);
  }
  static w(dynamic message){
    Console();
    logger.w(message);
  }
  static e(dynamic message){
    Console();
    logger.e(message);
  }

}

class console{
  static d(dynamic message){
    Console();
    Console.logger.d(message);
  }
  static i(dynamic message){
    Console();
    Console.logger.i(message);
  }
  static w(dynamic message){
    Console();
    Console.logger.w(message);
  }
  static e(dynamic message){
    Console();
    Console.logger.e(message);
  }
}