/* ============================================================
   情侣 100 天纪念日许愿星 · 配置文件
   所有可维护项集中在这里，改完保存 → 刷新页面即生效
   ============================================================ */
window.WISH_STAR_CONFIG = {
  /* 星星总数（网格 10 x 10 = 100） */
  TOTAL: 100,

  /* 点亮一颗星后的冷却时长（秒）。测试期 300 = 5 分钟
     常见取值：300 = 5 分钟 | 1800 = 30 分钟 | 3600 = 1 小时 | 86400 = 1 天 */
  COOLDOWN_SECONDS: 300,

  /* 冷却期间是否锁定其余未点亮的星星（置灰、不可点） */
  LOCK_OTHERS_DURING_CD: true,

  /* 预留：按天解锁模式开关（true 时每天最多点亮 DAILY_UNLOCK_COUNT 颗） */
  DAILY_UNLOCK_MODE: false,

  /* 按天解锁模式下，每天可点亮的数量上限 */
  DAILY_UNLOCK_COUNT: 5,

  /* 大模型情话（OpenAI 兼容协议） */
  AI: {
    ENABLED: true,
    BASE_URL: 'https://api.deepseek.com/v1', // OpenAI 兼容地址（末尾不要带 /）
    MODEL: 'deepseek-chat',
    API_KEY: '',                             // 由用户填入；为空则自动走本地兜底文案
    TIMEOUT_MS: 3000                         // 超时（毫秒），超时即回退兜底
  }
};