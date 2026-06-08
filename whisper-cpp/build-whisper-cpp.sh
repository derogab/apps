#!/usr/bin/env sh
set -eu

repo_dir="/tmp/whisper.cpp"
image="whisper.cpp:main"

export DOCKER_BUILDKIT="${DOCKER_BUILDKIT:-1}"

if [ -d "$repo_dir/.git" ]; then
  git -C "$repo_dir" pull --ff-only
elif [ -e "$repo_dir" ]; then
  echo "$repo_dir already exists but is not a git checkout" >&2
  exit 1
else
  git clone --depth 1 https://github.com/ggml-org/whisper.cpp.git "$repo_dir"
fi

if [ -n "${HF_TOKEN:-}" ]; then
  docker build --secret id=HF_TOKEN,env=HF_TOKEN -f "$repo_dir/.devops/main.Dockerfile" -t "$image" "$repo_dir"
else
  docker build -f "$repo_dir/.devops/main.Dockerfile" -t "$image" "$repo_dir"
fi
