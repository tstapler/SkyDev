FROM google/dart

WORKDIR /app
ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline

EXPOSE 8081

CMD []

ENTRYPOINT ["/usr/bin/dart", "server.dart"]
