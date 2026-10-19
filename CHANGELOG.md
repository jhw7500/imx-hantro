# Changelog

## [Unreleased]

### Fixed
- vc8000e: 코어 예약 소유를 스레드 id 대신 열린 파일로 대조한다. 예약하지 않은 스레드가 마지막 close 를 하면
  예약이 영구히 남던 문제를 고친다(pim-package-jhw#191).
- vc8000e: 인코딩 완료 대기가 timeout 되면 세마포어를 푼다. 인터럽트를 한 번 놓치면 다음 인코딩 시작이
  무기한 기다리던 문제를 고친다. upstream LF-7711-7 을 그대로 가져왔다(imx-hantro#1).

### Added
- linux-imx `drivers/mxc/hantro_vc8000e` 원본 가져오기(`vc8000e/UPSTREAM.md`).
- Yocto SDK 외부 모듈 빌드(`make-for-imx8`)와 pim-package 배포(`update_bin.sh`).
- 내장 드라이버와 함께 등록되도록 플랫폼 드라이버 이름 `mxc_hantro_vc8000e_ext`.
