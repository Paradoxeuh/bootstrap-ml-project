FROM python:3.10-bullseye

# Upgrade pip and install scipy dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y build-essential cmake python3-dev gfortran \
        libblas-dev liblapack-dev libatlas-base-dev \
    && pip --disable-pip-version-check install --upgrade pip

# Create non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

USER $USERNAME

# Setup the application
RUN mkdir /home/$USERNAME/app
WORKDIR /home/$USERNAME/app

ENV PATH=/root/.local/bin:/home/$USERNAME/.local/bin:$PATH

RUN python3 -m pip install pipx && python3 -m pipx ensurepath --force && pipx install poetry

COPY pyproject.toml ./
RUN poetry config --local virtualenvs.in-project true \
    && poetry install

COPY src/ ./src

