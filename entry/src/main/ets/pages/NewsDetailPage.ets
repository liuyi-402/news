import { NewsItem, Comment } from '../models/NewsModel';
import { MockDataService } from '../services/MockDataService';
import { CommonConstants } from '../common/CommonConstants';
import router from '@ohos.router';

/**
 * 新闻详情页
 * 复刻微博详情页样式
 */
@Entry
@Component
struct NewsDetailPage {
  @Prop newsId: string = '';
  @State newsItem: NewsItem | null = null;
  @State commentList: Comment[] = [];
  @State commentText: string = '';
  @State fontSize: number = CommonConstants.FONT_SIZE.BODY;
  @State isNightMode: boolean = false;
  @State showMoreMenu: boolean = false;

  aboutToAppear() {
    this.loadNewsDetail();
  }

  build() {
    Column() {
      // 顶部栏
      this.HeaderBar()

      // 内容区域
      Scroll() {
        Column({ space: CommonConstants.SPACING.MD }) {
          if (this.newsItem) {
            // 新闻标题
            this.NewsTitle()

            // 发布信息
            this.PublishInfo()

            // 新闻正文
            this.NewsContent()

            // 分割线
            Divider()
              .color(CommonConstants.COLORS.DIVIDER)
              .margin({ top: CommonConstants.SPACING.LG, bottom: CommonConstants.SPACING.LG })

            // 评论区
            this.CommentSection()
          }
        }
        .width('100%')
        .padding(CommonConstants.SPACING.LG)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)

      // 底部评论输入栏
      this.CommentInputBar()

      // 更多菜单
      if (this.showMoreMenu) {
        this.MoreMenu()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isNightMode ? '#FF1A1A1A' : CommonConstants.COLORS.WHITE)
  }

  @Builder
  HeaderBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 返回按钮
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.onBack();
        })

      Blank()
        .layoutWeight(1)

      // 更多按钮
      Image($r('app.media.ic_more'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.showMoreMenu = !this.showMoreMenu;
        })
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(this.isNightMode ? '#FF2A2A2A' : CommonConstants.COLORS.WHITE)
  }

  @Builder
  NewsTitle() {
    Text(this.newsItem?.title || '')
      .fontSize(CommonConstants.FONT_SIZE.TITLE)
      .fontColor(this.isNightMode ? CommonConstants.COLORS.WHITE : CommonConstants.COLORS.TEXT_PRIMARY)
      .fontWeight(FontWeight.Bold)
      .lineHeight(28)
      .width('100%')
  }

  @Builder
  PublishInfo() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 作者头像
      Image(this.newsItem?.author.avatar || $r('app.media.default_avatar'))
        .width(36)
        .height(36)
        .borderRadius(18)
        .objectFit(ImageFit.Cover)

      Column({ space: 2 }) {
        // 作者昵称
        Text(this.newsItem?.author.name || '')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(this.isNightMode ? CommonConstants.COLORS.WHITE : CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)

        // 发布时间和来源
        Text(`${this.newsItem?.publishTime || ''} · ${this.newsItem?.source || ''}`)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 关注按钮
      Button('关注')
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(CommonConstants.COLORS.WHITE)
        .backgroundColor(CommonConstants.COLORS.PRIMARY)
        .borderRadius(CommonConstants.BORDER_RADIUS.ROUND)
        .height(28)
        .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .margin({ top: CommonConstants.SPACING.MD })
  }

  @Builder
  NewsContent() {
    Column({ space: CommonConstants.SPACING.LG }) {
      // 正文内容
      Text(this.newsItem?.content || '')
        .fontSize(this.fontSize)
        .fontColor(this.isNightMode ? '#FFE0E0E0' : CommonConstants.COLORS.TEXT_PRIMARY)
        .lineHeight(this.fontSize * 1.8)
        .width('100%')

      // 阅读数
      Row({ space: CommonConstants.SPACING.XL }) {
        Text(`阅读 ${this.formatCount(this.newsItem?.readCount || 0)}`)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)

        Text(`评论 ${this.formatCount(this.newsItem?.commentCount || 0)}`)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .margin({ top: CommonConstants.SPACING.LG })
  }

  @Builder
  CommentSection() {
    Column({ space: CommonConstants.SPACING.MD }) {
      // 评论标题
      Row({ space: CommonConstants.SPACING.SM }) {
        Text('评论')
          .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
          .fontColor(this.isNightMode ? CommonConstants.COLORS.WHITE : CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        Text(`(${this.commentList.length})`)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      }
      .width('100%')

      // 评论列表
      if (this.commentList.length > 0) {
        Column({ space: CommonConstants.SPACING.LG }) {
          ForEach(this.commentList, (comment: Comment) => {
            this.CommentItem(comment)
          })
        }
        .width('100%')
      } else {
        // 暂无评论
        Column() {
          Image($r('app.media.ic_empty_comment'))
            .width(80)
            .height(80)
            .opacity(0.5)

          Text('暂无评论，快来抢沙发吧~')
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
            .margin({ top: CommonConstants.SPACING.MD })
        }
        .width('100%')
        .height(150)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CommentItem(comment: Comment) {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 评论者头像
      Image(comment.author.avatar)
        .width(40)
        .height(40)
        .borderRadius(20)
        .objectFit(ImageFit.Cover)

      Column({ space: CommonConstants.SPACING.SM }) {
        // 评论者昵称和时间
        Row({ space: 8 }) {
          Text(comment.author.name)
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(this.isNightMode ? CommonConstants.COLORS.WHITE : CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)

          Text(comment.publishTime)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }
        .width('100%')

        // 评论内容
        Text(comment.content)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(this.isNightMode ? '#FFE0E0E0' : CommonConstants.COLORS.TEXT_SECONDARY)
          .lineHeight(20)

        // 互动按钮
        Row({ space: CommonConstants.SPACING.XL }) {
          // 点赞
          Row({ space: 4 }) {
            Image(comment.isLiked ? $r('app.media.ic_like_active') : $r('app.media.ic_like'))
              .width(16)
              .height(16)

            Text(this.formatCount(comment.likeCount))
              .fontSize(CommonConstants.FONT_SIZE.CAPTION)
              .fontColor(comment.isLiked ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
          }
          .onClick(() => {
            this.toggleCommentLike(comment);
          })

          // 回复
          Row({ space: 4 }) {
            Image($r('app.media.ic_comment'))
              .width(16)
              .height(16)

            Text(this.formatCount(comment.replyCount))
              .fontSize(CommonConstants.FONT_SIZE.CAPTION)
              .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  CommentInputBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 点赞按钮
      Row({ space: 4 }) {
        Image(this.newsItem?.isLiked ? $r('app.media.ic_like_active') : $r('app.media.ic_like'))
          .width(20)
          .height(20)
        
        Text(this.formatCount(this.newsItem?.likeCount || 0))
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(this.newsItem?.isLiked ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
      }
      .onClick(() => {
        this.toggleNewsLike();
      })

      // 评论按钮
      Row({ space: 4 }) {
        Image($r('app.media.ic_comment'))
          .width(20)
          .height(20)
        
        Text(this.formatCount(this.commentList.length))
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      }

      // 分享按钮
      Row({ space: 4 }) {
        Image($r('app.media.ic_share'))
          .width(20)
          .height(20)
        
        Text(this.formatCount(this.newsItem?.shareCount || 0))
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      }
      .onClick(() => {
        this.onShare();
      })

      Blank()
        .layoutWeight(1)

      // 评论输入框
      TextInput({ placeholder: '说点什么...', text: this.commentText })
        .width(180)
        .height(36)
        .backgroundColor(this.isNightMode ? '#FF2A2A2A' : '#FFF5F5F5')
        .borderRadius(18)
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(this.isNightMode ? CommonConstants.COLORS.WHITE : CommonConstants.COLORS.TEXT_PRIMARY)
        .placeholderColor(CommonConstants.COLORS.TEXT_HINT)
        .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD })
        .onChange((value: string) => {
          this.commentText = value;
        })

      // 发送按钮
      Button('发送')
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(CommonConstants.COLORS.WHITE)
        .backgroundColor(this.commentText.trim().length > 0 ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_HINT)
        .borderRadius(18)
        .height(36)
        .padding({ left: 16, right: 16 })
        .enabled(this.commentText.trim().length > 0)
        .onClick(() => {
          this.sendComment();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(this.isNightMode ? '#FF2A2A2A' : CommonConstants.COLORS.WHITE)
    .border({ width: { top: 0.5 }, color: { top: CommonConstants.COLORS.DIVIDER } })
  }

  @Builder
  MoreMenu() {
    Column() {
      Column({ space: 0 }) {
        // 复制链接
        this.MenuItem('复制链接', $r('app.media.ic_copy'), () => {
          this.copyLink();
        })

        Divider().color(CommonConstants.COLORS.DIVIDER)

        // 举报
        this.MenuItem('举报', $r('app.media.ic_report'), () => {
          this.reportNews();
        })

        Divider().color(CommonConstants.COLORS.DIVIDER)

        // 字体大小
        this.MenuItem('字体大小', $r('app.media.ic_font'), () => {
          this.adjustFontSize();
        })

        Divider().color(CommonConstants.COLORS.DIVIDER)

        // 夜间模式
        this.MenuItem(this.isNightMode ? '日间模式' : '夜间模式', $r('app.media.ic_night_mode'), () => {
          this.toggleNightMode();
        })
      }
      .width('100%')
      .backgroundColor(CommonConstants.COLORS.WHITE)
      .borderRadius(CommonConstants.BORDER_RADIUS.LG)
      .padding(CommonConstants.SPACING.SM)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .justifyContent(FlexAlign.End)
    .padding(CommonConstants.SPACING.LG)
    .onClick(() => {
      this.showMoreMenu = false;
    })
  }

  @Builder
  MenuItem(title: string, icon: Resource, onClick: () => void) {
    Row({ space: CommonConstants.SPACING.MD }) {
      Image(icon)
        .width(20)
        .height(20)

      Text(title)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .layoutWeight(1)
    }
    .width('100%')
    .height(48)
    .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD })
    .onClick(() => onClick())
  }

  // ==================== 事件处理 ====================
  // 【已修复】优先使用传递的新闻对象，确保详情页内容和列表页一致
  private loadNewsDetail() {
    // 尝试从路由参数中获取完整的新闻对象
    const params = router.getParams() as Record<string, Object>;
    if (params && params['newsItem']) {
      // 如果传递了完整的新闻对象，直接使用
      this.newsItem = params['newsItem'] as NewsItem;
      console.log('NewsDetailPage: 使用传递的新闻对象');
    } else {
      // 如果没有传递新闻对象，则根据 newsId 查找（兼容旧逻辑）
      console.log('NewsDetailPage: 根据 newsId 查找新闻');
      const allCategories = ['要闻', '财经', '娱乐', '体育', '科技', '社会', '国际', '军事', '教育', '健康'];
      let foundNews: NewsItem | undefined = undefined;
      
      // 遍历所有分类查找对应的新闻
      for (const category of allCategories) {
        const newsList = MockDataService.getNewsList(category, 1);
        foundNews = newsList.find(item => item.id === this.newsId);
        if (foundNews) {
          break; // 找到后立即退出循环
        }
      }
      
      // 如果没找到，使用默认第一条新闻
      if (!foundNews) {
        const defaultList = MockDataService.getNewsList();
        foundNews = defaultList[0];
      }
      
      this.newsItem = foundNews;
    }
    
    // 应用点赞状态
    if (this.newsItem) {
      const isLiked = MockDataService.getNewsLikeStatus(this.newsItem.id);
      const news = this.newsItem;
      this.newsItem = {
        id: news.id,
        title: news.title,
        summary: news.summary,
        content: news.content,
        coverImages: news.coverImages,
        category: news.category,
        source: news.source,
        author: news.author,
        publishTime: news.publishTime,
        readCount: news.readCount,
        likeCount: news.likeCount,
        commentCount: news.commentCount,
        shareCount: news.shareCount,
        collectCount: news.collectCount,
        isLiked: isLiked,
        isCollected: news.isCollected,
        isRead: news.isRead,
        type: news.type,
        videoUrl: news.videoUrl
      };
    }
    
    // 加载对应评论（带状态）
    this.commentList = MockDataService.getCommentsWithStatus(this.newsId);
  }

  /**
   * 切换新闻点赞状态
   */
  private toggleNewsLike() {
    if (!this.newsItem) return;
    
    const result = MockDataService.toggleNewsLike(this.newsItem.id, this.newsItem.likeCount);
    const news = this.newsItem;
    
    // 更新新闻对象
    this.newsItem = {
      id: news.id,
      title: news.title,
      summary: news.summary,
      content: news.content,
      coverImages: news.coverImages,
      category: news.category,
      source: news.source,
      author: news.author,
      publishTime: news.publishTime,
      readCount: news.readCount,
      likeCount: result.likeCount,
      commentCount: news.commentCount,
      shareCount: news.shareCount,
      collectCount: news.collectCount,
      isLiked: result.isLiked,
      isCollected: news.isCollected,
      isRead: news.isRead,
      type: news.type,
      videoUrl: news.videoUrl
    };
    
    // 通知封面页更新点赞状态
    MockDataService.notifyNewsLikeChanged();
    
    console.log(`新闻点赞状态: ${result.isLiked ? '已点赞' : '取消点赞'}, 点赞数: ${result.likeCount}`);
  }

  /**
   * 切换评论点赞状态
   */
  private toggleCommentLike(comment: Comment) {
    const result = MockDataService.toggleCommentLike(comment.id, comment.likeCount);
    
    // 更新评论列表
    const updatedList: Comment[] = [];
    for (let i = 0; i < this.commentList.length; i++) {
      const c = this.commentList[i];
      if (c.id === comment.id) {
        const updatedComment: Comment = {
          id: c.id,
          newsId: c.newsId,
          author: c.author,
          content: c.content,
          publishTime: c.publishTime,
          likeCount: result.likeCount,
          replyCount: c.replyCount,
          isLiked: result.isLiked,
          replies: c.replies
        };
        updatedList.push(updatedComment);
      } else {
        updatedList.push(c);
      }
    }
    this.commentList = updatedList;
    
    console.log(`评论点赞状态: ${result.isLiked ? '已点赞' : '取消点赞'}, 点赞数: ${result.likeCount}`);
  }

  private formatCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    }
    return count.toString();
  }

  private onBack() {
    router.back();
  }

  private onShare() {
    // TODO: 显示分享菜单
    console.log('分享新闻');
  }

  /**
   * 发送评论
   */
  private sendComment() {
    if (this.commentText.trim().length > 0 && this.newsItem) {
      // 添加评论
      const newComment = MockDataService.addComment(this.newsItem.id, this.commentText.trim());
      
      // 更新评论列表（将新评论添加到开头）
      const updatedList: Comment[] = [newComment];
      for (let i = 0; i < this.commentList.length; i++) {
        updatedList.push(this.commentList[i]);
      }
      this.commentList = updatedList;
      
      // 更新新闻的评论数
      if (this.newsItem) {
        const news = this.newsItem;
        this.newsItem = {
          id: news.id,
          title: news.title,
          summary: news.summary,
          content: news.content,
          coverImages: news.coverImages,
          category: news.category,
          source: news.source,
          author: news.author,
          publishTime: news.publishTime,
          readCount: news.readCount,
          likeCount: news.likeCount,
          commentCount: news.commentCount + 1,
          shareCount: news.shareCount,
          collectCount: news.collectCount,
          isLiked: news.isLiked,
          isCollected: news.isCollected,
          isRead: news.isRead,
          type: news.type,
          videoUrl: news.videoUrl
        };
      }
      
      console.log(`发送评论成功: ${this.commentText}`);
      
      // 清空输入框
      this.commentText = '';
    }
  }

  private copyLink() {
    // TODO: 复制链接到剪贴板
    console.log('复制链接');
    this.showMoreMenu = false;
  }

  private reportNews() {
    // TODO: 举报新闻
    console.log('举报新闻');
    this.showMoreMenu = false;
  }

  private adjustFontSize() {
    // 循环调整字体大小
    const sizes = [12, 14, 16, 18];
    const currentIndex = sizes.indexOf(this.fontSize);
    const nextIndex = (currentIndex + 1) % sizes.length;
    this.fontSize = sizes[nextIndex];
    this.showMoreMenu = false;
  }

  private toggleNightMode() {
    this.isNightMode = !this.isNightMode;
    this.showMoreMenu = false;
  }
}