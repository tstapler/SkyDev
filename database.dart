import 'package:trestle/gateway.dart';

class Users {
  int id;
  String username;
  String email;
  String password;
}

class CreateUsersTable extends Migration {
  Future run (Gateway gateway) {
    await gateway.create('users', (Schema schema){
      schema.id();
      schema.string('username').unique().nullable(false);
      schema.string('email').unique().nullable(false);
      schema.string('password', 60);
      schema.timestamps();
    });
  }

  Future rollback(Gateway gateway){
    await gateway.drop('users');
  }
}

main() async {
  // The database implementation
  Driver driver = new PostgresqlDriver(username: 'postgres',
      password: 'pass',
      port: 5433, //To Avoid Conflicts
      database: 'skydev');

  // The gateway takes the driver as a constructor argument
  Gateway gateway = new Gateway(driver);

  // Next, connect!
  await gateway.connect();


  // Disconnect when you're done
  await gateway.disconnect();
}
