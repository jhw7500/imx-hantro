# vc8000e 원본 출처

이 디렉터리의 `hx280enc_vc8000e.c`·`hx280enc.h` 는 NXP linux-imx 커널 트리의
`drivers/mxc/hantro_vc8000e/` 를 **그대로** 복사한 것으로 시작한다(이 저장소 첫 커밋).
그 뒤의 변경은 모두 이 저장소의 커밋으로만 들어간다 — 원본과의 차이는 `git log -p vc8000e/` 로 본다.

## 가져온 트리 (2026-10-17)

| 항목 | 값 |
|---|---|
| 트리 | Yocto devtool 작업 공간 `workspace/sources/linux-imx` (브랜치 `lf-5.10.y`, 원격 `https://source.codeaurora.org/external/imx/linux-imx.git`) |
| 그 트리 HEAD | `e002bd363671fb43269987a4b08ca2ecb082ebaa` (2026-08-13) |
| 이 디렉터리를 마지막으로 바꾼 커밋 | `eefe8b054e8c` (2020-12-14, `LF-1762-5 mxc: vpu: replace '---help---' in Kconfig files with 'help'`) |
| 빌드 출력의 kernel.release | `5.10.35-lts-5.10.y+g2fce14defc04` — 현장 보드(.4·.6) `uname -r` 와 같다 |
| 커널 설정 | `CONFIG_MXC_HANTRO_VC8000E=y` (커널 내장) |

## 원본 파일 SHA-256

| 파일 | SHA-256 |
|---|---|
| `hx280enc_vc8000e.c` | `f0e5123da0151c8baeba86e4700b181f9d4523b41969cb64c9ba0c05c4a1b8bd` |
| `hx280enc.h` | `1c9d204c69e20b04113b3494420c4d660f91636797e3aa37b4f9a2e14d89af43` |

다른 Yocto 트리(`kernel-source`, kernel.release `+g9e6a96304d4c`)의 같은 두 파일도 SHA-256 이 같다.

## 라이선스

원본 머리말 그대로 GNU GPL v2 이상(`COPYRIGHT(C) 2014 VERISILICON`)이다. 이 저장소의 변경도 같은 조건을 따른다.
