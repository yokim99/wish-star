# 我们的 100 颗许愿星

给男朋友的 100 天纪念日礼物网站。纯前端、零后端，双击即可运行，所有内容都可以在本机自己维护。

## 文件说明

| 文件 | 作用 |
| --- | --- |
| `index.html` | 主应用：星空场景、点亮交互、记录卡片、冷却倒计时、AI 情话、100 颗彩蛋 |
| `config.js` | 配置文件：星星总数、冷却时长、按天解锁、大模型 API 等，**改这里最多** |
| `records.json` | 素材数据：编号 → 记录正文，编号是 key，缺号会自动渲染成"待补充空位" |
| `README.md` | 本说明文档 |
| `wish-star-prototype.html` | 早期交互原型，仅供对照，可保留可删除 |

---

## 一、如何替换 / 新增 / 删除素材

编辑 `records.json` 即可。它是一个"稀疏 Map"，key 是两位数字编号（字符串），value 是记录正文。

```json
{
  "01": "第一条回忆……",
  "08": "第八条回忆……",
  "100": "第 100 天……"
}
```

规则：

- **新增**：在 JSON 里加一行 `"编号": "内容"`。
- **修改**：直接改对应编号后面的文字。
- **删除**：删掉整行。删掉后该位置会自动变成**灰色空位**，不可点击。
- **跳号 / 缺号**：完全没问题，比如你只写了 `01`、`07`、`100`，中间的空号会自动渲染为"待补充空位"，不影响其它星星点亮。

注意事项：

1. 编号必须是**两位数字的字符串**（写成 `"01"` 而不是 `1`，否则会匹配不到）。
2. 每行末尾的逗号：**最后一行不要加逗号**，否则 JSON 会报错。
3. 改完后校验一下格式是否合法：

```bash
python3 -m json.tool records.json
```

  没有报错、正常打印出内容，就说明格式正确。

> `index.html` 里内置了一份和 `records.json` 相同的兜底数据，是为了让"双击打开（file://）"时也能正常显示。如果你直接双击运行，请记得**同时更新 `index.html` 中 `FALLBACK_RECORDS` 的内容**，两边保持一致；如果通过本地服务器或线上访问，则只改 `records.json` 就够了。

---

## 二、如何调整冷却时间

编辑 `config.js` 里的 `COOLDOWN_SECONDS`，单位是**秒**：

```js
COOLDOWN_SECONDS: 300,
```

常见取值：

| 你想要的节奏 | 填写值 |
| --- | --- |
| 5 分钟（测试期，默认） | `300` |
| 30 分钟 | `1800` |
| 1 小时 | `3600` |
| 1 天（一天点亮一颗） | `86400` |

同一行附近还有两个开关：

- `LOCK_OTHERS_DURING_CD`：`true` 表示冷却期间其余星星置灰锁定；改成 `false` 则冷却期间仍可点其它星（只提示冷却）。
- `DAILY_UNLOCK_MODE` / `DAILY_UNLOCK_COUNT`：预留的"按天解锁"模式。把 `DAILY_UNLOCK_MODE` 改成 `true`，每天最多点亮 `DAILY_UNLOCK_COUNT` 颗。

---

## 三、如何配置大模型 API Key

编辑 `config.js` 的 `AI` 部分：

```js
AI: {
  ENABLED: true,
  BASE_URL: 'https://api.deepseek.com/v1', // OpenAI 兼容地址（末尾不要带 /）
  MODEL: 'deepseek-chat',
  API_KEY: '',                             // 把你的 key 填在这里
  TIMEOUT_MS: 3000
}
```

- 把 `API_KEY` 填成你自己的 key，`BASE_URL` 和 `MODEL` 换成对应服务商的即可（任何 OpenAI 兼容接口都行）。
- **没填 key、请求失败、或超过 `TIMEOUT_MS`（默认 3000 毫秒）** 时，会自动回退到本地兜底情话，**绝不会报错、不会白屏**。
- 安全提示：这是纯前端项目，key 会被写死在网页里，**仅供个人自用，请不要把带 key 的版本公开发布或提交到公开仓库**。更稳妥的做法是留空 key，只使用本地兜底文案。

---

## 四、如何本地预览

两种方式，任选其一：

1. **最简单：直接双击 `index.html`**。
   会自动使用内置兜底数据，100 颗星正常显示、点亮和冷却都能用。
   （file:// 协议下浏览器不允许读取 `records.json`，所以走内联数据；这是正常的。）

2. **推荐：起一个本地服务器**（数据从 `records.json` 读取，方便改素材）：

```bash
cd wish-star
python3 -m http.server 8000
```

   然后浏览器打开 <http://localhost:8000/>

想测试隐藏管理入口（重置进度）：打开 <http://localhost:8000/?admin=1>，右上角会出现"重置进度"按钮。

---

## 五、如何重新部署

仓库：`github.com/yokim99/wish-star`（GitHub Pages）。链接固定不变，改完文件推上去即可。

### 方式一（推荐）：一键部署脚本

本机网络对 `github.com` 域名受限，且 macOS 自带 git 使用 LibreSSL，直接 `git push` 可能会失败（报 `tlsv1 alert protocol version`）。因此**推荐直接运行仓库内的 `deploy.sh` 脚本**，它走 GitHub REST API（`api.github.com` 可正常访问）上传文件，绕开上述限制。

```bash
cd wish-star
bash deploy.sh
```

脚本会自动：

1. 读取 `gh` 的登录 token；
2. 依次上传 `index.html`、`config.js`、`records.json`、`README.md` 四个文件（先查已有文件 sha，再 PUT 更新/新建）；
3. 每个文件带 3 次重试，任一文件失败会打印错误并退出。

全部成功后，约 30 秒公网生效，访问：

<https://raw.githack.com/yokim99/wish-star/main/index.html>

> 若首次运行提示权限不足或 `gh` 未登录，先执行 `gh auth login` 完成登录。

### 方式二：git push（网络正常时可用）

```bash
cd wish-star
git add .
git commit -m "更新素材/配置"
git push
```

推送后稍等一两分钟，刷新线上链接就能看到最新内容。

---

## 常见问题

- **页面一片空白？** 检查 `records.json` 是否是合法 JSON（用上面的 `python3 -m json.tool` 命令校验），以及 `index.html` 是否与 `config.js` 在同一目录。
- **某颗星点不了？** 说明那个编号在 `records.json` 里没有内容，它被渲染成了"待补充空位"，补上内容即可点亮。
- **点亮后想再改记录？** 已点亮的星星可以重复点击查看；修改记录直接改 `records.json` 后刷新页面。
- **想重新体验一遍？** 打开 `?admin=1` 点"重置进度"，或清除浏览器该站点的本地存储。