// 新闻卡片组件
import { NewsItem, NewsType } from '../models/NewsModel'

@Component
export struct NewsCard {
  @Prop newsItem: NewsItem | null = null
  onLike?: (newsId: string) => void
  onComment?: (newsId: string) => void
  onShare?: (newsId: string) => void
  onCollect?: (newsId: string) => void

  build() {
    if (this.newsItem) {
      Column() {
        // 用户信息行
        this.UserInfoRow()

        // 内容区域
        this.ContentArea()

        // 互动按钮行
        this.InteractionBar()

        // 分割线
        Column()
          .width('100%')
          .height(8)
          .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
  }

  // 用户信息行
  @Builder
  UserInfoRow() {
    Row() {
      // 用户头像
      Image(this.newsItem?.author.avatar)
        .width(40)
        .height(40)
        .borderRadius(20)
        .objectFit(ImageFit.Cover)

      Column() {
        Row() {
          // 用户名
          Text(this.newsItem?.author.name || '')
            .fontSize(15)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)

          // 认证标识
          if (this.newsItem?.author.isVerified) {
            Text('✓')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF6B6B')
              .borderRadius(8)
              .padding({ left: 4, right: 4, top: 1, bottom: 1 })
              .margin({ left: 6 })
          }
        }

        // 发布时间和来源
        Row() {
          Text(this.newsItem?.publishTime || '')
            .fontSize(12)
            .fontColor('#999999')

          Text(' · ')
            .fontSize(12)
            .fontColor('#999999')

          Text(this.newsItem?.source || '')
            .fontSize(12)
            .fontColor('#999999')
        }
        .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      // 关注按钮
      Button('关注')
        .fontSize(13)
        .fontColor('#FF6B6B')
        .backgroundColor('#FFE5E5')
        .borderRadius(15)
        .height(28)
        .padding({ left: 12, right: 12 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  // 内容区域
  @Builder
  ContentArea() {
    Column() {
      // 新闻标题
      Text(this.newsItem?.title || '')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .lineHeight(22)
        .margin({ top: 12 })
        .width('100%')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 新闻摘要
      Text(this.newsItem?.summary || '')
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(20)
        .margin({ top: 8 })
        .width('100%')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 根据类型显示不同内容
      if (this.newsItem?.type === NewsType.SINGLE_IMAGE || this.newsItem?.type === NewsType.MULTI_IMAGE) {
        // 图文新闻 - 图片网格
        this.ImageGrid()
      } else if (this.newsItem?.type === NewsType.VIDEO) {
        // 视频新闻 - 视频封面
        this.VideoCover()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 图片网格
  @Builder
  ImageGrid() {
    if (this.newsItem?.coverImages && this.newsItem.coverImages.length > 0) {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.newsItem.coverImages, (image: string, index: number) => {
          Image(this.getImageResource(image))
            .width(this.newsItem?.coverImages?.length === 1 ? '100%' : '32%')
            .height(this.newsItem?.coverImages?.length === 1 ? 200 : 100)
            .objectFit(ImageFit.Cover)
            .borderRadius(4)
            .margin({ top: 8, right: index % 3 !== 2 ? '2%' : 0 })
        }, (image: string) => image)
      }
      .width('100%')
      .margin({ top: 8 })
    }
  }

  // 视频封面
  @Builder
  VideoCover() {
    Stack() {
      if (this.newsItem?.coverImages && this.newsItem.coverImages.length > 0) {
        Image(this.getImageResource(this.newsItem.coverImages[0]))
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
      }

      // 播放按钮
      Column() {
        Text('▶')
          .fontSize(32)
          .fontColor('#FFFFFF')
      }
      .width(60)
      .height(60)
      .backgroundColor('rgba(0,0,0,0.5)')
      .borderRadius(30)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(200)
    .margin({ top: 12 })
  }

  // 互动按钮行
  @Builder
  InteractionBar() {
    Row() {
      // 转发
      this.InteractionButton('🔄', this.newsItem?.shareCount || 0, () => {
        if (this.onShare && this.newsItem) {
          this.onShare(this.newsItem.id)
        }
      })

      Blank()

      // 评论
      this.InteractionButton('💬', this.newsItem?.commentCount || 0, () => {
        if (this.onComment && this.newsItem) {
          this.onComment(this.newsItem.id)
        }
      })

      Blank()

      // 点赞
      Row() {
        Text(this.newsItem?.isLiked ? '❤️' : '🤍')
          .fontSize(18)

        Text(this.formatNumber(this.newsItem?.likeCount || 0))
          .fontSize(14)
          .fontColor(this.newsItem?.isLiked ? '#FF6B6B' : '#999999')
          .margin({ left: 6 })
      }
      .onClick(() => {
        if (this.onLike && this.newsItem) {
          this.onLike(this.newsItem.id)
        }
      })
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })

      Blank()

      // 收藏
      Row() {
        Text(this.newsItem?.isCollected ? '⭐' : '☆')
          .fontSize(18)

        Text(this.formatNumber(this.newsItem?.collectCount || 0))
          .fontSize(14)
          .fontColor('#999999')
          .margin({ left: 6 })
      }
      .onClick(() => {
        if (this.onCollect && this.newsItem) {
          this.onCollect(this.newsItem.id)
        }
      })
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    }
    .width('100%')
    .margin({ top: 12 })
  }

  // 互动按钮组件
  @Builder
  InteractionButton(icon: string, count: number, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(18)

      Text(this.formatNumber(count))
        .fontSize(14)
        .fontColor('#999999')
        .margin({ left: 6 })
    }
    .onClick(onClick)
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
  }

  // 获取图片资源
  private getImageResource(imagePath: string): Resource | string {
    if (imagePath.startsWith('app.media.')) {
      const resourceName = imagePath.replace('app.media.', '');
      return $r(`app.media.${resourceName}`);
    }
    return imagePath;
  }

  // 格式化数字
  private formatNumber(num: number): string {
    if (num >= 10000) {
      return `${(num / 10000).toFixed(1)}万`
    }
    return num.toString()
  }
}
