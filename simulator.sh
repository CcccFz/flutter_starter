#!/usr/bin/env bash

set -euo pipefail

collect_emulators() {
  if ! command -v flutter >/dev/null 2>&1; then
    echo "未找到 flutter 命令，请先确认 Flutter SDK 已加入 PATH。" >&2
    exit 1
  fi

  flutter emulators 2>/dev/null | awk -F ' • ' '
    NF == 4 && $1 != "Id" {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $4)
      if ($1 != "") {
        printf "%s\t%s\t%s\t%s\n", $1, $2, $3, $4
      }
    }
  '
}

print_emulators() {
  local index=1
  local id name manufacturer platform

  while IFS=$'\t' read -r id name manufacturer platform; do
    printf '%2d) %-22s %-18s %-10s %s\n' "$index" "$id" "$name" "$manufacturer" "$platform"
    index=$((index + 1))
  done <<< "$EMULATORS"
}

choose_emulator() {
  local selected=""

  if [[ -n "${REQUESTED_ID:-}" ]]; then
    selected="$(awk -F '\t' -v requested="$REQUESTED_ID" '$1 == requested { print; exit }' <<< "$EMULATORS")"
    if [[ -z "$selected" ]]; then
      echo "未找到模拟器 id: $REQUESTED_ID" >&2
      exit 1
    fi

    printf '%s\n' "$selected"
    return 0
  fi

  if command -v fzf >/dev/null 2>&1; then
    selected="$(
      awk -F '\t' '{ printf "%-22s %-18s %-10s %s\t%s\n", $1, $2, $3, $4, $1 }' <<< "$EMULATORS" |
        fzf --prompt='选择模拟器 > ' --height=40% --reverse --with-nth=1 --delimiter=$'\t' || true
    )"

    if [[ -n "$selected" ]]; then
      local id
      id="$(awk -F '\t' '{ print $2 }' <<< "$selected")"
      awk -F '\t' -v id="$id" '$1 == id { print; exit }' <<< "$EMULATORS"
      return 0
    fi
  fi

  print_emulators
  echo
  read -r -p "输入序号或模拟器 id: " selected

  if [[ "$selected" =~ ^[0-9]+$ ]]; then
    awk -F '\t' -v index="$selected" 'NR == index { print; exit }' <<< "$EMULATORS"
  else
    awk -F '\t' -v id="$selected" '$1 == id { print; exit }' <<< "$EMULATORS"
  fi
}

main() {
  REQUESTED_ID="${1:-}"
  EMULATORS="$(collect_emulators)"

  if [[ -z "$EMULATORS" ]]; then
    echo "未找到可启动的 Flutter 模拟器。" >&2
    echo "可运行 flutter emulators 查看详情，或用 flutter emulators --create 创建 Android 模拟器。" >&2
    exit 1
  fi

  local selected id name manufacturer platform
  selected="$(choose_emulator)"

  if [[ -z "$selected" ]]; then
    echo "未选择模拟器。" >&2
    exit 1
  fi

  IFS=$'\t' read -r id name manufacturer platform <<< "$selected"

  echo "启动模拟器: $name ($id, $platform)"
  flutter emulators --launch "$id"
}

main "$@"
