FROM google/dart

WORKDIR /app

ENV DB_HOST=postgres
ENV DB_PORT=5432
ENV DB_PASS=pass
ENV DB_USER=postgres
ENV DB_NAME=skydev

#Install needed dependencies
RUN echo "deb http://ftp.debian.org/debian sid main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -t sid install -y libc6 libc6-dev libc6-dbg
RUN apt-get install -y postgresql libpq-dev python-psycopg2

RUN apt-get install -y python-dev python-pip python-setuptools
RUN pip install ansible


ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline

EXPOSE 8081

CMD ["/app/scripts/launchserver.sh"]
