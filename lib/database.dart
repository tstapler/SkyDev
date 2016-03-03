import 'dart:io';
import 'package:trestle/trestle.dart';
import 'package:trestle/gateway.dart';
import 'package:dbcrypt/dbcrypt.dart';

class User extends Model {
  @field int id;
  @field String username;
  @field String email;
  @field String password;

  User();
  User.create(String this.username, String this.email, String this.password);

  String toString() => username + "(" + email + ")";
}

class CreateUsersTable extends Migration {
  Future run (Gateway gateway) {
    gateway.create('users', (Schema schema){
      schema.id();
      schema.string('username').unique().nullable(false);
      schema.string('email').unique().nullable(false);
      schema.string('password', 60);
      schema.timestamps();
    });
  }

  Future rollback(Gateway gateway){
    gateway.drop('users');
  }
}

 Future create_db(Gateway gateway){
     return gateway.create('users', (Schema schema){
          schema.id();
          schema.string('username').unique().nullable(false);
          schema.string('email').unique().nullable(false);
          schema.string('password', 60);
          schema.timestamps();
        });
}

Future delete_db(Gateway gateway) {
    return gateway.drop('users');
}

hash_password(plain){
 return new DBCrypt().hashpw(plain, new DBCrypt().gensalt());
}

check_password(plain, hashed)
{
 return new DBCrypt().checkpw(plain, hashed);
}

//Create set of migrations
final migrations = [CreateUsersTable].toSet();

Map<String, String> envVars = Platform.environment;

final String DB_HOST = envVars["DB_HOST"];
final String DB_PORT = envVars["DB_PORT"];
//Create Database Connection
final Driver db_driver = new PostgresqlDriver(host: DB_HOST,
                                        username: 'postgres',
                                        password: 'pass',
                                        port: DB_PORT, //To Avoid Conflicts
                                        database: 'skydev');

//Create Gateway (Representation of the database)
final Gateway db_gateway = new Gateway(db_driver);

//Create ORM mapping for users
final users = new Repository<User>(db_gateway);
