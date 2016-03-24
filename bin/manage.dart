import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:skydev/database.dart';
import 'package:trestle/gateway.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

seed_db(String file_name) async
{
  if(file_name == null) return;
      var relative_to = Directory.current.path;
      var file = new File(relative_to + "/" + file_name);
      var doc = loadYaml(file.readAsStringSync());
      var to_add = [];
      for(var user in doc["users"]){
        print("Adding: ${user['username']}");
        to_add.add(new User.create(user['username'],
                                   user['email'],
                                   hash_password(user['password'])));
      }
      await users.saveAll(to_add);
}

create_parser() {
  var parser = new ArgParser();

  parser
    ..addFlag('create',
               abbr:'c',
               help: 'Creates tables in the database',
               negatable: false)
    ..addFlag('migrate',
               abbr:'m',
               help: 'Runs the databases migrations',
               negatable: false)
    ..addFlag('rollback',
               abbr:'r',
               help: 'Rollsback the databases migrations',
               negatable: false)
    ..addFlag('delete',
               abbr:'d',
               help: 'Deletes tables from the database',
               negatable: false)
    ..addOption('seed',
              abbr:'s',
              help: 'Seeds Database from file',
              valueHelp: 'file (relative to your current directory)')
    ..addFlag('help',
               abbr:'h',
               help: 'Displays the help materials',
               negatable: false);
  return parser;
}

main(List<String> args) async {
  await db_gateway.connect();
  //Create command argument parser
  var parser = create_parser();
  var results = parser.parse(args);
  try {
    if (results['help']) {
      print("${parser.usage}");
    } else if (results['seed'] != null){
      await seed_db(results['seed']);
    }else if (results['create']) {
      await create_db(db_gateway);
    } else if (results['delete']) {
      await delete_db(db_gateway);
    } else if (results['migrate']) {
      await db_gateway.migrate(migrations);
    } else if (results['rollback']) {
      await db_gateway.rollback(migrations);
    } else {
      print("${parser.usage}");
    }
  } catch (e) {
    print(e);
  }

  // Disconnect when you're done
  await db_gateway.disconnect();
}
