FROM alpine:3 as builder
RUN apk add --no-cache cargo
RUN cargo install mdbook
RUN cargo install mdbook-toc

FROM alpine:3
RUN apk add --no-cache libgcc
COPY --from=builder /root/.cargo/bin/mdbook /bin/mdbook
COPY --from=builder /root/.cargo/bin/mdbook-toc /bin/mdbook-toc
