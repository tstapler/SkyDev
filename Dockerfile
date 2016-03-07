FROM ubuntu:14.04

WORKDIR /app

ENV DB_HOST=postgres
ENV DB_PORT=5432
ENV DB_PASS=pass
ENV DB_USER=postgres
ENV DB_NAME=skydev

#Install needed dependencies

RUN sudo apt-get update && sudo apt-get install -y python-dev python-pip
RUN pip install ansible
ADD . /app
RUN ansible-playbook -i "localhost," -c local /app/scripts/installer.yaml


ADD pubspec.* /app/
RUN pub get
RUN pub get --offline
RUN pub build
RUN pub install

EXPOSE 8081

CMD ["/app/scripts/launchserver.sh"]
