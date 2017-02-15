FROM python:2.7

# Update
RUN apt-get update
RUN apt-get install -y git wget gcc make g++

# Install app dependencies
RUN pip install webob PasteDeploy PasteScript sqlalchemy simplejson

# Bundle app source
RUN mkdir -p /anki/server
RUN mkdir -p /anki/data
RUN ln -s /anki/server/ankiserverctl.py /usr/bin/ankiserverctl.py

RUN useradd -m runner

COPY run-server.sh /usr/bin/runserver.sh
COPY production.ini /anki/
RUN chmod +x /usr/bin/runserver.sh

EXPOSE  27701
CMD ["/usr/bin/runserver.sh"]
