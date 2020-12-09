FROM python:3.8-slim

ENV USER_NAME="taxophages"
ENV HOME="/home/${USER_NAME}"
RUN useradd -m $USER_NAME
USER $USER_NAME

ENV APP_DIR="${HOME}/app"
ENV PATH="${HOME}/.local/bin:${PATH}"

WORKDIR $HOME
RUN mkdir -p ${APP_DIR}/requirements
ADD requirements/base.pip ${APP_DIR}/requirements/base.pip
RUN pip3 install -r ${APP_DIR}/requirements/base.pip --user

ADD taxophages $APP_DIR
ADD main.py $APP_DIR
WORKDIR $APP_DIR

CMD ["python", "main.py", "-h"]