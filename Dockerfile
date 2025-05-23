FROM python:3.10-slim

RUN apt-get update && \
    apt-get install -y git && \
    python3 -m pip install --upgrade pip

# Install system dependencies for building Python packages
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure environments vars. Overriden by GitHub Actions
ENV INPUT_SNOWFLAKE_ACCOUNT= ${{ secrets.SNOWFLAKE_ACCOUNT }}
ENV INPUT_SNOWFLAKE_USERNAME= ${{ secrets.SNOWFLAKE_USER }}
ENV INPUT_SNOWFLAKE_PASSWORD= ${{ secrets.SNOWFLAKE_PASSWORD }}
ENV INPUT_SNOWFLAKE_WAREHOUSE= ${{ secrets.SNOWFLAKE_WAREHOUSE }}
ENV INPUT_QUERIES=
ENV APP_DIR=/app

WORKDIR ${APP_DIR}

# setup python environ
COPY ./requirements.txt ${APP_DIR}
RUN pip install --upgrade pip wheel && \
    pip install -r ${APP_DIR}/requirements.txt

# copy app files
COPY . ./
RUN useradd -ms /bin/bash anecdotes
RUN chown -R anecdotes:anecdotes /app
USER anecdotes
# command to run in container start
CMD python ${APP_DIR}/main.py
