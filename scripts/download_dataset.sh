#!/usr/bin/env bash
# Downloads the minimal Atari replay dataset for a given game.
# The dataset is hosted at gs://atari-replay-datasets/dqn/{GAME}/1/replay_logs/
# and requires gsutil (https://cloud.google.com/storage/docs/gsutil_install).
#
# Usage: bash scripts/download_dataset.sh [GAME] [DATA_DIR] [NUM_BUFFERS]
#   GAME:        Atari game name, e.g. Breakout (default: Breakout)
#   DATA_DIR:    Local directory to store the dataset (default: /data/minimal-atari-replay-dataset)
#   NUM_BUFFERS: Number of replay buffer checkpoints to download (default: 50, range: 1-50)
#
# Example:
#   bash scripts/download_dataset.sh Breakout /data/minimal-atari-replay-dataset 50

set -e

GAME=${1:-Breakout}
DATA_DIR=${2:-/data/minimal-atari-replay-dataset}
NUM_BUFFERS=${3:-50}

GCS_BUCKET="gs://atari-replay-datasets/dqn"
RUN=1
LOCAL_DIR="${DATA_DIR}/${GAME}/${RUN}/replay_logs"

if [ "${NUM_BUFFERS}" -lt 1 ] || [ "${NUM_BUFFERS}" -gt 50 ]; then
    echo "Error: NUM_BUFFERS must be between 1 and 50 (got ${NUM_BUFFERS})"
    exit 1
fi

echo "Downloading ${NUM_BUFFERS} replay buffer(s) for game: ${GAME}"
echo "Destination: ${LOCAL_DIR}"

mkdir -p "${LOCAL_DIR}"

START_BUFFER=$((50 - NUM_BUFFERS))

for i in $(seq "${START_BUFFER}" 49); do
    echo "Downloading buffer ${i}..."
    gsutil -m cp \
        "${GCS_BUCKET}/${GAME}/${RUN}/replay_logs/\$store\$_action_ckpt.${i}.gz" \
        "${GCS_BUCKET}/${GAME}/${RUN}/replay_logs/\$store\$_add_count_ckpt.${i}.gz" \
        "${GCS_BUCKET}/${GAME}/${RUN}/replay_logs/\$store\$_invalid_range_ckpt.${i}.gz" \
        "${GCS_BUCKET}/${GAME}/${RUN}/replay_logs/\$store\$_observation_ckpt.${i}.gz" \
        "${GCS_BUCKET}/${GAME}/${RUN}/replay_logs/\$store\$_reward_ckpt.${i}.gz" \
        "${GCS_BUCKET}/${GAME}/${RUN}/replay_logs/\$store\$_terminal_ckpt.${i}.gz" \
        "${LOCAL_DIR}/"
done

echo "Done! Dataset for ${GAME} downloaded to ${DATA_DIR}/${GAME}/"
