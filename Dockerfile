FROM node:12


ENV NODE_ENV "production"
ENV POPULATE_DB "true"

# Change me in production
ENV DB_URI "mongodb://169.254.129.3:27017/a11y-req"
ENV BASIC_AUTH_USERNAME "ictaccessibility-db"
ENV BASIC_AUTH_PASSWORD "zSZahFS5wwHKhq0XsY3NuAXxnqWaPu7vu9JItRqpLQiOidYyI5WbbVLU7IzyT8Rz0gNqmeJQaDPuiEY6oEHyKQ=="
ENV WAIT_FOR_MONGO "true"
ENV WAIT_HOSTS "mongodb://169.254.129.3:27017/a11y-req"




# Installing NGINX for reverse proxy
RUN apt update && \
apt install -y nginx && \
rm /etc/nginx/sites-available/default && \
rm /etc/nginx/sites-enabled/default

RUN apt-get install -y net-tools
RUN apt-get install -y mongodb

# dos2unix used to convert scripts written on windows systems to unix formats
RUN apt-get install -y dos2unix
RUN mkdir /home/app

# install node process manager pm2 
RUN npm install -g pm2

WORKDIR /home/app
SHELL ["/bin/bash", "-c"]

RUN wget -q https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian92-x86_64-100.0.2.tgz && \
tar -xzf mongodb-database-tools-debian92-x86_64-100.0.2.tgz  && \
mv mongodb-database-tools-debian92-x86_64-100.0.2 mongotools && \
chmod 777 ./mongotools/bin/mongorestore 

RUN apt-get install -y netcat
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.2.1/wait ./wait
RUN chmod +x ./wait

COPY ./nginx ./nginx

# copying over nginx vhost to appropriate location and testing configuration
RUN dos2unix ./nginx/default.conf && \
mv ./nginx/default.conf /etc/nginx/sites-enabled/default

RUN dos2unix ./nginx/nginx.conf && \
mv ./nginx/nginx.conf /etc/nginx/nginx.conf && \
nginx -t 

RUN dos2unix ./scripts/mongodb.conf && \
mv ./scripts/mongodb.conf /etc/mongodb.conf





# copy over application files 
COPY . .

# install dependencies 
RUN npm install

RUN apt-get update && apt-get install -y vim

RUN apt-get update && apt-get install -y ssh
RUN echo "root:Docker!" | chpasswd
RUN mkdir /run/sshd
COPY sshd_config /etc/ssh/

RUN dos2unix ./scripts/start.sh

# make startup script executable 
RUN chmod 777 ./scripts/start.sh 

# make the script to be the entrypoint
ENTRYPOINT [ "/bin/bash", "scripts/start.sh" ]
EXPOSE 80 2222 27017 27018





