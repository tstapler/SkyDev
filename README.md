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
--create      Creates tables in the database
--migrate     Runs the databases migrations
--rollback    Rollsback the databases migrations
--delete      Deletes tables from the database
--help        Displays the help materials
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

## Techs
Dart makes use of the following

- [trestle](https://github.com/dart-bridge/trestle) for database migrations and ORM

