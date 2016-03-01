import 'package:trestle/gateway.dart';


class Users {
  int id;
  String username;
  String email;
  String password;
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
