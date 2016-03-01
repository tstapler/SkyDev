# SkyDev
Contributors: Josua Gonzales-Neal, Sambhav Srirama, 
Chris Stapler, Tyler Stapler
 
## Description
A cloud based IDE 

## Use 

### Running the server
In order to use *SkyDev* follow these steps:

1. Install the dependencies 
```bash
make install-dependencies
```
2. Run the server
```bash
make it
```
3. Open <https://localhost:8081>

### Database Manager
---
**Usage:**
```
dart bin/manage.dart
-c, --create                                              Creates tables in the database
-m, --migrate                                             Runs the databases migrations
-r, --rollback                                            Rollsback the databases migrations
-d, --delete                                              Deletes tables from the database
-s, --seed=file (relative to your current directory)      Seeds Database from file
-h, --help                                                Displays the help materials
```
---

#### Create
Create tables in your database

**Command**:
```bash
dart bin/manager.dart --create
```
**Output**:
```bash
skydev=# \d
                    List of relations
		  Schema |        Name         |   Type   |  Owner
		  --------+---------------------+----------+----------
		  public | users               | table    | postgres
		  public | users_id_seq        | sequence | postgres
```

#### Delete
Delete your tables from the database. Note that you must not use this command after 
running migrations. It will orphan your migrations tables and make things unplesant.

**Command**:
```bash
dart bin/manager.dart --delete
```
**Output**:
```bash
skydev=# \d
No relations found.
```

#### Migrate
Makes your migrations. Will only work after **Create** has been run.


**Command**:
```bash
dart bin/manager.dart --migrate
```
**Output**:
```
skydev=# \d
                 List of relations
 Schema |        Name         |   Type   |  Owner
--------+---------------------+----------+----------
 public | __migrations        | table    | postgres
 public | __migrations_id_seq | sequence | postgres
 public | users               | table    | postgres
 public | users_id_seq        | sequence | postgres
```

#### Rollback
Removes your migrations from the database. Only run after perfoming migrations

**Command**:
```bash
dart bin/manager.dart --rollback
```
**Output**:
```
skydev=# \d
No relations found.
```

#### Seed
Puts sample data into the database

**Command**:
```bash
dart bin/manager.dart --seed seeddata.yaml
```
**Output**:
```bash
Adding: tstapler
Adding: cstapler
Adding: jgn
Adding: ssrirama

skydev=# select * from users;

 id | username |        email         |                           password                           |         created_at         |         updated_at
----+----------+----------------------+--------------------------------------------------------------+----------------------------+----------------------------
  1 | tstapler | tstapler@iastate.edu | $2a$10$/m.e5J.yqi3GLdYu2MCSB..TuBq8pk0gTZf56QR.NGlSWFrK.U2Ba | 2016-03-01 11:19:40.454151 | 2016-03-01 11:19:40.454151
  2 | cstapler | cstapler@iastate.edu | $2a$10$6g.OQEGuwYvucHd2WKMia.f4oOzgsZcfy5ckOoqZpMAtLrhckbjKK | 2016-03-01 11:19:40.576388 | 2016-03-01 11:19:40.576388
  3 | jgn      | jgn@iastate.edu      | $2a$10$YA/2mRo6JMnWxFj2GD3qj.dE9PB05FUEpynEPH/RjIXWIVk2L1y/a | 2016-03-01 11:19:40.698401 | 2016-03-01 11:19:40.698401
  4 | ssrirama | ssrirama@iastate.edu | $2a$10$1hBe8fHKhwjGGTt22Ne2t.7K0a7btxTOfoNHsINDI6wF1goze.rOK | 2016-03-01 11:19:40.82207  | 2016-03-01 11:19:40.822071
```


## Techs
Dart makes use of the following

- [trestle](https://github.com/dart-bridge/trestle) for database migrations and ORM

