#!/usr/bin/env bash
# 챕터별 원격 반영 자동화 스크립트
# 사용법: bash scripts/save-chapter.sh "커밋 메시지"
# 예:    bash scripts/save-chapter.sh "5강: CRUD 기초 실습 완료"
set -e

MSG="${1:-"chore: 학습 진행 저장"}"

cd "$(dirname "$0")/.."

git add -A
if git diff --cached --quiet; then
  echo "변경사항이 없습니다. 커밋을 건너뜁니다."
  exit 0
fi

git commit -m "$MSG"
git push origin main
echo "✅ 원격(main)에 반영 완료: $MSG"
