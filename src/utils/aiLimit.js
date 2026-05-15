export function isAiQuotaError(error) {
  return error?.code === 'functions/resource-exhausted'
}

export function getAiQuotaMessage(lang, context = 'general') {
  if (context === 'smart') {
    if (lang === 'ja') return 'タスクは保存しました。AI整理は本日の利用枠に達したため、明日また利用できます。'
    if (lang === 'zh') return '已保存任务。AI整理今天的使用额度已用完，明天可再次使用。'
    if (lang === 'en') return 'Task saved. AI cleanup has reached today\'s limit and will be available again tomorrow.'
    return '할 일은 저장했어요. AI 정리는 오늘 사용량에 도달해서 내일 다시 사용할 수 있어요.'
  }

  if (lang === 'ja') return '本日のAI利用枠に達しました。明日また試してください。'
  if (lang === 'zh') return '今天的AI使用额度已用完，请明天再试。'
  if (lang === 'en') return 'AI has reached today\'s limit. Please try again tomorrow.'
  return '오늘의 AI 사용량에 도달했어요. 내일 다시 시도해 주세요.'
}
