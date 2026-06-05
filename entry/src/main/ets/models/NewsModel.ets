/**
 * 新闻数据模型
 */
export interface NewsItem {
  id: string;                    // 新闻ID
  title: string;                 // 新闻标题
  summary: string;               // 摘要
  content: string;               // 正文内容
  coverImages: string[];         // 封面图片数组（支持单图/三图）
  category: string;              // 新闻分类
  source: string;                // 新闻来源
  author: AuthorInfo;            // 作者信息
  publishTime: string;           // 发布时间
  readCount: number;             // 阅读数
  likeCount: number;             // 点赞数
  commentCount: number;          // 评论数
  shareCount: number;            // 分享数
  collectCount: number;          // 收藏数
  isLiked: boolean;              // 是否已点赞
  isCollected: boolean;          // 是否已收藏
  isRead: boolean;               // 是否已读
  type: NewsType;                // 新闻类型
  videoUrl?: string;             // 视频URL（如果是视频新闻）
}

/**
 * 作者信息
 */
export interface AuthorInfo {
  id: string;                    // 作者ID
  name: string;                  // 作者昵称
  avatar: string;                // 作者头像
  isVerified: boolean;           // 是否认证
  verifyType?: string;           // 认证类型
}

/**
 * 新闻类型
 */
export enum NewsType {
  TEXT = 'text',                 // 纯文字
  SINGLE_IMAGE = 'single',       // 单图
  MULTI_IMAGE = 'multi',         // 多图
  VIDEO = 'video',               // 视频
}

/**
 * 评论模型
 */
export interface Comment {
  id: string;                    // 评论ID
  newsId: string;                // 新闻ID
  author: AuthorInfo;            // 评论者信息
  content: string;               // 评论内容
  publishTime: string;           // 评论时间
  likeCount: number;             // 点赞数
  replyCount: number;            // 回复数
  isLiked: boolean;              // 是否已点赞
  replies?: Comment[];           // 回复列表
}

/**
 * 消息模型
 */
export interface Message {
  id: string;                    // 消息ID
  type: MessageType;             // 消息类型
  title: string;                 // 消息标题
  content: string;               // 消息内容
  sender?: AuthorInfo;           // 发送者信息
  targetId?: string;             // 关联ID（新闻ID/评论ID等）
  createTime: string;            // 创建时间
  isRead: boolean;               // 是否已读
}

/**
 * 消息类型
 */
export enum MessageType {
  COMMENT = 'comment',           // 评论我的
  LIKE = 'like',                 // 点赞我的
  COLLECT = 'collect',           // 收藏我的
  SYSTEM = 'system',             // 系统通知
  PRIVATE = 'private',           // 私信
  FOLLOW = 'follow'              // 关注我的
}

/**
 * 用户信息模型
 */
export interface UserInfo {
  id: string;                    // 用户ID
  name: string;                  // 昵称
  avatar: string;                // 头像
  signature: string;             // 个人签名
  gender: string;                // 性别
  birthday: string;              // 生日
  location: string;              // 地区
  publishCount: number;          // 发布数
  followCount: number;           // 关注数
  fansCount: number;             // 粉丝数
  likeCount: number;             // 获赞数
  collectCount: number;          // 收藏数
  isVerified: boolean;           // 是否认证
}

/**
 * 热搜模型
 */
export interface HotSearch {
  rank: number;                  // 排名
  keyword: string;               // 关键词
  heat: number;                  // 热度
  trend: 'up' | 'down' | 'new' | 'hot'; // 趋势
  label?: string;                // 标签（新/热/爆等）
}

/**
 * 专题模型
 */
export interface Topic {
  id: string;                    // 专题ID
  name: string;                  // 专题名称
  cover: string;                 // 封面图
  description: string;           // 描述
  followCount: number;           // 关注数
  newsCount: number;             // 新闻数
  isFollowed: boolean;           // 是否已关注
}

/**
 * 示例新闻数据
 */
export const SAMPLE_NEWS: NewsItem[] = [
  {
    id: 'sample_1',
    title: '华为发布新品手机',
    summary: '华为最新手机发布，搭载麒麟芯片',
    content: '华为近日发布了新款智能手机，搭载了最新的麒麟处理器，具备强大的性能和出色的摄影能力。该手机采用了全新的设计语言，支持5G网络，并配备了高刷新率屏幕。华为表示，这款手机将在全球范围内上市，预计会受到消费者的热烈欢迎。',
    coverImages: ['app.media.news_cover1'],
    category: '科技',
    source: '科技日报',
    author: {
      id: 'author_1',
      name: '科技前沿',
      avatar: 'app.media.default_avatar',
      isVerified: true,
      verifyType: '官方'
    },
    publishTime: '2024-01-15 10:30:00',
    readCount: 15000,
    likeCount: 1200,
    commentCount: 300,
    shareCount: 500,
    collectCount: 200,
    isLiked: false,
    isCollected: false,
    isRead: false,
    type: NewsType.SINGLE_IMAGE
  },
  {
    id: 'sample_2',
    title: '央行发布最新货币政策调整',
    summary: '央行宣布降准，释放流动性',
    content: '中国人民银行近日宣布下调金融机构存款准备金率，以支持实体经济发展。此次降准将释放长期资金约1万亿元，有助于降低社会融资成本，促进经济稳定增长。央行表示，将继续实施稳健的货币政策，保持流动性合理充裕。',
    coverImages: ['app.media.news_cover2'],
    category: '财经',
    source: '财经日报',
    author: {
      id: 'author_2',
      name: '财经观察',
      avatar: 'app.media.default_avatar',
      isVerified: true,
      verifyType: '官方'
    },
    publishTime: '2024-01-14 09:15:00',
    readCount: 12000,
    likeCount: 800,
    commentCount: 250,
    shareCount: 400,
    collectCount: 150,
    isLiked: false,
    isCollected: false,
    isRead: false,
    type: NewsType.SINGLE_IMAGE
  },
  {
    id: 'sample_3',
    title: '体育赛事精彩纷呈，观众热情高涨',
    summary: '国际足球比赛精彩瞬间',
    content: '近日举行的国际足球比赛中，双方球队展开了激烈角逐，最终以2:2平局收场。比赛过程中出现了多次精彩进球和精彩扑救，现场观众热情高涨。此次比赛不仅展示了运动员的高超技艺，也促进了国际体育交流。',
    coverImages: ['app.media.news_cover3'],
    category: '体育',
    source: '体育日报',
    author: {
      id: 'author_3',
      name: '体育达人',
      avatar: 'app.media.default_avatar',
      isVerified: false,
      verifyType: '个人'
    },
    publishTime: '2024-01-13 14:20:00',
    readCount: 9000,
    likeCount: 600,
    commentCount: 180,
    shareCount: 300,
    collectCount: 100,
    isLiked: false,
    isCollected: false,
    isRead: false,
    type: NewsType.MULTI_IMAGE
  }
];
