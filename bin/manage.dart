import 'package:args/args.dart';
import 'dart:async';
import 'dart:io';
import 'package:trestle/gateway.dart';
import 'package:skydev/database.dart';

final migrations = [
CreateUsersTable
].toSet();


create_parser()
{
  var parser = new ArgParser();

  parser
    ..addFlag('create', help: 'Creates tables in the database')
    ..addFlag('migrate', help: 'Runs the databases migrations')
    ..addFlag('rollback', help: 'Rollsback the databases migrations')
    ..addFlag('delete', help:  'Deletes tables from the database')
    ..addFlag('help', help: 'Displays the help materials');
  return parser;
}
main(List<String> args) async{
  //Create Database Connection
  Driver db_driver = new PostgresqlDriver(username: 'postgres',
                                          password: 'pass',
                                          port: 5433, //To Avoid Conflicts
                                          database: 'skydev');
  Gateway db_gateway = new Gateway(db_driver);

  await db_gateway.connect();

  //Create command argument parser
  var parser = create_parser();
  var results = parser.parse(args);

  if (results['help']) 
  {
    print("${parser.usage}");
  } 
  else if(results['create']) 
  {
    await create_db(db_gateway);
  } 
  else if(results['delete'])
  {
    await delete_db(db_gateway);

  }
  else if(results['migrate']) 
  {
    await db_gateway.migrate(migrations);
  } 
  else if(results['rollback']) 
  {
    await db_gateway.rollback(migrations);
  } 
  else 
  {
    print("""
        ${parser.usage}
        ${results.arguments}
        """);
  }

  // Disconnect when you're done
  await db_gateway.disconnect();
}
