FROM ubuntu

RUN apt update
RUN apt -y install mini-httpd

WORKDIR /var/www/html
COPY index.html .

EXPOSE 80

RUN chmod u=rw,g=r,o=r index.html

CMD ["mini_httpd", "-dd", "/var/www/html", "-D"]