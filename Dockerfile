########################################################################################################################
# Build an alpine-based gcloud image with the pubsub emulator installed
FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:548.0.0-alpine AS alpine_gcloud

# RUN apk add openjdk11

RUN gcloud components install beta --quiet

RUN gcloud components install beta pubsub-emulator --quiet

########################################################################################################################
# Build the pubsubc application and other runtime tooling
FROM golang:alpine AS builder

RUN apk update && apk upgrade && apk add --no-cache curl git

RUN curl -s https://raw.githubusercontent.com/eficode/wait-for/master/wait-for -o /usr/bin/wait-for
RUN chmod +x /usr/bin/wait-for

# Install pubsubc, with a patch for HTTP+HTTPS push endpoint support & docker label support
RUN go install github.com/thinkfluent/pubsubc@d6679feea13d642c1472e1c4479d0f088c7acfb9

########################################################################################################################
# Runtime image
FROM alpine:latest

# Install JRE and netcat
RUN apk --no-cache add openjdk11-jre-headless netcat-openbsd

# Pull the PubSub emulator from our earlier install phase
COPY --from=alpine_gcloud /google-cloud-sdk/platform/pubsub-emulator /google-cloud-sdk/platform/pubsub-emulator

# Copy the pubsubc binary and wait-for script
COPY --from=builder /usr/bin/wait-for /usr/bin
COPY --from=builder /go/bin/pubsubc   /usr/bin
COPY                run.sh            /run.sh

CMD /run.sh


