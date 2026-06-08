import { NewsItem, NewsType, AuthorInfo, HotSearch, Topic, Message, MessageType, Comment, UserInfo, LikeResult } from '../models/NewsModel';
import { PreferencesUtil } from '../utils/PreferencesUtil';

/**
 * Mock数据服务
 */
export class MockDataService {
  // ==================== 静态数据存储 ====================
  // 用于保存点赞和评论状态
  public static newsLikeStatus: Map<string, boolean> = new Map();
  public static newsLikeCount: Map<string, number> = new Map();
  // 用于保存收藏状态
  public static newsCollectStatus: Map<string, boolean> = new Map();
  public static newsCollectCount: Map<string, number> = new Map();
  // 用于保存评论数
  public static newsCommentCount: Map<string, number> = new Map();
  private static commentLikeStatus: Map<string, boolean> = new Map();
  private static commentLikeCount: Map<string, number> = new Map();
  private static commentsData: Map<string, Comment[]> = new Map();
  
  // 持久化存储的key
  private static readonly COMMENTS_STORAGE_KEY = 'comments_data';
  private static readonly COMMENT_COUNT_STORAGE_KEY = 'comment_count_data';
  
  // 全局状态版本号，用于通知页面刷新
  private static stateVersion: number = 0;
  public static readonly STATE_VERSION_KEY = 'newsStateVersion';
  
  /**
   * 通知新闻点赞状态变化（从详情页调用）
   * 用于通知封面页更新特定新闻的点赞状态
   */
  static notifyNewsLikeChanged() {
    MockDataService.stateVersion++;
    AppStorage.set<number>(MockDataService.STATE_VERSION_KEY, MockDataService.stateVersion);
    console.log(`MockDataService: 通知点赞状态变化，版本号: ${MockDataService.stateVersion}`);
  }
  
  /**
   * 通知新闻收藏状态变化
   * 用于通知其他页面更新特定新闻的收藏状态
   */
  static notifyNewsCollectChanged() {
    MockDataService.stateVersion++;
    AppStorage.set<number>(MockDataService.STATE_VERSION_KEY, MockDataService.stateVersion);
    console.log(`MockDataService: 通知收藏状态变化，版本号: ${MockDataService.stateVersion}`);
  }
  
  /**
   * 通知新闻评论数变化
   * 用于通知其他页面更新特定新闻的评论数
   */
  static notifyNewsCommentChanged() {
    MockDataService.stateVersion++;
    AppStorage.set<number>(MockDataService.STATE_VERSION_KEY, MockDataService.stateVersion);
    console.log(`MockDataService: 通知评论数变化，版本号: ${MockDataService.stateVersion}`);
  }
  
  /**
   * 生成Mock新闻列表
   */
  static getNewsList(category?: string, page: number = 1): NewsItem[] {
    const newsList: NewsItem[] = [];
    const pageSize = 10;
    const startIndex = (page - 1) * pageSize;

    for (let i = 0; i < pageSize; i++) {
      const index = startIndex + i;
      const newsType = MockDataService.getRandomNewsType();
      const newsCategory = category || MockDataService.getRandomCategory();
      const newsId = `news_${newsCategory}_${index}`;

      // 获取已保存的点赞状态和点赞数
      const savedIsLiked = MockDataService.newsLikeStatus.get(newsId) || false;
      const savedLikeCount = MockDataService.newsLikeCount.get(newsId);
      // 获取已保存的收藏状态和收藏数
      const savedIsCollected = MockDataService.newsCollectStatus.get(newsId) || false;
      const savedCollectCount = MockDataService.newsCollectCount.get(newsId);
      // 获取已保存的评论数
      const savedCommentCount = MockDataService.newsCommentCount.get(newsId);
      
      // 如果没有保存的评论数据，生成新的评论列表
      let commentCount = savedCommentCount;
      if (!MockDataService.commentsData.has(newsId)) {
        // 生成随机数量的评论（5-15条）
        const randomCommentCount = Math.floor(Math.random() * 11) + 5;
        const comments = MockDataService.generateComments(newsId, randomCommentCount);
        MockDataService.commentsData.set(newsId, comments);
        if (commentCount === undefined) {
          commentCount = randomCommentCount;
          MockDataService.newsCommentCount.set(newsId, commentCount);
        }
      } else {
        // 如果已有评论数据，使用实际评论数量
        if (commentCount === undefined) {
          const comments = MockDataService.commentsData.get(newsId);
          commentCount = comments ? comments.length : 10;
          MockDataService.newsCommentCount.set(newsId, commentCount);
        }
      }

      newsList.push({
        id: newsId,
        title: MockDataService.getMockTitle(index, newsCategory),
        summary: MockDataService.getMockSummary(index, newsCategory),
        content: MockDataService.getMockContent(index, newsCategory),
        coverImages: MockDataService.getMockCoverImages(newsType, newsCategory, index),
        category: newsCategory,
        source: MockDataService.getMockSource(),
        author: MockDataService.getMockAuthor(),
        publishTime: MockDataService.getMockTime(index),
        readCount: Math.floor(Math.random() * 100000),
        likeCount: savedLikeCount !== undefined ? savedLikeCount : Math.floor(Math.random() * 10000),
        commentCount: commentCount,
        shareCount: Math.floor(Math.random() * 500),
        collectCount: savedCollectCount !== undefined ? savedCollectCount : Math.floor(Math.random() * 300),
        isLiked: savedIsLiked,
        isCollected: savedIsCollected,
        isRead: index < 5,
        type: newsType,
        videoUrl: newsType === NewsType.VIDEO ? 'https://example.com/video.mp4' : undefined
      });
    }

    return newsList;
  }

  /**
   * 搜索新闻
   */
  static searchNews(keyword: string, sortBy: number = 0): NewsItem[] {
    if (!keyword || keyword.trim().length === 0) {
      return [];
    }

    const allNews: NewsItem[] = [];
    const categories = ['要闻', '财经', '娱乐', '体育', '科技', '社会', '国际', '军事', '教育', '健康'];

    categories.forEach((category: string) => {
      for (let page = 1; page <= 3; page++) {
        const newsList = MockDataService.getNewsList(category, page);
        allNews.push(...newsList);
      }
    });

    const searchKeyword = keyword.trim().toLowerCase();
    const results = allNews.filter((news: NewsItem) => {
      return news.title.toLowerCase().includes(searchKeyword) ||
             news.summary.toLowerCase().includes(searchKeyword) ||
             news.category.toLowerCase().includes(searchKeyword) ||
             news.author.name.toLowerCase().includes(searchKeyword) ||
             news.source.toLowerCase().includes(searchKeyword);
    });

    // 根据排序方式排序
    if (sortBy === 1) {
      // 最新 - 按发布时间排序（这里简化处理）
      return results.slice(0, 50);
    } else if (sortBy === 2) {
      // 最热 - 按阅读数排序
      return results.sort((a: NewsItem, b: NewsItem) => b.readCount - a.readCount).slice(0, 50);
    }
    
    // 综合 - 默认排序
    return results.slice(0, 50);
  }

  /**
   * 获取热门搜索列表
   * @param type 0: 热搜榜, 1: 热榜, 2: 新榜
   */
  static getHotSearchList(type: number = 0): HotSearch[] {
    // 热搜榜 - 按热度排序的热门搜索关键词
    const hotSearchList: HotSearch[] = [
      { rank: 1, keyword: '要闻', heat: 1000000, trend: 'hot', label: '热' },
      { rank: 2, keyword: '科技', heat: 980000, trend: 'up', label: '升' },
      { rank: 3, keyword: '财经', heat: 950000, trend: 'hot', label: '热' },
      { rank: 4, keyword: '体育', heat: 900000, trend: 'new', label: '新' },
      { rank: 5, keyword: '娱乐', heat: 850000, trend: 'down' },
      { rank: 6, keyword: '国际', heat: 800000, trend: 'up', label: '升' },
      { rank: 7, keyword: '社会', heat: 750000, trend: 'hot', label: '热' },
      { rank: 8, keyword: '军事', heat: 700000, trend: 'new', label: '新' },
      { rank: 9, keyword: '教育', heat: 650000, trend: 'up', label: '升' },
      { rank: 10, keyword: '健康', heat: 600000, trend: 'down' }
    ];

    // 热榜 - 实时热点事件
    const hotList: HotSearch[] = [
      { rank: 1, keyword: '国务院', heat: 1500000, trend: 'hot', label: '爆' },
      { rank: 2, keyword: '人工智能', heat: 1200000, trend: 'up', label: '升' },
      { rank: 3, keyword: 'A股', heat: 1100000, trend: 'hot', label: '热' },
      { rank: 4, keyword: '女排', heat: 950000, trend: 'new', label: '新' },
      { rank: 5, keyword: '电影', heat: 880000, trend: 'down' },
      { rank: 6, keyword: '国际合作', heat: 820000, trend: 'up', label: '升' },
      { rank: 7, keyword: '惠民政策', heat: 780000, trend: 'hot', label: '热' },
      { rank: 8, keyword: '芯片', heat: 720000, trend: 'new', label: '新' },
      { rank: 9, keyword: '社会保障', heat: 680000, trend: 'up', label: '升' },
      { rank: 10, keyword: '货币政策', heat: 620000, trend: 'down' }
    ];

    // 新榜 - 最新发布的内容
    const newList: HotSearch[] = [
      { rank: 1, keyword: '通信卫星', heat: 500000, trend: 'new', label: '新' },
      { rank: 2, keyword: '大模型', heat: 480000, trend: 'new', label: '新' },
      { rank: 3, keyword: '存款利率', heat: 450000, trend: 'up', label: '升' },
      { rank: 4, keyword: '世预赛', heat: 420000, trend: 'new', label: '新' },
      { rank: 5, keyword: '导演', heat: 380000, trend: 'up', label: '升' },
      { rank: 6, keyword: '领导人', heat: 350000, trend: 'new', label: '新' },
      { rank: 7, keyword: '教育公平', heat: 320000, trend: 'up', label: '升' },
      { rank: 8, keyword: 'CBA', heat: 280000, trend: 'new', label: '新' },
      { rank: 9, keyword: '音乐节', heat: 250000, trend: 'up', label: '升' },
      { rank: 10, keyword: '两会', heat: 220000, trend: 'new', label: '新' }
    ];

    // 根据 type 返回不同的榜单
    if (type === 1) {
      return hotList;
    } else if (type === 2) {
      return newList;
    }
    
    return hotSearchList;
  }

  /**
   * 获取话题列表
   */
  static getTopicList(): Topic[] {
    return [
      {
        id: 'topic_1',
        name: '科技创新',
        description: '探讨最新科技发展趋势',
        cover: 'https://picsum.photos/400/300?random=201',
        followCount: 125000,
        newsCount: 3580,
        isFollowed: false,
        category: '科技'
      },
      {
        id: 'topic_2',
        name: '财经投资',
        description: '分享投资理财经验',
        cover: 'https://picsum.photos/400/300?random=202',
        followCount: 98000,
        newsCount: 2450,
        isFollowed: false,
        category: '财经'
      },
      {
        id: 'topic_3',
        name: '体育竞技',
        description: '关注体育赛事动态',
        cover: 'https://picsum.photos/400/300?random=203',
        followCount: 156000,
        newsCount: 4200,
        isFollowed: true,
        category: '体育'
      },
      {
        id: 'topic_4',
        name: '娱乐明星',
        description: '娱乐圈最新资讯',
        cover: 'https://picsum.photos/400/300?random=204',
        followCount: 210000,
        newsCount: 5600,
        isFollowed: false,
        category: '娱乐'
      }
    ];
  }

  /**
   * 根据话题获取新闻
   */
  static getNewsByTopic(topicId: string): NewsItem[] {
    // 获取专题信息
    const topics = MockDataService.getTopicList();
    const topic = topics.find((t: Topic) => t.id === topicId);
    
    // 如果专题有对应的分类，返回该分类的新闻
    if (topic && topic.category) {
      return MockDataService.getNewsList(topic.category, 1);
    }
    
    // 否则返回随机新闻
    return MockDataService.getNewsList(undefined, 1).slice(0, 5);
  }

  /**
   * 获取消息列表
   */
  static getMessageList(type: string): Message[] {
    const messages: Message[] = [];
    for (let i = 0; i < 10; i++) {
      messages.push({
        id: `msg_${i}`,
        type: MockDataService.getRandomMessageType(),
        title: `消息标题${i + 1}`,
        content: `这是消息内容的详细描述，包含了消息的核心信息。`,
        sender: MockDataService.getMockAuthor(),
        createTime: `${i + 1}小时前`,
        isRead: i < 3
      });
    }
    return messages;
  }

  /**
   * 获取评论列表
   */
  static getCommentList(newsId: string): Comment[] {
    const comments: Comment[] = [];
    for (let i = 0; i < 10; i++) {
      comments.push({
        id: `comment_${i}`,
        newsId: newsId,
        author: MockDataService.getMockAuthor(),
        content: `这是第${i + 1}条评论内容，表达了对新闻的看法和观点。`,
        publishTime: `${i + 1}小时前`,
        likeCount: Math.floor(Math.random() * 100),
        replyCount: Math.floor(Math.random() * 10),
        isLiked: false,
        replies: []
      });
    }
    return comments;
  }

  /**
   * 生成指定数量的评论
   * @param newsId 新闻ID
   * @param count 评论数量
   * @returns 评论列表
   */
  private static generateComments(newsId: string, count: number): Comment[] {
    const comments: Comment[] = [];
    for (let i = 0; i < count; i++) {
      comments.push({
        id: `comment_${newsId}_${i}`,
        newsId: newsId,
        author: MockDataService.getMockAuthor(),
        content: `这是第${i + 1}条评论内容，表达了对新闻的看法和观点。`,
        publishTime: `${i + 1}小时前`,
        likeCount: Math.floor(Math.random() * 100),
        replyCount: Math.floor(Math.random() * 10),
        isLiked: false,
        replies: []
      });
    }
    return comments;
  }

  /**
   * 获取用户信息
   */
  static getUserInfo(): UserInfo {
    return {
      id: 'user_001',
      name: '测试用户',
      avatar: 'https://picsum.photos/200/200?random=301',
      signature: '这是一段个性签名',
      gender: '男',
      birthday: '1990-01-01',
      location: '北京',
      publishCount: 32,
      followCount: 89,
      fansCount: 1256,
      likeCount: 1580,
      collectCount: 45,
      isVerified: true
    };
  }

  // ==================== 点赞和评论功能 ====================

  /**
   * 切换新闻点赞状态
   * @param newsId 新闻ID
   * @param currentLikeCount 当前点赞数
   * @returns 点赞结果
   */
  static toggleNewsLike(newsId: string, currentLikeCount: number): LikeResult {
    const isLiked = MockDataService.newsLikeStatus.get(newsId) || false;
    const newIsLiked = !isLiked;
    
    // 更新点赞状态
    MockDataService.newsLikeStatus.set(newsId, newIsLiked);
    
    // 更新点赞数
    let likeCount = MockDataService.newsLikeCount.get(newsId);
    if (likeCount === undefined) {
      likeCount = currentLikeCount;
    }
    likeCount += newIsLiked ? 1 : -1;
    MockDataService.newsLikeCount.set(newsId, likeCount);
    
    const result: LikeResult = {
      isLiked: newIsLiked,
      likeCount: likeCount
    };
    
    return result;
  }

  /**
   * 切换新闻收藏状态
   * @param newsId 新闻ID
   * @param currentCollectCount 当前收藏数
   * @returns 收藏结果
   */
  static toggleNewsCollect(newsId: string, currentCollectCount: number): LikeResult {
    const isCollected = MockDataService.newsCollectStatus.get(newsId) || false;
    const newIsCollected = !isCollected;
    
    // 更新收藏状态
    MockDataService.newsCollectStatus.set(newsId, newIsCollected);
    
    // 更新收藏数
    let collectCount = MockDataService.newsCollectCount.get(newsId);
    if (collectCount === undefined) {
      collectCount = currentCollectCount;
    }
    collectCount += newIsCollected ? 1 : -1;
    MockDataService.newsCollectCount.set(newsId, collectCount);
    
    const result: LikeResult = {
      isLiked: newIsCollected,
      likeCount: collectCount
    };
    
    return result;
  }

  /**
   * 切换评论点赞状态
   * @param commentId 评论ID
   * @param currentLikeCount 当前点赞数
   * @returns 点赞结果
   */
  static toggleCommentLike(commentId: string, currentLikeCount: number): LikeResult {
    const isLiked = MockDataService.commentLikeStatus.get(commentId) || false;
    const newIsLiked = !isLiked;
    
    // 更新点赞状态
    MockDataService.commentLikeStatus.set(commentId, newIsLiked);
    
    // 更新点赞数
    let likeCount = MockDataService.commentLikeCount.get(commentId);
    if (likeCount === undefined) {
      likeCount = currentLikeCount;
    }
    likeCount += newIsLiked ? 1 : -1;
    MockDataService.commentLikeCount.set(commentId, likeCount);
    
    const result: LikeResult = {
      isLiked: newIsLiked,
      likeCount: likeCount
    };
    
    return result;
  }

  /**
   * 添加评论
   * @param newsId 新闻ID
   * @param content 评论内容
   * @returns 新添加的评论
   */
  static async addComment(newsId: string, content: string): Promise<Comment> {
    // 获取或创建评论列表
    let comments = MockDataService.commentsData.get(newsId);
    if (!comments) {
      comments = MockDataService.getCommentList(newsId);
      MockDataService.commentsData.set(newsId, comments);
    }
    
    // 创建新评论
    const newComment: Comment = {
      id: `comment_${Date.now()}`,
      newsId: newsId,
      author: {
        id: 'user_001',
        name: '测试用户',
        avatar: 'https://picsum.photos/200/200?random=301',
        isVerified: true
      },
      content: content,
      publishTime: '刚刚',
      likeCount: 0,
      replyCount: 0,
      isLiked: false,
      replies: []
    };
    
    // 将新评论添加到列表开头
    comments.unshift(newComment);
    
    // 更新新闻的评论数
    let commentCount = MockDataService.newsCommentCount.get(newsId);
    const oldCount = commentCount;
    if (commentCount === undefined) {
      // 如果之前没有保存过评论数，初始化为当前评论列表长度
      commentCount = comments.length;
    } else {
      // 否则加1
      commentCount += 1;
    }
    MockDataService.newsCommentCount.set(newsId, commentCount);
    
    console.log(`MockDataService: 更新评论数 - 新闻ID: ${newsId}, 原评论数: ${oldCount}, 新评论数: ${commentCount}`);
    
    // 通知页面刷新
    MockDataService.notifyNewsCommentChanged();
    
    // 保存到本地存储（等待保存完成）
    await MockDataService.saveCommentsToStorage();
    
    return newComment;
  }

  /**
   * 获取评论列表（带状态）
   * @param newsId 新闻ID
   * @returns 评论列表
   */
  static getCommentsWithStatus(newsId: string): Comment[] {
    // 检查是否有保存的评论数据
    let comments = MockDataService.commentsData.get(newsId);
    if (!comments) {
      // 如果没有，生成新的评论数据
      comments = MockDataService.getCommentList(newsId);
      MockDataService.commentsData.set(newsId, comments);
    }
    
    // 应用点赞状态
    const result: Comment[] = [];
    for (let i = 0; i < comments.length; i++) {
      const comment = comments[i];
      const isLiked = MockDataService.commentLikeStatus.get(comment.id) || false;
      const likeCount = MockDataService.commentLikeCount.get(comment.id);
      
      const updatedComment: Comment = {
        id: comment.id,
        newsId: comment.newsId,
        author: comment.author,
        content: comment.content,
        publishTime: comment.publishTime,
        likeCount: likeCount !== undefined ? likeCount : comment.likeCount,
        replyCount: comment.replyCount,
        isLiked: isLiked,
        replies: comment.replies
      };
      
      result.push(updatedComment);
    }
    
    return result;
  }

  /**
   * 获取新闻点赞状态
   * @param newsId 新闻ID
   * @returns 是否已点赞
   */
  static getNewsLikeStatus(newsId: string): boolean {
    return MockDataService.newsLikeStatus.get(newsId) || false;
  }
  
  /**
   * 获取新闻点赞数
   * @param newsId 新闻ID
   * @returns 点赞数（如果未保存则返回undefined）
   */
  static getNewsLikeCount(newsId: string): number | undefined {
    return MockDataService.newsLikeCount.get(newsId);
  }

  /**
   * 获取新闻收藏状态
   * @param newsId 新闻ID
   * @returns 是否已收藏
   */
  static getNewsCollectStatus(newsId: string): boolean {
    return MockDataService.newsCollectStatus.get(newsId) || false;
  }
  
  /**
   * 获取新闻收藏数
   * @param newsId 新闻ID
   * @returns 收藏数（如果未保存则返回undefined）
   */
  static getNewsCollectCount(newsId: string): number | undefined {
    return MockDataService.newsCollectCount.get(newsId);
  }

  /**
   * 获取新闻评论数
   * @param newsId 新闻ID
   * @returns 评论数（如果未保存则返回undefined）
   */
  static getNewsCommentCount(newsId: string): number | undefined {
    return MockDataService.newsCommentCount.get(newsId);
  }

  // 私有辅助方法

  private static getRandomNewsType(): NewsType {
    const types = [NewsType.SINGLE_IMAGE, NewsType.MULTI_IMAGE, NewsType.TEXT];
    return types[Math.floor(Math.random() * types.length)];
  }

  private static getRandomCategory(): string {
    const categories: string[] = ['要闻', '财经', '娱乐', '体育', '科技', '社会', '国际'];
    return categories[Math.floor(Math.random() * categories.length)];
  }

  private static getMockTitle(index: number, category: string): string {
    const titles: Record<string, string[]> = {
      '要闻': [
        '国务院发布最新政策，推动经济高质量发展',
        '全国两会胜利闭幕，多项重要决议通过',
        '中国科技创新取得重大突破，引领行业发展'
      ],
      '财经': [
        'A股市场今日大涨，科技板块领涨',
        '央行发布最新货币政策报告',
        '多家银行下调存款利率，释放积极信号'
      ],
      '科技': [
        '我国成功发射新一代通信卫星',
        '人工智能大模型取得重要进展',
        '国产芯片研发获得重大突破'
      ],
      '体育': [
        '中国女排世界锦标赛夺冠',
        '国足世预赛取得关键胜利',
        'CBA总决赛精彩对决落幕'
      ],
      '娱乐': [
        '国产电影票房再创新高',
        '知名导演新作即将上映',
        '音乐节吸引数万观众参与'
      ],
      '社会': [
        '多地出台惠民新政策',
        '社会保障体系不断完善',
        '教育公平取得新进展'
      ],
      '国际': [
        '中国在国际会议上发挥重要作用',
        '多国领导人高度评价中国发展',
        '国际合作取得新进展'
      ]
    };

    const categoryTitles = titles[category] || titles['要闻'];
    return categoryTitles[index % categoryTitles.length];
  }

  private static getMockSummary(index: number, category: string): string {
    const summaries: Record<string, string[]> = {
      '要闻': [
        '国务院今日发布最新政策文件，明确提出推动经济高质量发展的具体措施和目标，受到社会各界的广泛关注。',
        '全国两会圆满闭幕，会议期间审议通过了多项重要决议，为未来发展指明了方向，具有深远意义。',
        '我国在科技创新领域取得重大突破，多项关键技术达到国际领先水平，为产业发展注入新动力。'
      ],
      '财经': [
        'A股市场今日表现强劲，科技板块领涨，市场信心得到提振，投资者情绪乐观。',
        '央行发布最新货币政策执行报告，分析了当前经济金融形势，提出了下一步工作重点。',
        '多家商业银行宣布下调存款利率，释放出积极的市场信号，有助于降低企业融资成本。'
      ],
      '科技': [
        '我国成功发射新一代通信卫星，标志着航天事业迈上新台阶，将大幅提升通信服务能力。',
        '国内人工智能大模型研发取得重要进展，在多个应用场景展现出强大潜力，引起业界关注。',
        '国产芯片研发获得重大突破，性能指标达到国际先进水平，为科技自立自强奠定基础。'
      ],
      '体育': [
        '中国女排在世界锦标赛决赛中表现出色，成功夺冠，展现了顽强拼搏的精神风貌。',
        '国足在世界杯预选赛中取得关键胜利，为晋级之路增添了重要砝码，球迷欢欣鼓舞。',
        'CBA总决赛经过激烈角逐落下帷幕，精彩对决为观众奉献了一场篮球盛宴。'
      ],
      '娱乐': [
        '国产电影持续发力，票房成绩再创新高，展现了中国电影产业的蓬勃生机。',
        '知名导演最新力作即将上映，影片备受期待，有望成为年度话题之作。',
        '大型音乐节成功举办，吸引数万观众参与，现场气氛热烈，成为文化盛事。'
      ],
      '社会': [
        '多个地区相继出台惠民新政策，在教育、医疗、住房等方面为群众带来实实在在的福利。',
        '社会保障体系建设不断完善，覆盖面持续扩大，保障水平稳步提升，惠及更多群众。',
        '教育公平工作取得新进展，优质教育资源向基层延伸，让更多孩子享受良好教育。'
      ],
      '国际': [
        '中国代表在重要国际会议上积极发声，为全球治理贡献中国智慧，展现大国担当。',
        '多国领导人高度评价中国发展成就，认为中国经验具有重要借鉴意义。',
        '国际合作项目取得新进展，各方携手应对全球挑战，推动构建人类命运共同体。'
      ]
    };

    const categorySummaries = summaries[category] || summaries['要闻'];
    return categorySummaries[index % categorySummaries.length];
  }

  private static getMockContent(index: number, category: string): string {
    const contents: Record<string, string[]> = {
      '要闻': [
        '国务院今日正式发布最新政策文件，明确提出推动经济高质量发展的具体措施和目标。\n\n文件指出，要坚持稳中求进工作总基调，完整、准确、全面贯彻新发展理念，加快构建新发展格局，着力推动高质量发展。\n\n主要措施包括：深化供给侧结构性改革、扩大内需、推动科技创新、优化营商环境等。专家表示，这些政策措施将为经济发展注入新动力，具有重要指导意义。\n\n社会各界对此高度关注，认为政策出台及时、措施有力，必将推动经济实现质的有效提升和量的合理增长。',
        '全国两会圆满闭幕，会议期间审议通过了多项重要决议，为未来发展指明了方向。\n\n会议期间，代表委员们认真履职尽责，围绕经济社会发展重大问题建言献策。会议审议通过的决议涵盖经济发展、民生改善、法治建设等多个领域。\n\n代表们纷纷表示，将把会议精神带回各自工作岗位，以实际行动推动各项决策部署落地见效。\n\n此次两会成果丰硕，对于凝聚共识、汇聚力量，推动全面建设社会主义现代化国家具有重要而深远的意义。',
        '我国在科技创新领域取得重大突破，多项关键技术达到国际领先水平，为产业发展注入新动力。\n\n据相关部门介绍，此次突破涉及人工智能、量子计算、生物医药等多个前沿领域。其中，部分技术已开始产业化应用，展现出巨大市场潜力。\n\n专家指出，这些成果的取得，得益于国家长期以来的战略布局和持续投入，也体现了我国科技工作者的创新精神和攻坚能力。\n\n未来，我国将继续加大科技创新支持力度，推动更多关键核心技术实现突破，为建设科技强国奠定坚实基础。'
      ],
      '财经': [
        'A股市场今日表现强劲，主要指数全线上涨，其中科技板块领涨，市场信心得到提振。\n\n截至收盘，上证指数上涨2.3%，深证成指上涨2.8%，创业板指上涨3.1%。科技、新能源、医药等板块涨幅居前，成交额明显放大。\n\n市场分析人士认为，此次上涨主要受到政策利好、经济数据改善等多重因素影响。投资者情绪明显好转，对未来市场走势持乐观态度。\n\n机构投资者普遍表示，当前市场估值处于合理区间，具备较好的投资价值，建议关注科技创新、高端制造等领域的优质标的。',
        '央行今日发布最新货币政策执行报告，全面分析了当前经济金融形势，提出了下一步工作重点。\n\n报告指出，将继续实施稳健的货币政策，保持流动性合理充裕，支持实体经济高质量发展。同时，将加强逆周期调节，灵活运用多种货币政策工具。\n\n报告强调，要深化金融供给侧结构性改革，完善市场化利率形成和传导机制，提升金融服务实体经济质效。\n\n专家解读认为，报告释放出政策保持连续性稳定性、适时适度预调微调的信号，有助于稳定市场预期，支持经济平稳运行。',
        '多家商业银行今日宣布下调存款利率，这是继前期贷款利率下调后的又一重要举措。\n\n据了解，此次调整涉及活期存款和定期存款多个品种，下调幅度在5-15个基点不等。银行表示，此举旨在优化资产负债结构，降低负债成本。\n\n业内人士分析，存款利率下调有助于引导资金流向实体经济，降低企业融资成本，支持经济复苏。同时，也将促进居民优化资产配置，增加消费和投资。\n\n专家预计，未来存款利率市场化改革将继续深化，利率传导机制将更加顺畅。'
      ],
      '科技': [
        '我国成功发射新一代通信卫星，标志着航天事业迈上新台阶，将大幅提升通信服务能力。\n\n今日凌晨，运载火箭在卫星发射中心点火升空，成功将新一代通信卫星送入预定轨道。卫星太阳翼顺利展开，各项参数正常，发射任务取得圆满成功。\n\n这颗卫星是我国自主研制的新一代大容量通信卫星，采用了多项创新技术，通信容量和覆盖范围大幅提升。投入使用后，将为偏远地区提供高质量通信服务。\n\n卫星研制团队表示，此次发射成功凝聚了多年心血，展现了我国航天科技的进步。未来将继续攻关，为建设航天强国贡献力量。',
        '国内人工智能大模型研发取得重要进展，在多个应用场景展现出强大潜力，引起业界广泛关注。\n\n据悉，该大模型在自然语言处理、图像识别、知识推理等方面表现优异，多项指标达到国际先进水平。特别是在中文理解和生成方面具有独特优势。\n\n目前，该模型已在智能客服、内容创作、辅助决策等领域开始应用测试，效果显著。多家企业表达了合作意向，希望将技术应用于实际生产。\n\n专家评价认为，这一成果表明我国在人工智能核心技术上正在缩小与国际先进水平的差距，为产业发展提供了有力支撑。未来应用前景广阔。',
        '国产芯片研发获得重大突破，性能指标达到国际先进水平，为科技自立自强奠定坚实基础。\n\n研发团队今日宣布，经过多年攻关，成功研制出新一代高性能芯片。测试结果显示，该芯片在计算性能、功耗控制、集成度等方面均达到国际先进水平。\n\n这款芯片采用先进的制程工艺和架构设计，具备高性能、低功耗、高可靠等特点，可广泛应用于数据中心、智能终端、自动驾驶等领域。\n\n业内专家表示，此次突破意义重大，不仅打破了技术瓶颈，更增强了产业链自主可控能力。未来将继续加大研发投入，推动芯片产业高质量发展。'
      ],
      '体育': [
        '中国女排在世界锦标赛决赛中表现出色，以顽强拼搏的精神成功夺冠，为国争光。\n\n决赛中，中国女排面对强劲对手，在先失一局的不利局面下连扳三局，最终以3:1获胜。队员们在关键时刻展现出强大的心理素质和技战术水平。\n\n主教练赛后表示，这个冠军来之不易，是全体队员和教练组共同努力的结果。队伍将继续发扬女排精神，在未来的比赛中再创佳绩。\n\n球迷们纷纷通过社交媒体表达祝贺，认为这次夺冠再次证明了中国女排的实力，激励着全国人民团结奋斗、勇攀高峰。',
        '国足在世界杯预选赛中取得关键胜利，为晋级之路增添了重要砝码，球迷欢欣鼓舞。\n\n今晚的比赛，国足面对实力不俗的对手，凭借出色的团队配合和顽强的防守，最终以2:0获胜。两个进球都来自精彩的团队配合，展现了队伍的进步。\n\n主教练赛后表示，球队在这段时间的训练很有成效，队员们的执行力和拼搏精神值得肯定。但晋级之路还很漫长，需要继续努力。\n\n这场胜利让国足在小组积分榜上处于有利位置，出线希望大增。球迷们纷纷表示，希望球队保持状态，在接下来的比赛中继续取得好成绩。',
        'CBA总决赛经过激烈角逐落下帷幕，精彩对决为观众奉献了一场篮球盛宴。\n\n总决赛采用七场四胜制，双方你来我往，战至最后一刻才分出胜负。决胜场中，冠军球队凭借末节的出色发挥，最终以微弱优势获胜，总比分4:3夺冠。\n\n冠军球队的核心球员荣膺总决赛MVP，他在系列赛中场均贡献高分，关键时刻屡屡挺身而出，是球队夺冠的头号功臣。\n\n本赛季CBA联赛整体水平显著提升，精彩比赛层出不穷，观众上座率和收视率均创新高。联赛负责人表示，将继续推动联赛职业化发展，为球迷呈现更精彩的比赛。'
      ],
      '娱乐': [
        '国产电影持续发力，票房成绩再创新高，展现了中国电影产业的蓬勃生机。\n\n据最新统计，该片上映以来票房持续攀升，已突破多项纪录，成为年度票房冠军。影片凭借精良的制作、动人的故事和出色的表演，赢得了观众和口碑双丰收。\n\n业内分析认为，近年来国产电影质量稳步提升，题材类型日益丰富，工业化水平不断提高，这是票房佳绩的根本原因。观众对国产电影的认可度和期待值也在提升。\n\n电影主管部门表示，将继续支持优秀国产电影创作，完善产业政策，推动中国电影高质量发展，为观众奉献更多精品力作。',
        '知名导演最新力作即将上映，影片备受期待，有望成为年度话题之作。\n\n该导演以独特的艺术风格和深刻的人文关怀著称，此前的作品屡获国际大奖。新作历时三年精心打造，投资规模创其个人作品新高。\n\n影片讲述了一个触动人心的故事，探讨了当代社会的重要议题。演员阵容强大，多位实力派演员加盟，表演备受好评。\n\n提前观影的影评人给予高度评价，认为影片兼具艺术性和观赏性，有望在颁奖季有所斩获。观众期待值持续攀升，预售票房表现亮眼。',
        '大型音乐节成功举办，吸引数万观众参与，现场气氛热烈，成为年度文化盛事。\n\n本次音乐节汇聚了众多知名音乐人和乐队，涵盖流行、摇滚、民谣等多种风格。三天活动期间，数万名乐迷齐聚现场，享受音乐盛宴。\n\n主办方精心设计了多个舞台，满足不同音乐爱好者的需求。现场设施完善，安保措施到位，活动秩序井然，观众体验良好。\n\n音乐节的成功举办，不仅丰富了群众文化生活，也带动了周边旅游、餐饮等产业发展，实现了文化效益和经济效益的双丰收。主办方表示，将继续打造这一品牌活动，为乐迷带来更好的体验。'
      ],
      '社会': [
        '多个地区相继出台惠民新政策，在教育、医疗、住房等方面为群众带来实实在在的福利。\n\n这些政策涵盖范围广泛，包括扩大优质教育资源覆盖面、降低医疗费用负担、增加保障性住房供给等。各地结合实际情况，推出了具有地方特色的惠民举措。\n\n以教育为例，多地增加公办学位供给，推进义务教育均衡发展；医疗方面，扩大医保报销范围，降低群众就医负担；住房领域，加大保障房建设力度，解决新市民住房问题。\n\n群众对这些政策反响热烈，认为措施实在、针对性强，切实解决了急难愁盼问题。专家指出，这些政策的出台体现了以人民为中心的发展思想，将不断增强群众获得感幸福感。',
        '社会保障体系建设不断完善，覆盖面持续扩大，保障水平稳步提升，惠及更多群众。\n\n近年来，我国社会保障制度改革持续深化，建成了世界上规模最大的社会保障体系。基本养老保险、医疗保险参保人数持续增加，保障范围不断扩大。\n\n在提高保障水平方面，退休人员养老金实现连续上涨，居民医保财政补助标准提高，社会救助标准动态调整机制不断完善。多层次社会保障体系加快构建。\n\n这些进展让更多群众享受到社会保障的温暖，特别是困难群体得到了更好的兜底保障。下一步，将继续完善制度，推动社会保障事业高质量发展，织密扎牢社会保障安全网。',
        '教育公平工作取得新进展，优质教育资源向基层延伸，让更多孩子享受良好教育。\n\n教育部门持续推进义务教育均衡发展，通过集团化办学、教师轮岗交流、信息化建设等措施，缩小城乡、区域、校际差距，促进优质资源共享。\n\n在乡村教育方面，实施乡村教师支持计划，提高乡村教师待遇，改善办学条件，让乡村孩子也能接受良好教育。同时，加大对贫困家庭学生资助力度，确保不让一个孩子因家庭经济困难而失学。\n\n这些举措取得了明显成效，人民群众对教育的满意度不断提升。教育公平是社会公平的重要基础，将继续深化改革，推动教育公平迈上新台阶。'
      ],
      '国际': [
        '中国代表在重要国际会议上积极发声，为全球治理贡献中国智慧，展现大国担当。\n\n在此次国际会议上，中国代表团围绕气候变化、可持续发展、全球公共卫生等议题提出了一系列建设性主张和方案，得到与会各方积极响应。\n\n中方强调，各国应坚持多边主义，加强团结合作，共同应对全球性挑战。中国将继续以实际行动支持全球治理体系改革，推动构建人类命运共同体。\n\n与会代表高度评价中国在国际事务中发挥的积极作用，认为中国方案为解决全球问题提供了重要思路。会议达成的多项共识中，吸纳了中国提出的主张。',
        '多国领导人高度评价中国发展成就，认为中国经验具有重要借鉴意义。\n\n近期，多位外国领导人在不同场合表达了对中国发展的赞赏。他们指出，中国在经济发展、脱贫攻坚、科技创新等方面取得的成就令人瞩目，为发展中国家提供了宝贵经验。\n\n特别是中国在消除贫困方面的成功实践，被认为是人类减贫史上的奇迹。多国表示希望学习借鉴中国经验，探索符合本国国情的发展道路。\n\n中国方面表示，愿意与各国分享发展经验，但各国应根据自身实际情况选择适合的发展模式。中国将继续致力于促进共同发展，推动构建新型国际关系。',
        '国际合作项目取得新进展，各方携手应对全球挑战，推动构建人类命运共同体。\n\n多个国际合作项目传来好消息：在气候变化领域，各国就减排目标达成新共识；在公共卫生领域，疫苗国际合作持续推进；在基础设施建设方面，互联互通项目取得实质进展。\n\n这些成果的取得，体现了国际社会加强合作、共克时艰的共同意愿。面对全球性挑战，任何国家都无法独善其身，唯有团结合作才是正确选择。\n\n中国积极参与并推动国际合作，为项目成功作出了重要贡献。未来，中国将继续秉持合作共赢理念，与各国一道，推动全球治理朝着更加公正合理的方向发展。'
      ]
    };

    const categoryContents = contents[category] || contents['要闻'];
    return categoryContents[index % categoryContents.length];
  }

  private static getMockCoverImages(type: NewsType, category?: string, index?: number): string[] {
    // 使用网络图片（与 NetworkNewsService 保持一致）
    const networkImages: string[] = [
      'https://picsum.photos/400/300?random=101',
      'https://picsum.photos/400/300?random=102',
      'https://picsum.photos/400/300?random=103',
      'https://picsum.photos/400/300?random=104',
      'https://picsum.photos/400/300?random=105',
      'https://picsum.photos/400/300?random=106',
      'https://picsum.photos/400/300?random=107',
      'https://picsum.photos/400/300?random=108',
      'https://picsum.photos/400/300?random=109',
      'https://picsum.photos/400/300?random=110'
    ];

    const imageIndex = index !== undefined ? index % networkImages.length : 0;

    switch (type) {
      case NewsType.SINGLE_IMAGE:
        return [networkImages[imageIndex]];
      case NewsType.MULTI_IMAGE:
        return [
          networkImages[imageIndex % networkImages.length],
          networkImages[(imageIndex + 1) % networkImages.length],
          networkImages[(imageIndex + 2) % networkImages.length]
        ];
      default:
        return [];
    }
  }

  private static getMockSource(): string {
    const sources: string[] = ['新华社', '人民日报', '央视新闻', '中国新闻网', '环球时报'];
    return sources[Math.floor(Math.random() * sources.length)];
  }

  private static getMockAuthor(): AuthorInfo {
    const names: string[] = ['新闻小编', '财经观察', '科技前沿', '体育达人', '娱乐八卦'];
    const index = Math.floor(Math.random() * names.length);
    return {
      id: `author_${index}`,
      name: names[index],
      avatar: `https://picsum.photos/100/100?random=${300 + index}`,
      isVerified: Math.random() > 0.5,
      verifyType: Math.random() > 0.5 ? '官方' : '个人'
    };
  }

  private static getMockTime(index: number): string {
    const now = new Date();
    const minutesAgo = index * 5;
    now.setMinutes(now.getMinutes() - minutesAgo);

    if (minutesAgo < 60) {
      return `${minutesAgo}分钟前`;
    } else if (minutesAgo < 1440) {
      return `${Math.floor(minutesAgo / 60)}小时前`;
    } else {
      return `${Math.floor(minutesAgo / 1440)}天前`;
    }
  }

  /**
   * 添加回复
   * @param newsId 新闻ID
   * @param commentId 评论ID
   * @param content 回复内容
   * @returns 新回复
   */
  static async addReply(newsId: string, commentId: string, content: string): Promise<Comment> {
    // 获取评论列表
    let comments = MockDataService.commentsData.get(newsId);
    if (!comments) {
      comments = MockDataService.getCommentList(newsId);
      MockDataService.commentsData.set(newsId, comments);
    }
    
    // 找到对应的评论
    const commentIndex = comments.findIndex(c => c.id === commentId);
    if (commentIndex === -1) {
      throw new Error('Comment not found');
    }
    
    const comment = comments[commentIndex];
    
    // 创建新回复
    const newReply: Comment = {
      id: `reply_${Date.now()}`,
      newsId: newsId,
      author: {
        id: 'user_001',
        name: '测试用户',
        avatar: 'https://picsum.photos/200/200?random=301',
        isVerified: true
      },
      content: content,
      publishTime: '刚刚',
      likeCount: 0,
      replyCount: 0,
      isLiked: false,
      replies: []
    };
    
    // 将新回复添加到评论的回复列表
    if (!comment.replies) {
      comment.replies = [];
    }
    comment.replies.unshift(newReply);
    
    // 更新评论的回复数
    comment.replyCount = comment.replies.length;
    
    // 更新评论列表
    comments[commentIndex] = comment;
    MockDataService.commentsData.set(newsId, comments);
    
    // 更新新闻的评论数（回复也算评论）
    let commentCount = MockDataService.newsCommentCount.get(newsId);
    if (commentCount === undefined) {
      commentCount = comments.length;
    } else {
      commentCount += 1;
    }
    MockDataService.newsCommentCount.set(newsId, commentCount);
    
    // 通知页面刷新
    MockDataService.notifyNewsCommentChanged();
    
    // 保存到本地存储（等待保存完成）
    await MockDataService.saveCommentsToStorage();
    
    return newReply;
  }

  /**
   * 保存评论数据到本地存储
   */
  static async saveCommentsToStorage(): Promise<void> {
    try {
      // 将commentsData转换为可序列化的对象
      const commentsObj: Record<string, Comment[]> = {};
      MockDataService.commentsData.forEach((value, key) => {
        commentsObj[key] = value;
      });
      
      // 保存评论数据
      await PreferencesUtil.put(MockDataService.COMMENTS_STORAGE_KEY, JSON.stringify(commentsObj));
      
      // 保存评论数数据
      const commentCountObj: Record<string, number> = {};
      MockDataService.newsCommentCount.forEach((value, key) => {
        commentCountObj[key] = value;
      });
      await PreferencesUtil.put(MockDataService.COMMENT_COUNT_STORAGE_KEY, JSON.stringify(commentCountObj));
      
      console.info('MockDataService: 评论数据已保存到本地');
    } catch (error) {
      console.error('MockDataService: 保存评论数据失败', error);
    }
  }

  /**
   * 从本地存储加载评论数据
   */
  static async loadCommentsFromStorage(): Promise<void> {
    try {
      // 加载评论数据
      const commentsStr = await PreferencesUtil.get(MockDataService.COMMENTS_STORAGE_KEY, '{}') as string;
      const commentsObj = JSON.parse(commentsStr) as Record<string, Comment[]>;
      
      // 恢复commentsData
      const commentKeys = Object.keys(commentsObj);
      for (let i = 0; i < commentKeys.length; i++) {
        const key = commentKeys[i];
        MockDataService.commentsData.set(key, commentsObj[key]);
      }
      
      // 加载评论数数据
      const commentCountStr = await PreferencesUtil.get(MockDataService.COMMENT_COUNT_STORAGE_KEY, '{}') as string;
      const commentCountObj = JSON.parse(commentCountStr) as Record<string, number>;
      
      // 恢复newsCommentCount
      const countKeys = Object.keys(commentCountObj);
      for (let i = 0; i < countKeys.length; i++) {
        const key = countKeys[i];
        MockDataService.newsCommentCount.set(key, commentCountObj[key]);
      }
      
      console.info('MockDataService: 评论数据已从本地加载');
    } catch (error) {
      console.error('MockDataService: 加载评论数据失败', error);
    }
  }

  private static getRandomMessageType(): MessageType {
    const types = [MessageType.COMMENT, MessageType.LIKE, MessageType.SYSTEM, MessageType.FOLLOW];
    return types[Math.floor(Math.random() * types.length)];
  }
}
