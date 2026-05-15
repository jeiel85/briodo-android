/**
 * Pro monetization is paused. This component is kept as a harmless fallback
 * for older call sites, but the active app no longer renders it.
 */
export function SubscriptionModal({
  isOpen,
  onClose,
  t = (key) => key,
}) {
  if (!isOpen) return null

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="subscription-modal" onClick={(e) => e.stopPropagation()}>
        <div style={{ padding: '24px', textAlign: 'center' }}>
          <h2 style={{ marginBottom: '8px' }}>{t('proPausedTitle') || 'Pro 준비 중'}</h2>
          <p style={{ color: 'var(--color-on-surface-variant)', lineHeight: 1.5 }}>
            {t('proPausedMessage') || 'BrioDo Pro는 더 나은 기능을 갖춘 뒤 다시 제공할 예정입니다.'}
          </p>
          <button className="smart-save-btn" style={{ marginTop: '18px' }} onClick={onClose}>
            {t('confirm') || '확인'}
          </button>
        </div>
      </div>
    </div>
  )
}

export default SubscriptionModal
