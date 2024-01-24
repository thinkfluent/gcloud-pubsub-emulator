#!/bin/sh

: "${PUBSUB_PORT:=8681}"
: "${READY_PORT:=8682}"

# Start pubsubc in the background. It will poll for an open PubSub
# emulator port and create its topics and subscriptions when it's up.
#
# After it's done, port READY_PORT will be open to facilitate the wait-for and
# wait-for-it scripts from other applications/containers
(/usr/bin/wait-for localhost:${PUBSUB_PORT} -- env PUBSUB_EMULATOR_HOST=localhost:${PUBSUB_PORT} /usr/bin/pubsubc -debug; nc -lkp ${READY_PORT} >/dev/null) &

# Start the PubSub emulator in the foreground.
exec /google-cloud-sdk/platform/pubsub-emulator/bin/cloud-pubsub-emulator --port=${PUBSUB_PORT} --host=0.0.0.0
