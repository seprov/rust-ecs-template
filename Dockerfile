FROM rust:1.67 as builder
WORKDIR /usr/src/
COPY Cargo.lock .
COPY Cargo.toml .
COPY ./src/ ./src/
COPY ./data ./data/
RUN cargo build --release

FROM debian:bookworm-slim
WORKDIR /usr/src/
COPY --from=builder /usr/src/target/release/rq /usr/local/bin/rq
COPY --from=builder /usr/src/data/ ./data/
EXPOSE 8080

CMD ["rq"]
