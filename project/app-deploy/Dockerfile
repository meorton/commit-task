FROM python:3.9

# Set the working directory in the container
WORKDIR /app



# Copy the Python script and requirements.txt into the container's /app directory
ADD commit.py /app/
ADD requirements.txt /app/
ADD .env /app/
RUN mkdir -p /app/templates
ADD templates /app/templates

RUN ls -al /app/


# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt


# Ensure read, write, and execute permissions for the /app directory and its contents
RUN chmod -R 777 /app

# Add a script to debug permissions and environment variables
RUN echo '#!/bin/sh\n' \
    'echo "Running as user: $(id)"\n' \
    'echo "Listing /app directory:"\n' \
    'ls -l /app\n' \
    'echo "Listing environment variables:"\n' \
    'python /app/commit.py' > /app/start.sh
RUN chmod +x /app/start.sh

# Run the container as the user with UID 1002
USER 1002

# Expose port 8080
EXPOSE 8080

# Run the start.sh script when the container launches
CMD ["/app/start.sh"]
