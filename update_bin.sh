#!/bin/bash
# vc8000e/hantro_vc8000e_ext.ko 를 pim-package 배포 트리에 복사하고 매니페스트를 맞춘다.
# max9296 의 update_bin.sh 와 같은 방식이다. 다른 점 하나: 매니페스트 갱신 대상이
# 아직 등록되지 않았으면 복사 전에 멈춘다(복사 뒤에 실패하면 바이너리만 새것이 된다).

set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
ARTIFACT="$HERE/vc8000e/hantro_vc8000e_ext.ko"
DEST_REL="dist/pim/opt/pim/driver/hantro_vc8000e_ext.ko"
BUILD_HINT="./make-for-imx8"

PIM_PACKAGE_DIR="${PIM_PACKAGE_DIR:-}"
if [ -z "$PIM_PACKAGE_DIR" ] && [ -f "$HERE/.env" ]; then
    PIM_PACKAGE_DIR="$(sed -n 's/^PIM_PACKAGE_DIR=//p' "$HERE/.env" | tail -1)"
fi
PIM_PACKAGE_DIR="${PIM_PACKAGE_DIR:-$(dirname "$HERE")/pim-package-jhw}"
update_manifest=1

die() {
    echo "update_bin: $*" >&2
    exit 1
}

usage() {
    cat <<'USAGE'
update_bin.sh — hantro_vc8000e_ext.ko 를 pim-package 배포 트리에 복사하고 매니페스트를 맞춘다.

  ./update_bin.sh                          복사 + 매니페스트 갱신
  ./update_bin.sh --no-manifest            복사만
  ./update_bin.sh --pim-dir <경로>         대상 트리 지정
  PIM_PACKAGE_DIR=<경로> ./update_bin.sh   같은 것을 환경변수로 (.env 의 PIM_PACKAGE_DIR 보다 우선)

매니페스트 갱신은 pim-package 의 tools/verify_binaries.py --update 를 불러
sha256/size/mode/arch 를 실측 기입하고 source.commit 을 이 저장소 HEAD 로 맞춘다.
그 도구는 이미 등록된 경로만 갱신하므로, 처음 들일 때는 pim-package 쪽에서 항목을 먼저 만든다.
USAGE
}

while [ $# -gt 0 ]; do
    case "$1" in
        --pim-dir)
            shift
            [ $# -gt 0 ] || die "--pim-dir 뒤에 경로가 필요하다"
            PIM_PACKAGE_DIR="$1"
            ;;
        --pim-dir=*) PIM_PACKAGE_DIR="${1#*=}" ;;
        --no-manifest) update_manifest=0 ;;
        -h|--help) usage; exit 0 ;;
        *) die "모르는 인자: $1 (--help 참고)" ;;
    esac
    shift
done

[ -f "$ARTIFACT" ] || die "빌드 산출물이 없다: $ARTIFACT — 먼저 $BUILD_HINT"
[ -d "$PIM_PACKAGE_DIR" ] || die "pim-package 트리가 없다: $PIM_PACKAGE_DIR"
PIM_PACKAGE_DIR="$(cd "$PIM_PACKAGE_DIR" && pwd)"

dest="$PIM_PACKAGE_DIR/$DEST_REL"
dest_dir="$(dirname "$dest")"
[ -d "$dest_dir" ] || die "배포 경로가 없다: $dest_dir — pim-package 트리가 맞는지 확인한다"

manifest="$PIM_PACKAGE_DIR/.github/binary-manifest.json"
verifier="$PIM_PACKAGE_DIR/tools/verify_binaries.py"
if [ "$update_manifest" -eq 1 ]; then
    [ -f "$manifest" ] || die "매니페스트가 없다: $manifest (건너뛰려면 --no-manifest)"
    [ -f "$verifier" ] || die "대조기가 없다: $verifier (건너뛰려면 --no-manifest)"
    command -v python3 >/dev/null 2>&1 || die "python3 가 없다 (건너뛰려면 --no-manifest)"
    python3 - "$manifest" "$DEST_REL" <<'PY' || die "매니페스트에 $DEST_REL 항목이 없다 — pim-package 쪽에서 먼저 등록한다 (복사만 하려면 --no-manifest)"
import json, sys
entries = json.load(open(sys.argv[1], encoding="utf-8")).get("binaries", [])
sys.exit(0 if any(e.get("path") == sys.argv[2] for e in entries) else 1)
PY
fi

# 내용이 그대로면 출처 커밋도 건드리지 않는다.
changed=1
if [ -f "$dest" ] && cmp -s "$ARTIFACT" "$dest"; then
    changed=0
fi

cp "$ARTIFACT" "$dest"
echo "복사: $ARTIFACT"
echo "  -> $dest"
[ "$changed" -eq 1 ] || echo "  (내용 동일 — 출처 커밋은 그대로 둔다)"

[ "$update_manifest" -eq 1 ] || exit 0

verify_args=(--update "$DEST_REL")
if [ "$changed" -eq 1 ]; then
    commit="$(git -C "$HERE" rev-parse --short=7 HEAD)"
    verify_args+=(--set-commit "$commit")
    dirty="$(git -C "$HERE" status --porcelain)"
    if [ -n "$dirty" ]; then
        {
            echo "경고: 작업트리가 깨끗하지 않다. 기록할 커밋은 $commit 인데"
            echo "      아래 변경은 그 커밋에 들어 있지 않다:"
            while IFS= read -r line; do echo "        $line"; done <<<"$dirty"
        } >&2
    fi
fi

echo
python3 "$verifier" "${verify_args[@]}"
