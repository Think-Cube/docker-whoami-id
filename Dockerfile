FROM --platform=$BUILDPLATFORM golang:1.27.4-alpine3.24@sha256:70bd7ddea8b6cbe5d6943cde279d6b67feb10cc924fb9100d1d8757c1575b280 AS build

ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0

WORKDIR /src

COPY go.mod *.go ./

# Vet and test on the build platform, then cross-compile a static binary for the target.
RUN go vet ./... && \
    go test ./... && \
    GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags="-s -w" -o /out/whoami .

FROM scratch

LABEL org.opencontainers.image.title="whoami-id" \
      org.opencontainers.image.description="Tiny HTTP server that answers with the container's hostname" \
      org.opencontainers.image.vendor="Think-Cube" \
      org.opencontainers.image.authors="contact@thinkcube.dev" \
      org.opencontainers.image.licenses="MIT"

COPY --from=build /out/whoami /whoami

ENV PORT=8000

EXPOSE 8000

USER 10001:10001

ENTRYPOINT ["/whoami"]
