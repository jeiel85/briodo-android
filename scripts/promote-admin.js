/* eslint-env node */

/**
 * BrioDo Admin Promotion Script
 * 
 * 특정 사용자의 UID에 관리자 권한(Custom Claims)을 부여합니다.
 * 실행 전 'firebase-admin' 설치가 필요할 수 있습니다: npm install firebase-admin
 */

import admin from 'firebase-admin';
import { readFileSync } from 'fs';

// 1. 서비스 계정 키 파일 경로 (Firebase 설정 -> 서비스 계정 -> 새 비공개 키 생성에서 다운로드)
const serviceAccountPath = './serviceAccountKey.json'; 

try {
  const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });

  const promoteAdmin = async (uid) => {
    try {
      await admin.auth().setCustomUserClaims(uid, { admin: true });
      console.log(`Successfully promoted user ${uid} to admin.`);
      
      // 확인을 위해 토큰 결과 출력
      const user = await admin.auth().getUser(uid);
      console.log('Current Custom Claims:', user.customClaims);
      
      process.exit(0);
    } catch (error) {
      console.error('Error promoting user:', error);
      process.exit(1);
    }
  };

  // 실행 시 인자로 UID를 전달하세요: node scripts/promote-admin.js <USER_UID>
  const targetUid = process.argv[2];

  if (!targetUid) {
    console.error('Please provide a User UID: node scripts/promote-admin.js <UID>');
    process.exit(1);
  }

  promoteAdmin(targetUid);

} catch (e) {
  console.error('Failed to load service account or initialize admin SDK. Make sure serviceAccountKey.json exists in the root.');
  console.log('Error:', e.message);
  process.exit(1);
}
