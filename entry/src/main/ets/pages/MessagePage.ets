import { Message, MessageType } from '../models/NewsModel';
import { MockDataService } from '../services/MockDataService';
import { CommonConstants } from '../common/CommonConstants';
import router from '@ohos.router';

/**
 * 消息页 - 参考抖音样式
 * 统一列表展示，私信进入聊天，其他通知进入详情
 */
@Component
export struct MessagePage {
  @State messageList: Message[] = [];
  @State avatarLoadFailed: Map<string, boolean> = new Map();

  aboutToAppear() {
    this.loadData();
  }

  build() {
    Column() {
      // 顶部栏
      this.HeaderBar()

      // 消息列表
      this.MessageList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.BACKGROUND)
  }

  @Builder
  HeaderBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      Text('消息')
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)

      // 全部已读按钮
      Text('全部已读')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.PRIMARY)
        .onClick(() => {
          this.markAllAsRead();
        })
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }

  @Builder
  MessageList() {
    if (this.messageList.length === 0) {
      // 空状态
      Column() {
        Image($r('app.media.ic_empty_message'))
          .width(120)
          .height(120)

        Text('暂无消息')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
          .margin({ top: CommonConstants.SPACING.MD })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.messageList, (message: Message, index: number) => {
          ListItem() {
            this.MessageItem(message, index)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .friction(0.6)
    }
  }

  @Builder
  MessageItem(message: Message, index: number) {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 头像/图标
      if (message.type === MessageType.PRIVATE && message.sender) {
        // 私信显示用户头像
        if (!this.avatarLoadFailed.get(message.sender!.id)) {
          Image(message.sender!.avatar)
            .width(50)
            .height(50)
            .borderRadius(25)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              console.log('MessagePage: 头像加载失败，使用默认头像');
              this.avatarLoadFailed.set(message.sender!.id, true);
            })
        } else {
          Image($r('app.media.default_avatar'))
            .width(50)
            .height(50)
            .borderRadius(25)
            .objectFit(ImageFit.Cover)
        }
      } else {
        // 其他通知显示系统图标
        Column() {
          Image(this.getMessageIcon(message.type))
            .width(24)
            .height(24)
        }
        .width(50)
        .height(50)
        .borderRadius(25)
        .backgroundColor(this.getMessageIconBgColor(message.type))
        .justifyContent(FlexAlign.Center)
      }

      // 消息内容
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          // 标题
          Text(this.getMessageTitle(message))
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)

          // 时间
          Text(message.createTime)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }
        .width('100%')

        // 内容
        Text(message.content)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 未读标识
      if (!message.isRead) {
        Column()
          .width(8)
          .height(8)
          .borderRadius(4)
          .backgroundColor(CommonConstants.COLORS.DANGER)
      }
    }
    .width('100%')
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG, top: 12, bottom: 12 })
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .onClick(() => {
      this.onMessageClick(message, index);
    })
  }

  // ==================== 事件处理 ====================

  private loadData() {
    // 加载所有消息列表
    this.messageList = MockDataService.getAllMessageList();
  }

  private getMessageTitle(message: Message): string {
    if (message.type === MessageType.PRIVATE && message.sender) {
      return message.sender.name;
    }
    
    switch (message.type) {
      case MessageType.COMMENT:
        return '评论';
      case MessageType.LIKE:
        return '赞';
      case MessageType.COLLECT:
        return '收藏';
      case MessageType.SYSTEM:
        return '系统通知';
      default:
        return '消息';
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
      case MessageType.PRIVATE:
        return $r('app.media.ic_private');
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
      case MessageType.PRIVATE:
        return '#E8F0FF';
      default:
        return '#F0F0F0';
    }
  }

  private onMessageClick(message: Message, index: number) {
    // 标记为已读
    this.messageList[index].isRead = true;

    // 根据消息类型跳转不同页面
    if (message.type === MessageType.PRIVATE) {
      // 私信跳转到聊天页面
      router.pushUrl({
        url: 'pages/ChatPage',
        params: {
          message: message
        }
      });
    } else {
      // 其他通知跳转到用户主页
      if (message.sender) {
        router.pushUrl({
          url: 'pages/UserProfilePage',
          params: {
            user: message.sender
          }
        });
      }
    }
  }

  private markAllAsRead() {
    // 标记所有消息为已读
    this.messageList.forEach((message: Message) => {
      message.isRead = true;
    });
  }
}
