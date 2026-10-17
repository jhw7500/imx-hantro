# 호스트별 경로는 저장소에 넣지 않는다. 저장소 루트의 `.env`(gitignore 대상)에서
# 읽는다 — `cp .env.example .env` 로 시작한다. `make KERNEL_SRC=...` 로 넘기면
# 명령줄이 이긴다. 보통은 make-for-imx8 로 부른다(SDK 환경을 먼저 올린다).
#   KERNEL_SRC    : 커널 소스 트리 (arch/<arch>/configs 가 있는 쪽)
#   KBUILD_OUTPUT : 소스와 빌드가 나뉜 트리의 빌드 디렉터리 (.config 가 있는 쪽)
-include .env

KBUILD_O := $(if $(strip $(KBUILD_OUTPUT)),O=$(strip $(KBUILD_OUTPUT)))

ifeq ($(strip $(KERNEL_SRC)),)
$(error KERNEL_SRC 가 비었다 — `cp .env.example .env` 로 채우거나 make KERNEL_SRC=... 로 넘긴다)
endif

all:
	$(MAKE) -C $(KERNEL_SRC) $(KBUILD_O) M=$(CURDIR)/vc8000e modules

clean:
	$(MAKE) -C $(KERNEL_SRC) $(KBUILD_O) M=$(CURDIR)/vc8000e clean

.PHONY: all clean
