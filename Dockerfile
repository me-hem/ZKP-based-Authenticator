FROM rust:1.87.0

WORKDIR /zkp-server

COPY . .

RUN apt update
RUN apt install -y protobuf-compiler

RUN cargo build --release --bin server --bin client