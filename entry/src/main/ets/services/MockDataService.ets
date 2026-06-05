import { NewsItem, NewsType, AuthorInfo, HotSearch, Topic, Message, MessageType, Comment, UserInfo } from '../models/NewsModel';

/**
 * Mock数据服务
 */
export class MockDataService {
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

      newsList.push({
        id: `news_${newsCategory}_${index}`,
        title: MockDataService.getMockTitle(index, newsCategory),
        summary: MockDataService.getMockSummary(index, newsCategory),
        content: MockDataService.getMockContent(index, newsCategory),
        coverImages: MockDataService.getMockCoverImages(newsType, newsCategory, index),
        category: newsCategory,
        source: MockDataService.getMockSource(),
        author: MockDataService.getMockAuthor(),
        publishTime: MockDataService.getMockTime(index),
        readCount: Math.floor(Math.random() * 100000),
        likeCount: Math.floor(Math.random() * 10000),
        commentCount: Math.floor(Math.random() * 1000),
        shareCount: Math.floor(Math.random() * 500),
        collectCount: Math.floor(Math.random() * 300),
        isLiked: false,
        isCollected: false,
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
        isFollowed: false
      },
      {
        id: 'topic_2',
        name: '财经投资',
        description: '分享投资理财经验',
        cover: 'https://picsum.photos/400/300?random=202',
        followCount: 98000,
        newsCount: 2450,
        isFollowed: false
      },
      {
        id: 'topic_3',
        name: '体育竞技',
        description: '关注体育赛事动态',
        cover: 'https://picsum.photos/400/300?random=203',
        followCount: 156000,
        newsCount: 4200,
        isFollowed: true
      },
      {
        id: 'topic_4',
        name: '娱乐明星',
        description: '娱乐圈最新资讯',
        cover: 'https://picsum.photos/400/300?random=204',
        followCount: 210000,
        newsCount: 5600,
        isFollowed: false
      }
    ];
  }

  /**
   * 根据话题获取新闻
   */
  static getNewsByTopic(topicId: string): NewsItem[] {
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
    return `${MockDataService.getMockTitle(index, category)}。这是新闻的详细摘要内容。`;
  }

  private static getMockContent(index: number, category: string): string {
    return `${MockDataService.getMockTitle(index, category)}。\n\n这是新闻的详细内容。根据最新消息，相关方面已经采取了一系列措施。\n\n专家表示，这一发展具有重要意义。`;
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

  private static getRandomMessageType(): MessageType {
    const types = [MessageType.COMMENT, MessageType.LIKE, MessageType.SYSTEM, MessageType.FOLLOW];
    return types[Math.floor(Math.random() * types.length)];
  }
}
