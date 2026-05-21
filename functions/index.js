const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

// AI 기능 비활성화 (v1.1.17) — Gemini API 호출 차단.
// 클라이언트가 신규 빌드면 진입점이 모두 숨겨져 있어 호출되지 않지만,
// 구버전 사용자가 남아있을 수 있어 서버 측에서도 단락한다.
const AI_DISABLED = new HttpsError(
  "failed-precondition",
  "AI features are temporarily disabled."
);

exports.getAiUsageStatus = onCall(
  {
    region: "asia-northeast3",
    cors: true,
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    throw AI_DISABLED;
  }
);

exports.generateGeminiContent = onCall(
  {
    region: "asia-northeast3",
    cors: true,
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    throw AI_DISABLED;
  }
);
