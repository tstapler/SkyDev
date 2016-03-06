# SkyDev
Contributors: Josua Gonzales-Neal, Sambhav Srirama, 
Chris Stapler, Tyler Stapler
 
## Description
A web-based IDE 

## Use 

### Running the server

When running *SkyDev* for the first time follow these steps:

1. Set your desired database configuration
Sample configuration
```bash
source scripts/sample_config.sh
```

Or, one could set the following 

2. Install the dependencies 
```bash
make install-dependencies
```

3. Logout and back in to ensure your new docker group is enabled

4. Run the server
```bash
make it
```

5. Open <https://localhost:8081>

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

### Deployment With Docker 

An example of how to build and deploy the project using docker

#### Build an Image:

Build the SkyDev container from the home directory 

```bash docker build -t tstapler/skydev . ```

#### Push:

Push your newly built image to docker hub 

1. Create a Docker Hub account and login
```bash 
docker login 
Username: tstapler 
Password: 
Email: tystapler@gmail.com 
WARNING: login credentials saved in
/home/tstapler/.docker/config.json Login Succeeded 
```

2. Push your newly tagged image to docker hub

```bash
docker push tstapler/skydev

The push refers to a repository [docker.io/tstapler/skydev] 
140c56b6c50f: Preparing 
fcef89949268: Preparing 
97445628161b: Preparing 
140c56b6c50f: Layer already exists 
2a951c507b04: Layer already exists
a18c01fcb17f: Layer already exists
3b267d287e15: Layer already exists
04615e3a9cc9: Layer already exists
948c7db9b47c: Layer already exists
bbf51cf12065: Layer already exists
a9660e7f7c70: Layer already exists
5f70bf18a086: Layer already exists
c021cee30347: Layer already exists
947564b0c8d9: Layer already exists
latest:digest: sha256:ca944f59c33678ccd37098c7ae5f221dcd597f8c9f13e105ec02c2f801975036size: 12281
```

### Run SkyDev on host using Docker

Ensure the host you have both **docker** and **docker-compose** installed.

```bash 
docker-compose up 

Recreating g39skydev_postgres_1 
Recreating g39skydev_skydev_1
```

Yay! You have a running server

## Techs
Dart makes use of the following

- [trestle](https://github.com/dart-bridge/trestle) for database migrations and ORM
- [ansible](https://github.com/ansible/ansible) for dependency management 
- [docker](https://github.com/docker/docker) for ease of setup and deployment
