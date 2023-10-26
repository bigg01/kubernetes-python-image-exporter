# Build stage
FROM gcr.io/distroless/python3 AS build

# Set the working directory to /app
WORKDIR /app

ENV APP_NAME=prom-image-exporter

# Copy the requirements file into the container
COPY Pipfile . 
# Install the dependencies
RUN pip install --no-cache-dir pipenv && \
    pipenv install 
    #--system --deploy --ignore-pipfile

# Copy the rest of the application code into the container
COPY prom-image-exporter.py . 

RUN pipenv run pyinstaller --noconfirm --log-level=INFO \
    --onefile --nowindow \
	${APP_NAME}.py
	du -hs ./dist/${APP_NAME}
	ldd ./dist/${APP_NAME}
# Runtime stage
FROM redhat/ubi8-minimal AS runtime

# Set the working directory to /app
WORKDIR /app

# Copy the application code from the build stage
COPY --from=build /app .

# Set the command to run when the container starts
CMD ["ls", "-l", "/app"]