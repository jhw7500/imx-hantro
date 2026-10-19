# imx-hantro — i.MX8MP Hantro VPU 커널 드라이버 외부 모듈

linux-imx `drivers/mxc/hantro*` 커널 드라이버를 고쳐서, 보드 커널 이미지를 바꾸지 않고
배포하기 위한 저장소다. 원본을 그대로 가져온 커밋에서 시작하고, 모든 변경은 그 뒤의 커밋으로만 남긴다.

NXP 의 사용자 공간 패키지 `imx-vpu-hantro` 와는 다르다. 사용자 공간 VPU 라이브러리
(`libfslvpuwrap`, `libgstvpu`)는 [imx-vpu](https://github.com/jhw7500/imx-vpu) 에 있다.

## 구성

| 경로 | 내용 |
|---|---|
| `vc8000e/` | VC8000E 인코더 드라이버(`hx280enc_vc8000e`). 원본 출처는 `vc8000e/UPSTREAM.md` |
| `make-for-imx8` | Yocto SDK 환경을 올리고 외부 모듈을 빌드한다(max9296 의 같은 이름 스크립트와 같은 방식) |
| `update_bin.sh` | `.ko` 를 `../pim-package-jhw/dist/pim/opt/pim/driver/` 로 복사하고 바이너리 매니페스트를 갱신한다 |

## 원본 대비 변경

`git log --oneline 37ed64d..` 로 본다. 37ed64d 는 원본을 그대로 가져온 커밋이다.

| 커밋 | 내용 |
|---|---|
| `f5fc149` | 플랫폼 드라이버 이름을 `mxc_hantro_vc8000e_ext` 로 바꿨다. 내장 드라이버와 함께 등록돼야 하기 때문이다 |
| `9af5230` | 코어 예약 소유를 스레드 id 가 아니라 열린 파일로 대조한다. 원본에서는 SIGKILL 뒤 예약이 영구히 남아 모든 인코딩이 멈췄다([pim-package-jhw#191](https://github.com/jhw7500/pim-package-jhw/issues/191)) |
| `6b26f73` | 인코딩 완료 대기가 timeout 되면 세마포어를 푼다. upstream `LF-7711-7`(`9b03ccbcb27e`)을 그대로 가져왔다. 원본에서는 인터럽트를 한 번 놓치면 다음 인코딩 시작이 무기한 기다렸다([#1](https://github.com/jhw7500/imx-hantro/issues/1)) |

## 빌드와 배포

```bash
cp .env.example .env    # SDK·커널 트리 경로를 채운다
./make-for-imx8         # vc8000e/hantro_vc8000e_ext.ko
./update_bin.sh         # pim-package 로 복사 + 매니페스트 갱신
```

| 변수 | 무엇인가 |
|---|---|
| `SDK_LOC`, `SDK_NAME` | Yocto SDK 위치와 타깃(`environment-setup-${SDK_NAME}`) |
| `KERNEL_SRC` | 보드 커널과 같은 kernel.release 로 빌드된 커널 소스 트리 |
| `KBUILD_OUTPUT` | 소스와 빌드가 나뉜 트리의 빌드 디렉터리(`.config` 가 있는 쪽) |
| `PIM_PACKAGE_DIR` | pim-package 저장소 위치(비우면 `../pim-package-jhw`) |

환경변수가 `.env` 보다 우선한다. 모듈은 kernel.release 에 묶인다(vermagic·modversions).
커널 이미지가 바뀌면 그 커널 트리로 다시 빌드한다.

`update_bin.sh` 는 매니페스트에 이미 등록된 경로만 갱신한다. 처음 들일 때는 pim-package 쪽에서
항목을 먼저 만든다. 항목이 없으면 복사하기 전에 멈춘다(`--no-manifest` 는 복사만 한다).

## 보드에서 쓰는 방법

보드 커널은 이 드라이버를 내장(`CONFIG_MXC_HANTRO_VC8000E=y`)하고 있다. 그래서 `.ko` 를 넣기만 해서는
대체되지 않는다. 장치를 아무도 열지 않았을 때(gstApp 정지) 아래 순서로 장치를 옮겨 붙인다.
재부팅하면 내장 드라이버로 돌아간다.

```bash
insmod hantro_vc8000e_ext.ko
echo 38320000.vpu_vc8000e > /sys/bus/platform/drivers/mxc_hantro_vc8000e/unbind
echo mxc_hantro_vc8000e_ext > /sys/bus/platform/devices/38320000.vpu_vc8000e/driver_override
echo 38320000.vpu_vc8000e > /sys/bus/platform/drivers/mxc_hantro_vc8000e_ext/bind
```

- 장치를 연 프로세스가 있을 때는 unbind 하지 않는다. 드라이버 cleanup 이, 열린 fd 의 `private_data` 가
  가리키는 메모리를 해제하기 때문이다.
- `/dev/mxc_hantro_vc8000e` 는 같은 major·권한으로 다시 생기므로 사용자 공간은 바꿀 것이 없다.
- 내장으로 되돌릴 때는 unbind 하고, `driver_override` 를 비운 뒤 `mxc_hantro_vc8000e` 에 bind 한다.
- 부팅 때 자동으로 전환하는 일은 pim-package 가 맡는다([pim-package-jhw#194](https://github.com/jhw7500/pim-package-jhw/issues/194)).

## 라이선스

원본 머리말 그대로 GNU GPL v2 이상이다(`COPYRIGHT(C) 2014 VERISILICON`).
