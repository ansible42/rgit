FROM nixos/nix:latest AS builder

WORKDIR /app
COPY . .

RUN nix --extra-experimental-features "nix-command flakes" --accept-flake-config build .#
RUN mkdir /tmp/nix-store-closure
RUN cp -R $(nix-store -qR result/) /tmp/nix-store-closure
RUN ls /app/result

FROM scratch

WORKDIR /app
COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /app/result /app
ENV PORT=3333
ENV DB_DIR=./rgit
ENV GIT_DIR=./git
ENTRYPOINT [ "rgit" ]
CMD ["[::]${PORT} ${GIT_DIR} -d ${DB_DIR}"]
