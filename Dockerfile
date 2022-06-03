FROM python:3

RUN apt-get update && apt-get install xsltproc

# WORKDIR /code

# RUN python setup.py install