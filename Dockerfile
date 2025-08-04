# Use a lightweight C++ build image
FROM debian:bullseye-slim

# Set environment variables
ENV WHISPER_MODEL=ggml-base.en.bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    wget \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Clone whisper.cpp
RUN git clone https://github.com/ayushdh96/whisper.cpp.git

# Build whisper.cpp
WORKDIR /app/whisper.cpp
RUN cmake -S . -B build && cmake --build build -j && test -f build/bin/whisper-cli

# Download model
RUN mkdir -p /app/models && \
    wget -O /app/models/${WHISPER_MODEL} https://huggingface.co/ggerganov/whisper.cpp/resolve/main/${WHISPER_MODEL}

# Set default workdir when container runs
WORKDIR /app/whisper.cpp

# CMD expects the audio file path to be passed when the container is run
ENTRYPOINT ["./build/bin/whisper-cli"]