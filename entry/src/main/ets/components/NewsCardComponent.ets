import { NewsItem, NewsType } from '../models/NewsModel';
import { CommonConstants } from '../common/CommonConstants';


@Component
export struct NewsCardComponent {
  @Prop newsItem: NewsItem;
  @State imageLoadFailed: boolean = false; // 图片加载失败标志
  @State avatarLoadFailed: boolean = false; // 头像加载失败标志
  onCardClick?: (news: NewsItem) => void;
  onLikeClick?: (news: NewsItem) => void;
  onCommentClick?: (news: NewsItem) => void;
  onShareClick?: (news: NewsItem) => void;
  onCollectClick?: (news: NewsItem) => void;
  
  build() {
    Column() {
      // 新闻主体内容
      this.NewsContent()
      
      // 分割线
      Divider()
        .color(CommonConstants.COLORS.DIVIDER)
        .height(0.5)
        .margin({ left: CommonConstants.SPACING.LG })
    }
    .width('100%')
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .padding({
      left: CommonConstants.SPACING.LG,
      right: CommonConstants.SPACING.LG,
      top: CommonConstants.SPACING.MD,
      bottom: CommonConstants.SPACING.MD
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick(this.newsItem);
      }
    })
  }
  
  @Builder
  NewsContent() {
    Column({ space: CommonConstants.SPACING.SM }) {
      // 作者信息
      this.AuthorInfo()
      
      // 根据新闻类型显示不同布局
      if (this.newsItem.type === NewsType.TEXT) {
        // 纯文字新闻
        this.TextContent()
      } else if (this.newsItem.type === NewsType.SINGLE_IMAGE) {
        // 单图新闻
        this.SingleImageContent()
      } else if (this.newsItem.type === NewsType.MULTI_IMAGE) {
        // 多图新闻
        this.MultiImageContent()
      } else if (this.newsItem.type === NewsType.VIDEO) {
        // 视频新闻
        this.VideoContent()
      }
      
      // 互动栏
      this.InteractionBar()
    }
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  AuthorInfo() {
    Row({ space: CommonConstants.SPACING.SM }) {
      // 头像 - 显示用户真实头像
      if (!this.avatarLoadFailed) {
        Image(this.getAuthorAvatar())
          .width(36)
          .height(36)
          .borderRadius(18)
          .objectFit(ImageFit.Cover)
          .onError(() => {
            console.log('NewsCardComponent: 头像加载失败，使用默认头像');
            this.avatarLoadFailed = true;
          })
      } else {
        Image($r('app.media.default_avatar'))
          .width(36)
          .height(36)
          .borderRadius(18)
          .objectFit(ImageFit.Cover)
      }
      
      Column({ space: 2 }) {
        // 昵称
        Row({ space: 4 }) {
          Text(this.newsItem.author.name)
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
          
          if (this.newsItem.author.isVerified) {
            Image($r('app.media.ic_verified'))
              .width(14)
              .height(14)
          }
        }
        
        // 发布时间
        Text(this.newsItem.publishTime)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // 来源
      Text(this.newsItem.source)
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(CommonConstants.COLORS.TEXT_HINT)
    }
    .width('100%')
  }
  
  @Builder
  TextContent() {
    Column({ space: CommonConstants.SPACING.SM }) {
      // 标题
      Text(this.newsItem.title)
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      
      // 摘要
      Text(this.newsItem.summary)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  SingleImageContent() {
    Column({ space: CommonConstants.SPACING.SM }) {
      Row({ space: CommonConstants.SPACING.MD }) {
        // 左侧文字
        Column({ space: CommonConstants.SPACING.SM }) {
          Text(this.newsItem.title)
            .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(this.newsItem.summary)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 右侧图片 - 使用新闻数据中的封面图
        if (this.newsItem.coverImages.length > 0 && !this.imageLoadFailed) {
          Image(this.getNewsImage(0))
            .width(120)
            .height(90)
            .borderRadius(CommonConstants.BORDER_RADIUS.SM)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              console.log('NewsCardComponent: 图片加载失败，使用默认图片');
              this.imageLoadFailed = true;
            })
        } else {
          Image($r('app.media.default_cover'))
            .width(120)
            .height(90)
            .borderRadius(CommonConstants.BORDER_RADIUS.SM)
            .objectFit(ImageFit.Cover)
        }
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  MultiImageContent() {
    Column({ space: CommonConstants.SPACING.SM }) {
      // 标题
      Text(this.newsItem.title)
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      
      // 三图布局 - 使用新闻数据中的封面图
      Row({ space: CommonConstants.SPACING.SM }) {
        ForEach([0, 1, 2], (index: number) => {
          if (index < this.newsItem.coverImages.length && !this.imageLoadFailed) {
            Image(this.getNewsImage(index))
              .layoutWeight(1)
              .height(80)
              .borderRadius(CommonConstants.BORDER_RADIUS.SM)
              .objectFit(ImageFit.Cover)
              .onError(() => {
                this.imageLoadFailed = true;
              })
          } else {
            Image($r('app.media.default_cover'))
              .layoutWeight(1)
              .height(80)
              .borderRadius(CommonConstants.BORDER_RADIUS.SM)
              .objectFit(ImageFit.Cover)
          }
        })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  VideoContent() {
    Column({ space: CommonConstants.SPACING.SM }) {
      // 标题
      Text(this.newsItem.title)
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      
      // 视频封面 - 使用新闻数据中的封面图
      Stack() {
        if (this.newsItem.coverImages.length > 0 && !this.imageLoadFailed) {
          Image(this.getNewsImage(0))
            .width('100%')
            .height(180)
            .borderRadius(CommonConstants.BORDER_RADIUS.MD)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              this.imageLoadFailed = true;
            })
        } else {
          Image($r('app.media.default_cover'))
            .width('100%')
            .height(180)
            .borderRadius(CommonConstants.BORDER_RADIUS.MD)
            .objectFit(ImageFit.Cover)
        }
        
        // 播放按钮
        Image($r('app.media.ic_play'))
          .width(64)
          .height(64)
      }
      .width('100%')
      .height(180)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  InteractionBar() {
    Row({ space: CommonConstants.SPACING.XL }) {
      // 点赞
      Row({ space: 4 }) {
        Image(this.newsItem.isLiked ? $r('app.media.ic_like_active') : $r('app.media.ic_like'))
          .width(20)
          .height(20)
        
        Text(this.formatCount(this.newsItem.likeCount))
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      }
      .onClick(() => {
        if (this.onLikeClick) {
          this.onLikeClick(this.newsItem);
        }
      })
      
      // 评论
      Row({ space: 4 }) {
        Image($r('app.media.ic_comment'))
          .width(20)
          .height(20)
        
        Text(this.formatCount(this.newsItem.commentCount))
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      }
      .onClick(() => {
        if (this.onCommentClick) {
          this.onCommentClick(this.newsItem);
        }
      })
      
      // 分享
      Row({ space: 4 }) {
        Image($r('app.media.ic_share'))
          .width(20)
          .height(20)
        
        Text(this.formatCount(this.newsItem.shareCount))
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      }
      .onClick(() => {
        if (this.onShareClick) {
          this.onShareClick(this.newsItem);
        }
      })
      
      // 收藏
      Row({ space: 4 }) {
        Image(this.newsItem.isCollected ? $r('app.media.ic_star_active') : $r('app.media.ic_star'))
          .width(20)
          .height(20)
        
        Text(this.formatCount(this.newsItem.collectCount))
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      }
      .onClick(() => {
        if (this.onCollectClick) {
          this.onCollectClick(this.newsItem);
        }
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }
  
  // ==================== 辅助方法 ====================
  
  /**
   * 获取作者头像
   * 处理资源引用和网络URL
   */
  private getAuthorAvatar(): Resource | string {
    const avatarPath = this.newsItem.author.avatar;
    // 如果是资源引用格式 (app.media.xxx)，转换为 Resource
    if (avatarPath.startsWith('app.media.')) {
      const resourceName = avatarPath.replace('app.media.', '');
      return $r(`app.media.${resourceName}`);
    }
    // 否则直接返回路径（网络URL或本地路径）
    return avatarPath;
  }
  
  /**
   * 获取新闻封面图片
   * 根据索引从 coverImages 数组中获取对应的图片资源
   */
  private getNewsImage(index: number): Resource | string {
    if (this.newsItem.coverImages.length > index) {
      const imagePath = this.newsItem.coverImages[index];
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
  
  private formatCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    }
    return count.toString();
  }
}
