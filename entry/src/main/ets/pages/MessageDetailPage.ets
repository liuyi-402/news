import { Message, MessageType } from '../models/NewsModel';
import { CommonConstants } from '../common/CommonConstants';
import router from '@ohos.router';

/**
 * 通知详情页 - 点赞、评论、收藏、系统通知
 * 参考抖音通知详情样式
 */
@Entry
@Component
struct MessageDetailPage {
  @State message: Message | null = null;
  @State avatarLoadFailed: boolean = false;

  aboutToAppear() {
    // 从路由参数获取消息数据
    const params = router.getParams() as Record<string, Object>;
    if (params && params['message']) {
      this.message = params['message'] as Message;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderBar()

      if (this.message) {
        // 通知详情内容
        Scroll() {
          Column() {
            // 通知头部
            this.NotificationHeader()

            // 分割线
            Divider()
              .color(CommonConstants.COLORS.DIVIDER)
              .margin({ top: CommonConstants.SPACING.LG, bottom: CommonConstants.SPACING.LG })

            // 通知内容
            this.NotificationContent()

            // 相关内容卡片
            if (this.message!.type !== MessageType.SYSTEM) {
              this.RelatedContentCard()
            }
          }
          .width('100%')
          .padding(CommonConstants.SPACING.LG)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else {
        // 空状态
        Column() {
          Text('通知不存在')
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.BACKGROUND)
  }

  @Builder
  HeaderBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 返回按钮
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .onClick(() => {
          router.back();
        })

      Text(this.getPageTitle())
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }

  @Builder
  NotificationHeader() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 用户头像或系统图标
      if (this.message!.sender) {
        if (!this.avatarLoadFailed) {
          Image(this.message!.sender!.avatar)
            .width(50)
            .height(50)
            .borderRadius(25)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              this.avatarLoadFailed = true;
            })
        } else {
          Image($r('app.media.default_avatar'))
            .width(50)
            .height(50)
            .borderRadius(25)
            .objectFit(ImageFit.Cover)
        }
      } else {
        Column() {
          Image(this.getMessageIcon(this.message!.type))
            .width(28)
            .height(28)
        }
        .width(50)
        .height(50)
        .borderRadius(25)
        .backgroundColor(this.getMessageIconBgColor(this.message!.type))
        .justifyContent(FlexAlign.Center)
      }

      // 用户信息和时间
      Column({ space: 6 }) {
        Text(this.message!.sender?.name || this.getMessageTitle(this.message!.type))
          .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        Text(this.message!.createTime)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  NotificationContent() {
    Column({ space: CommonConstants.SPACING.MD }) {
      // 通知内容
      Text(this.message!.content)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RelatedContentCard() {
    Column({ space: CommonConstants.SPACING.MD }) {
      // 相关内容标题
      Text('相关内容')
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      // 内容卡片
      Row({ space: CommonConstants.SPACING.MD }) {
        // 封面图
        Image('https://picsum.photos/200/200?random=500')
          .width(80)
          .height(80)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        // 内容信息
        Column({ space: 6 }) {
          Text('这是相关内容的标题')
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text('点击查看详情')
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.PRIMARY)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(CommonConstants.SPACING.MD)
      .backgroundColor(CommonConstants.COLORS.WHITE)
      .borderRadius(CommonConstants.BORDER_RADIUS.MD)
      .onClick(() => {
        this.viewRelatedContent();
      })
    }
    .width('100%')
    .margin({ top: CommonConstants.SPACING.XL })
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 辅助方法 ====================

  private getPageTitle(): string {
    switch (this.message?.type) {
      case MessageType.COMMENT:
        return '评论详情';
      case MessageType.LIKE:
        return '点赞详情';
      case MessageType.COLLECT:
        return '收藏详情';
      case MessageType.SYSTEM:
        return '系统通知';
      default:
        return '通知详情';
    }
  }

  private getMessageTitle(type: MessageType): string {
    switch (type) {
      case MessageType.COMMENT:
        return '评论通知';
      case MessageType.LIKE:
        return '点赞通知';
      case MessageType.COLLECT:
        return '收藏通知';
      case MessageType.SYSTEM:
        return '系统通知';
      default:
        return '通知';
    }
  }

  private getMessageIcon(type: MessageType): Resource {
    switch (type) {
      case MessageType.COMMENT:
        return $r('app.media.ic_comment');
      case MessageType.LIKE:
        return $r('app.media.ic_like');
      case MessageType.COLLECT:
        return $r('app.media.ic_star');
      case MessageType.SYSTEM:
        return $r('app.media.ic_system');
      default:
        return $r('app.media.ic_message');
    }
  }

  private getMessageIconBgColor(type: MessageType): string {
    switch (type) {
      case MessageType.COMMENT:
        return '#FFE8E8';
      case MessageType.LIKE:
        return '#FFE8E8';
      case MessageType.COLLECT:
        return '#FFF4E0';
      case MessageType.SYSTEM:
        return '#F0F0F0';
      default:
        return '#F0F0F0';
    }
  }

  // ==================== 事件处理 ====================

  private viewRelatedContent() {
    console.log('查看相关内容，ID:', this.message?.targetId);
    // TODO: 跳转到相关新闻详情页
    if (this.message?.targetId) {
      router.pushUrl({
        url: 'pages/NewsDetailPage',
        params: {
          newsId: this.message.targetId
        }
      });
    }
  }
}
