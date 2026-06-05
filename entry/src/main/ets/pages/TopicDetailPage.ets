import { Topic, NewsItem } from '../models/NewsModel';
import { MockDataService } from '../services/MockDataService';
import { CommonConstants } from '../common/CommonConstants';
import router from '@ohos.router';

/**
 * 专题详情页 - 展示专题信息和相关文章列表
 */
@Entry
@Component
struct TopicDetailPage {
  @State topic: Topic | null = null;
  @State newsList: NewsItem[] = [];
  @State isLoading: boolean = true;
  @State isFollowed: boolean = false;
  @State topicCoverLoadFailed: boolean = false; // 专题封面加载失败标志
  @State newsImageLoadFailed: Map<string, boolean> = new Map(); // 新闻图片加载失败标志

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params['topicId']) {
      const topicId = params['topicId'] as string;
      this.loadTopicData(topicId);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopBar()

      if (this.isLoading) {
        // 加载状态
        this.LoadingView()
      } else if (this.topic) {
        // 内容区域
        Scroll() {
          Column({ space: CommonConstants.SPACING.MD }) {
            // 专题信息卡片
            this.TopicInfoCard()

            // 文章列表
            this.NewsListSection()
          }
          .width('100%')
          .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD, bottom: CommonConstants.SPACING.XXL })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .friction(0.6)
      } else {
        // 错误状态
        this.ErrorView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.BACKGROUND)
  }

  @Builder
  TopBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 返回按钮
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .onClick(() => {
          router.back();
        })

      // 标题
      Text(this.topic?.name || '专题详情')
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(CommonConstants.COLORS.PRIMARY)

      Text('加载中...')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        .margin({ top: CommonConstants.SPACING.MD })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ErrorView() {
    Column() {
      Image($r('app.media.ic_close'))
        .width(64)
        .height(64)

      Text('专题不存在')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        .margin({ top: CommonConstants.SPACING.MD })

      Button('返回')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.WHITE)
        .backgroundColor(CommonConstants.COLORS.PRIMARY)
        .borderRadius(CommonConstants.BORDER_RADIUS.MD)
        .margin({ top: CommonConstants.SPACING.LG })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  TopicInfoCard() {
    Column({ space: CommonConstants.SPACING.MD }) {
      // 封面图 - 使用网络图片
      if (!this.topicCoverLoadFailed && this.topic?.cover) {
        Image(this.topic.cover)
          .width('100%')
          .height(180)
          .borderRadius(CommonConstants.BORDER_RADIUS.MD)
          .objectFit(ImageFit.Cover)
          .onError(() => {
            console.log('TopicDetailPage: 专题封面加载失败，使用默认图片');
            this.topicCoverLoadFailed = true;
          })
      } else {
        Image($r('app.media.default_cover'))
          .width('100%')
          .height(180)
          .borderRadius(CommonConstants.BORDER_RADIUS.MD)
          .objectFit(ImageFit.Cover)
      }

      // 专题名称
      Text(this.topic?.name || '')
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)

      // 描述
      Text(this.topic?.description || '')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        .width('100%')

      // 统计信息和关注按钮
      Row({ space: CommonConstants.SPACING.XL }) {
        // 关注数
        Column({ space: 2 }) {
          Text(this.formatCount(this.topic?.followCount || 0))
            .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
          Text('关注')
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        }

        // 文章数
        Column({ space: 2 }) {
          Text(this.formatCount(this.topic?.newsCount || 0))
            .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
          Text('文章')
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        }

        Blank()
          .layoutWeight(1)

        // 关注按钮
        Button(this.isFollowed ? '已关注' : '+ 关注')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(this.isFollowed ? CommonConstants.COLORS.TEXT_SECONDARY : CommonConstants.COLORS.WHITE)
          .backgroundColor(this.isFollowed ? CommonConstants.COLORS.BACKGROUND : CommonConstants.COLORS.PRIMARY)
          .borderRadius(CommonConstants.BORDER_RADIUS.ROUND)
          .height(36)
          .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
          .onClick(() => {
            this.toggleFollow();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(CommonConstants.SPACING.LG)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .borderRadius(CommonConstants.BORDER_RADIUS.MD)
  }

  @Builder
  NewsListSection() {
    Column() {
      // 标题栏
      Row({ space: CommonConstants.SPACING.SM }) {
        Image($r('app.media.ic_recommend'))
          .width(20)
          .height(20)

        Text('相关文章')
          .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Text(`共${this.newsList.length}篇`)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      }
      .width('100%')
      .padding(CommonConstants.SPACING.MD)

      // 文章列表
      Column({ space: 0 }) {
        ForEach(this.newsList, (news: NewsItem) => {
          this.NewsItemCard(news)
        })
      }
    }
    .width('100%')
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .borderRadius(CommonConstants.BORDER_RADIUS.MD)
    .margin({ top: CommonConstants.SPACING.MD })
  }

  @Builder
  NewsItemCard(news: NewsItem) {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 文字信息
      Column({ space: CommonConstants.SPACING.SM }) {
        // 标题
        Text(news.title)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 来源和时间
        Row({ space: CommonConstants.SPACING.SM }) {
          Text(news.source)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)

          Text(this.formatTime(news.publishTime))
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }

        // 统计数据
        Row({ space: CommonConstants.SPACING.MD }) {
          Text(`${this.formatCount(news.readCount)}阅读`)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)

          Text(`${news.commentCount}评论`)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 封面图 - 使用网络图片
      if (news.coverImages.length > 0 && !this.newsImageLoadFailed.get(news.id)) {
        Image(this.getNewsImage(news))
          .width(100)
          .height(75)
          .borderRadius(CommonConstants.BORDER_RADIUS.SM)
          .objectFit(ImageFit.Cover)
          .onError(() => {
            console.log('TopicDetailPage: 新闻图片加载失败，使用默认图片');
            this.newsImageLoadFailed.set(news.id, true);
          })
      } else if (news.coverImages.length > 0) {
        Image($r('app.media.default_cover'))
          .width(100)
          .height(75)
          .borderRadius(CommonConstants.BORDER_RADIUS.SM)
          .objectFit(ImageFit.Cover)
      }
    }
    .width('100%')
    .padding(CommonConstants.SPACING.MD)
    .onClick(() => {
      this.onNewsClick(news);
    })
  }

  // ==================== 事件处理 ====================

  /**
   * 加载专题数据
   */
  private loadTopicData(topicId: string) {
    this.isLoading = true;

    // 获取专题信息
    const topics = MockDataService.getTopicList();
    this.topic = topics.find((t: Topic) => t.id === topicId) || null;

    if (this.topic) {
      this.isFollowed = this.topic.isFollowed;
      // 获取专题相关文章
      this.newsList = MockDataService.getNewsByTopic(topicId);
    }

    this.isLoading = false;
  }

  /**
   * 切换关注状态
   */
  private toggleFollow() {
    this.isFollowed = !this.isFollowed;
    console.log(`专题 ${this.topic?.name} ${this.isFollowed ? '已关注' : '取消关注'}`);
  }

  /**
   * 点击文章，跳转到文章详情页
   */
  private onNewsClick(news: NewsItem) {
    console.log('TopicDetailPage: 点击文章:', news.title);
    router.pushUrl({
      url: 'pages/NewsDetailPage',
      params: {
        newsId: news.id
      }
    }).then(() => {
      console.log('TopicDetailPage: 跳转到文章详情页成功');
    }).catch((error: Error) => {
      console.error('TopicDetailPage: 跳转到文章详情页失败:', error.message);
    });
  }

  /**
   * 格式化数量
   */
  private formatCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    }
    return count.toString();
  }

  /**
   * 格式化时间
   */
  private formatTime(time: string): string {
    // 简化时间显示，只显示日期
    if (time && time.length >= 10) {
      return time.substring(0, 10);
    }
    return time;
  }

  /**
   * 获取新闻封面图片
   */
  private getNewsImage(news: NewsItem): Resource | string {
    if (news.coverImages.length > 0) {
      const imagePath = news.coverImages[0];
      // 如果是资源引用格式 (app.media.xxx)，转换为 Resource
      if (imagePath.startsWith('app.media.')) {
        const resourceName = imagePath.replace('app.media.', '');
        return $r(`app.media.${resourceName}`);
      }
      // 否则直接返回路径（网络URL或本地路径）
      return imagePath;
    }
    return $r('app.media.default_cover');
  }
}
