# 图标资源说明

由于HarmonyOS项目需要实际的图片资源文件，请在以下目录添加对应的图标文件：

## 资源目录
`entry/src/main/resources/base/media/`

## 必需的图标列表

### 导航栏图标（建议尺寸：48x48px，SVG格式）
1. **ic_home.svg** - 首页图标（未选中）
2. **ic_home_active.svg** - 首页图标（选中状态）
3. **ic_discover.svg** - 发现图标（未选中）
4. **ic_discover_active.svg** - 发现图标（选中状态）
5. **ic_publish.svg** - 发布图标
6. **ic_message.svg** - 消息图标（未选中）
7. **ic_message_active.svg** - 消息图标（选中状态）
8. **ic_profile.svg** - 我的图标（未选中）
9. **ic_profile_active.svg** - 我的图标（选中状态）

### 功能图标（建议尺寸：24x24px）
10. **ic_search.svg** - 搜索
11. **ic_refresh.svg** - 刷新
12. **ic_like.svg** - 点赞（未选中）
13. **ic_like_active.svg** - 点赞（选中）
14. **ic_comment.svg** - 评论
15. **ic_share.svg** - 分享
16. **ic_collect.svg** - 收藏（未选中）
17. **ic_collect_active.svg** - 收藏（选中）
18. **ic_verified.svg** - 认证标识
19. **ic_play.svg** - 播放按钮（建议64x64px）

### 发现页图标
20. **ic_hot.svg** - 热搜
21. **ic_trend_up.svg** - 上升趋势
22. **ic_trend_down.svg** - 下降趋势
23. **ic_topic.svg** - 专题
24. **ic_recommend.svg** - 推荐

### 发布页图标
25. **ic_delete.svg** - 删除
26. **ic_add_image.svg** - 添加图片
27. **ic_close.svg** - 关闭
28. **ic_arrow_right.svg** - 右箭头
29. **ic_source.svg** - 来源
30. **ic_permission.svg** - 权限

### 消息页图标
31. **ic_system.svg** - 系统消息
32. **ic_private.svg** - 私信
33. **ic_empty_message.svg** - 空消息（建议120x120px）

### 个人中心图标
34. **ic_my_publish.svg** - 我的发布
35. **ic_my_collect.svg** - 我的收藏
36. **ic_history.svg** - 历史
37. **ic_feedback.svg** - 反馈
38. **ic_setting.svg** - 设置
39. **ic_about.svg** - 关于
40. **ic_male.svg** - 男性图标
41. **ic_female.svg** - 女性图标
42. **ic_edit.svg** - 编辑
43. **ic_not_login.svg** - 未登录（建议120x120px）

### 详情页图标
44. **ic_back.svg** - 返回
45. **ic_more.svg** - 更多
46. **ic_copy.svg** - 复制
47. **ic_report.svg** - 举报
48. **ic_font.svg** - 字体
49. **ic_night_mode.svg** - 夜间模式
50. **ic_empty_comment.svg** - 空评论（建议80x80px）

### 登录页图标
51. **app_logo.svg** - 应用Logo（建议80x80px）
52. **ic_wechat.svg** - 微信登录（建议48x48px）
53. **ic_qq.svg** - QQ登录（建议48x48px）
54. **ic_weibo.svg** - 微博登录（建议48x48px）

### 默认图片
55. **default_avatar.png** - 默认头像（建议200x200px）
56. **default_cover.png** - 默认封面（建议400x300px）
57. **news_cover1.png** - 新闻封面1
58. **news_cover2.png** - 新闻封面2
59. **news_cover3.png** - 新闻封面3

### 专题封面
60. **topic_tech.png** - 科技专题封面
61. **topic_finance.png** - 财经专题封面
62. **topic_sports.png** - 体育专题封面
63. **topic_entertainment.png** - 娱乐专题封面

## 图标设计建议

### 格式
- **图标**：SVG格式（矢量图，任意缩放不失真）
- **图片**：PNG或JPG格式

### 尺寸
- **导航栏图标**：48x48px
- **功能图标**：24x24px
- **头像**：200x200px
- **封面图**：400x300px或更大

### 颜色
- **未选中状态**：灰色 (#666666)
- **选中状态**：蓝色 (#1677FF)
- **强调色**：红色 (#FF4444)

### 设计风格
- 简洁、现代、扁平化
- 线条粗细一致
- 圆角统一

## 快速获取图标

推荐从以下网站下载图标：
1. [阿里巴巴矢量图标库](https://www.iconfont.cn/)
2. [Flaticon](https://www.flaticon.com/)
3. [IconFont](https://icomoon.io/)

## 临时解决方案

如果暂时没有图标资源，可以：
1. 使用纯色圆形占位
2. 使用文字代替图标
3. 注释掉图标相关代码

---

**注意**：缺少图标资源会导致编译错误，请务必添加所有必需的图标文件！
