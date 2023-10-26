# Build stage
FROM python:3.10.13-slim-bullseye AS build

# Set the working directory to /app
# WORKDIR /app

ENV APP_NAME=prom-image-exporter

# Copy the requirements file into the container
COPY Pipfile . 
# Install the dependencies
RUN apt update && apt install -y python3-pip && \
    pip install --no-cache-dir pipenv && \
    pipenv install

# Copy the rest of the application code into the container
COPY prom-image-exporter.py . 

RUN pipenv run pyinstaller --noconfirm --log-level=INFO \
    --onefile --nowindow \
	${APP_NAME}.py && \
    ls -larht && \
	du -hs ./dist/${APP_NAME} && \
	ldd ./dist/${APP_NAME}
    
# Runtime stage
FROM redhat/ubi8-minimal AS runtime

# Set the working directory to /app
#WORKDIR /app

# Copy the application code from the build stage
COPY --from=build . .

# Set the command to run when the container starts
CMD ["ls", "-l", "/app"]