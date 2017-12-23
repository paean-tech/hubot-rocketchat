FROM node:9.3.0
MAINTAINER Paean <jason.yuen@paean.net>

RUN npm install -g coffee-script yo generator-hubot  &&  \
  useradd chatbot -m

USER chatbot

WORKDIR /home/chatbot/rocketchat

USER root
RUN chown chatbot:chatbot -R /home/chatbot/rocketchat
USER chatbot

ENV BOT_NAME "rocketbot"
ENV BOT_OWNER "No owner specified"
ENV BOT_DESC "Hubot with rocketbot adapter"


ENV EXTERNAL_SCRIPTS=hubot-pugme,hubot-help

RUN yo hubot --owner="$BOT_OWNER" --name="$BOT_NAME" --description="$BOT_DESC" --defaults && \
  sed -i /heroku/d ./external-scripts.json && \
  sed -i /redis-brain/d ./external-scripts.json

ADD . /home/chatbot/rocketchat

RUN cd /home/chatbot/rocketchat && \
  npm install

CMD cd /home/chatbot && \
  npm install && \
  cd /home/chatbot/rocketchat && \
  node -e "console.log(JSON.stringify('$EXTERNAL_SCRIPTS'.split(',')))" > external-scripts.json && \
  npm install $(node -e "console.log('$EXTERNAL_SCRIPTS'.split(',').join(' '))") && \
  bin/hubot -n $BOT_NAME -a rocketchat