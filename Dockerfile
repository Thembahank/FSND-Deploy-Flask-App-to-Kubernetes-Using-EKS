FROM python:3.7.2-stretch

COPY . /app
WORKDIR /app

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install flask

ENTRYPOINT ["gunicorn","--bind", ":8080",  "--workers", "3", "main:APP"]

