import { useState } from 'react'
import { PRO_PLANS } from '../hooks/useSubscription'

/**
 * Pro 구독 업그레이드 모달
 */
export function SubscriptionModal({ 
  isOpen, 
  onClose, 
  onSubscribe, 
  t = (key) => key,
}) {
  const [selectedPlan, setSelectedPlan] = useState('YEARLY')
  const [isProcessing, setIsProcessing] = useState(false)
  
  if (!isOpen) return null

  const plans = [
    { 
      key: 'MONTHLY', 
      ...PRO_PLANS.MONTHLY,
      label: t('monthlyPlan') || '월간',
      description: t('monthlyDesc') || '매월 자동 결제',
    },
    { 
      key: 'YEARLY', 
      ...PRO_PLANS.YEARLY,
      label: t('yearlyPlan') || '연간',
      description: t('yearlyDesc') || '32% 할인',
      badge: t('bestValue') || 'BEST',
    },
    { 
      key: 'FAMILY', 
      ...PRO_PLANS.FAMILY,
      label: t('familyPlan') || '패밀리',
      description: t('familyDesc') || '최대 6인',
    },
  ]

  const features = [
    { icon: '✨', key: 'unlimited_ai', label: t('featureUnlimitedAi') || '무제한 AI 사용' },
    { icon: '🎨', key: 'custom_themes', label: t('featureCustomThemes') || '커스텀 테마' },
    { icon: '🚫', key: 'no_ads', label: t('featureNoAds') || '광고 제거' },
    { icon: '📊', key: 'advanced_stats', label: t('featureAdvancedStats') || '고급 통계' },
    { icon: '⚡', key: 'priority_sync', label: t('featurePrioritySync') || '우선 동기화' },
  ]

  const handleSubscribe = async () => {
    if (isProcessing) return
    
    setIsProcessing(true)
    try {
      await onSubscribe(selectedPlan.toLowerCase())
      onClose()
    } catch (error) {
      console.error('Subscription error:', error)
    } finally {
      setIsProcessing(false)
    }
  }

  const formatPrice = (price) => {
    return new Intl.NumberFormat('ko-KR', {
      style: 'currency',
      currency: 'KRW',
      maximumFractionDigits: 0,
    }).format(price)
  }

  return (
    <div 
      className="modal-overlay"
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.6)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1000,
        padding: '20px',
      }}
      onClick={onClose}
    >
      <div 
        className="subscription-modal"
        style={{
          backgroundColor: 'var(--color-surface)',
          borderRadius: 'var(--radius-xl)',
          maxWidth: '420px',
          width: '100%',
          maxHeight: '90vh',
          overflow: 'auto',
          animation: 'slideUp 0.3s ease',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* 헤더 */}
        <div style={{
          padding: '24px 24px 16px',
          textAlign: 'center',
          borderBottom: '1px solid var(--color-outline-variant)',
        }}>
          <div style={{
            width: '56px',
            height: '56px',
            borderRadius: '50%',
            background: 'linear-gradient(135deg, var(--color-primary) 0%, var(--color-tertiary) 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 16px',
            fontSize: '28px',
          }}>
            ⚡
          </div>
          <h2 style={{
            fontSize: '24px',
            fontWeight: 700,
            color: 'var(--color-on-surface)',
            marginBottom: '8px',
          }}>
            {t('upgradeToPro') || 'Pro로 업그레이드'}
          </h2>
          <p style={{
            fontSize: '14px',
            color: 'var(--color-on-surface-variant)',
          }}>
            {t('proDescription') || 'BrioDo의 모든 기능을 무제한으로 사용하세요'}
          </p>
        </div>

        {/* 기능 목록 */}
        <div style={{ padding: '20px 24px' }}>
          <div style={{
            display: 'grid',
            gap: '12px',
            marginBottom: '24px',
          }}>
            {features.map((feature) => (
              <div 
                key={feature.key}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  fontSize: '14px',
                  color: 'var(--color-on-surface)',
                }}
              >
                <span style={{ fontSize: '18px' }}>{feature.icon}</span>
                <span>{feature.label}</span>
                <span style={{
                  marginLeft: 'auto',
                  color: 'var(--color-primary)',
                  fontSize: '16px',
                }}>✓</span>
              </div>
            ))}
          </div>

          {/* 플랜 선택 */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {plans.map((plan) => (
              <button
                key={plan.key}
                onClick={() => setSelectedPlan(plan.key)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  padding: '16px',
                  borderRadius: 'var(--radius-lg)',
                  border: `2px solid ${selectedPlan === plan.key ? 'var(--color-primary)' : 'var(--color-outline-variant)'}`,
                  backgroundColor: selectedPlan === plan.key ? 'var(--color-primary-container)' : 'var(--color-surface-container)',
                  cursor: 'pointer',
                  transition: 'all 0.2s ease',
                  textAlign: 'left',
                }}
              >
                <div style={{
                  width: '20px',
                  height: '20px',
                  borderRadius: '50%',
                  border: `2px solid ${selectedPlan === plan.key ? 'var(--color-primary)' : 'var(--color-outline)'}`,
                  marginRight: '12px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}>
                  {selectedPlan === plan.key && (
                    <div style={{
                      width: '10px',
                      height: '10px',
                      borderRadius: '50%',
                      backgroundColor: 'var(--color-primary)',
                    }} />
                  )}
                </div>
                
                <div style={{ flex: 1 }}>
                  <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '8px',
                    marginBottom: '2px',
                  }}>
                    <span style={{
                      fontWeight: 600,
                      fontSize: '15px',
                      color: 'var(--color-on-surface)',
                    }}>
                      {plan.label}
                    </span>
                    {plan.badge && (
                      <span style={{
                        backgroundColor: 'var(--color-primary)',
                        color: 'white',
                        fontSize: '10px',
                        fontWeight: 700,
                        padding: '2px 6px',
                        borderRadius: '4px',
                      }}>
                        {plan.badge}
                      </span>
                    )}
                  </div>
                  <span style={{
                    fontSize: '12px',
                    color: 'var(--color-on-surface-variant)',
                  }}>
                    {plan.description}
                  </span>
                </div>
                
                <div style={{ textAlign: 'right' }}>
                  <div style={{
                    fontWeight: 700,
                    fontSize: '16px',
                    color: 'var(--color-on-surface)',
                  }}>
                    {formatPrice(plan.price)}
                  </div>
                  <div style={{
                    fontSize: '11px',
                    color: 'var(--color-on-surface-variant)',
                  }}>
                    /{plan.period === 'month' ? t('month') || '월' : t('year') || '년'}
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* 버튼 영역 */}
        <div style={{
          padding: '16px 24px 24px',
          borderTop: '1px solid var(--color-outline-variant)',
        }}>
          <button
            onClick={handleSubscribe}
            disabled={isProcessing}
            style={{
              width: '100%',
              padding: '16px',
              borderRadius: 'var(--radius-lg)',
              border: 'none',
              background: 'linear-gradient(135deg, var(--color-primary) 0%, var(--color-tertiary) 100%)',
              color: 'white',
              fontSize: '16px',
              fontWeight: 700,
              cursor: isProcessing ? 'not-allowed' : 'pointer',
              opacity: isProcessing ? 0.7 : 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
            }}
          >
            {isProcessing ? (
              <>
                <span style={{
                  width: '16px',
                  height: '16px',
                  border: '2px solid white',
                  borderTopColor: 'transparent',
                  borderRadius: '50%',
                  animation: 'spin 1s linear infinite',
                }} />
                {t('processing') || '처리 중...'}
              </>
            ) : (
              <>
                <span>⚡</span>
                {t('subscribeNow') || '지금 구독하기'}
              </>
            )}
          </button>
          
          <button
            onClick={onClose}
            style={{
              width: '100%',
              padding: '12px',
              marginTop: '8px',
              border: 'none',
              background: 'transparent',
              color: 'var(--color-on-surface-variant)',
              fontSize: '14px',
              cursor: 'pointer',
            }}
          >
            {t('maybeLater') || '나중에 하기'}
          </button>
          
          <p style={{
            textAlign: 'center',
            fontSize: '11px',
            color: 'var(--color-on-surface-variant)',
            marginTop: '12px',
          }}>
            {t('subscriptionNote') || '언제든지 취소 가능합니다. 구독은 자동 갱신됩니다.'}
          </p>
        </div>
      </div>
    </div>
  )
}

export default SubscriptionModal
