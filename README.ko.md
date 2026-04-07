[English](README.md)

# SF Server

용접 자동 검사 및 분류 시스템을 위한 스마트 팩토리 모노레포입니다.  
공장 PC에서 함께 실행되는 두 개의 서버로 구성됩니다.

---

## 저장소 구조

```
sf_server/
├── install.bat       # 두 서버 통합 최초 설치 스크립트
├── start.bat         # 전체 서비스 실행 스크립트
├── db_server/        # 데이터베이스 미들웨어, API, React 대시보드
└── cam_server/       # 카메라 서버 및 TFLite 용접 분류기
```

---

## 사전 요구사항

| 의존성 | 비고 |
|---|---|
| Python 3.x | `db_server` 용 (최신 버전 권장) |
| Python 3.10 | `cam_server` 용 (TFLite 호환성) |
| Node.js | `sf-dashboard` 용 |
| MySQL 8.1 | 서비스명이 반드시 `MySQL81`이어야 함 |

---

## 최초 설치

> 새 PC에서 한 번만 실행합니다. Python과 Node.js가 PATH에 등록되어 있어야 합니다.

`install.bat` 우클릭 → **관리자 권한으로 실행**

실행 순서:
1. `db_server/dbvenv` 재생성 및 Python 패키지 설치
2. MySQL81 시작 후 `db_setup.py` 실행하여 데이터베이스 및 테이블 생성
3. `sf-dashboard` Node 패키지 설치
4. `cam_server/venv` (Python 3.10) 생성 및 패키지 설치

> **주의:** `db_server`가 이전에 다른 경로에 설치된 경우, 실행 전 `db_server/dbvenv`를 수동으로 삭제하세요. 가상환경은 설치 경로를 내부에 하드코딩합니다.

---

## 실행

`start.bat` 우클릭 → **관리자 권한으로 실행**

별도의 터미널 창에서 네 개의 서비스가 실행됩니다:

| 창 이름 | 서비스 | 주소 |
|---|---|---|
| SF API | FastAPI 미들웨어 | http://localhost:8000 |
| SF Dashboard | React/Vite 대시보드 | http://localhost:5173 |
| SF PLC Controller | PLC 주문 동기화 | — |
| SF CAM | 카메라 + 분류기 | http://localhost:5000 |

5초 후 브라우저에서 대시보드가 자동으로 열립니다.

---

## 서버 구성

### db_server
MySQL과 대시보드/PLC 사이의 FastAPI 미들웨어입니다. 주문, 부품, 선박, 고객, 분류 결과, 검사 스냅샷을 관리합니다.  
API 레퍼런스 및 스키마 상세 내용은 [db_server/README.md](db_server/README.md)를 참조하세요.

### cam_server
검사 카메라 스트리밍과 TFLite 용접 분류 모델을 실행하는 Flask 서버입니다. HTTP 요청으로 런타임 중 모델 전환이 가능합니다.  
주요 의존성: OpenCV, TFLite (`ai_edge_litert`), pymcprotocol, mysql-connector.
