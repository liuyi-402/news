import { Message, MessageType } from '../models/NewsModel';
import { MockDataService } from '../services/MockDataService';
import { CommonConstants } from '../common/CommonConstants';

/**
 * 消息Tab项接口
 */
interface MessageTabItem {
  type: MessageType;
  name: string;
}

/**
 * 消息页 - 通知和私信
 * 复刻微博消息页样式
 */
@Component
export struct MessagePage {
  @State currentTab: number = 0;
  @State messageList: Message[] = [];
  @State unreadCounts: Map<MessageType, number> = new Map();
  @State avatarLoadFailed: Map<string, boolean> = new Map(); // 头像加载失败标志
  
  private tabs: MessageTabItem[] = [
    { type: MessageType.COMMENT, name: '评论' },
    { type: MessageType.LIKE, name: '点赞' },
    { type: MessageType.COLLECT, name: '收藏' },
    { type: MessageType.SYSTEM, name: '系统' },
    { type: MessageType.PRIVATE, name: '私信' }
  ];
  
  aboutToAppear() {
    this.loadData();
  }
  
  build() {
    Column() {
      // 顶部栏
      this.HeaderBar()
      
      // Tab栏
      this.TabBar()
      
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
  TabBar() {
    Row() {
      ForEach(this.tabs, (tab: MessageTabItem, index: number) => {
        Column({ space: 4 }) {
          Stack() {
            Image(this.getMessageIcon(tab.type))
              .width(24)
              .height(24)
            
            // 未读红点
            if (this.getUnreadCount(tab.type) > 0) {
              Text(this.getUnreadCount(tab.type) > 99 ? '99+' : this.getUnreadCount(tab.type).toString())
                .fontSize(CommonConstants.FONT_SIZE.SMALL)
                .fontColor(CommonConstants.COLORS.WHITE)
                .backgroundColor(CommonConstants.COLORS.DANGER)
                .borderRadius(10)
                .constraintSize({ minWidth: 16, maxHeight: 16 })
                .padding({ left: 4, right: 4 })
                .position({ x: '100%', y: 0 })
                .translate({ x: -8, y: -8 })
            }
          }
          .width(32)
          .height(32)
          
          Text(tab.name)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(this.currentTab === index ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .padding({ top: CommonConstants.SPACING.SM, bottom: CommonConstants.SPACING.SM })
        .onClick(() => {
          this.onTabChange(index);
        })
      })
    }
    .width('100%')
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .border({ width: { bottom: 0.5 }, color: { bottom: CommonConstants.COLORS.DIVIDER } })
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
      if (message.sender) {
        // 使用网络头像
        if (!this.avatarLoadFailed.get(message.sender!.id)) {
          Image(message.sender!.avatar)
            .width(48)
            .height(48)
            .borderRadius(24)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              console.log('MessagePage: 头像加载失败，使用默认头像');
              this.avatarLoadFailed.set(message.sender!.id, true);
            })
        } else {
          Image($r('app.media.default_avatar'))
            .width(48)
            .height(48)
            .borderRadius(24)
            .objectFit(ImageFit.Cover)
        }
      } else {
        Column() {
          Image(this.getMessageIcon(message.type))
            .width(24)
            .height(24)
        }
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor('#FFF0F0F0')
        .justifyContent(FlexAlign.Center)
      }
      
      // 消息内容
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(message.sender?.name || this.getMessageTitle(message.type))
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
          
          Text(message.createTime)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }
        .width('100%')
        
        Text(message.content)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          .maxLines(2)
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
    .padding(CommonConstants.SPACING.LG)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .onClick(() => {
      this.onMessageClick(message, index);
    })
  }
  
  // ==================== 事件处理 ====================
  
  private loadData() {
    // 加载消息列表
    this.messageList = MockDataService.getMessageList(this.tabs[this.currentTab].type);
    
    // 模拟未读数
    this.unreadCounts.set(MessageType.COMMENT, 5);
    this.unreadCounts.set(MessageType.LIKE, 12);
    this.unreadCounts.set(MessageType.COLLECT, 3);
    this.unreadCounts.set(MessageType.SYSTEM, 2);
    this.unreadCounts.set(MessageType.PRIVATE, 8);
  }
  
  private getUnreadCount(type: MessageType): number {
    return this.unreadCounts.get(type) || 0;
  }
  
  private getMessageIcon(type: MessageType): Resource {
    switch (type) {
      case MessageType.COMMENT:
        return $r('app.media.ic_comment');
      case MessageType.LIKE:
        return $r('app.media.ic_like');
      case MessageType.COLLECT:
        return $r('app.media.ic_collect');
      case MessageType.SYSTEM:
        return $r('app.media.ic_system');
      case MessageType.PRIVATE:
        return $r('app.media.ic_private');
      default:
        return $r('app.media.ic_message');
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
      case MessageType.PRIVATE:
        return '私信';
      default:
        return '消息';
    }
  }
  
  private onTabChange(index: number) {
    if (this.currentTab !== index) {
      this.currentTab = index;
      this.messageList = MockDataService.getMessageList(this.tabs[index].type);
    }
  }
  
  private onMessageClick(message: Message, index: number) {
    // 标记为已读
    this.messageList[index].isRead = true;
    
    // 更新未读数
    const type = message.type;
    const count = this.unreadCounts.get(type) || 0;
    if (count > 0) {
      this.unreadCounts.set(type, count - 1);
    }
    
    // TODO: 跳转到消息详情页
    console.log(`点击消息: ${message.title}`);
  }
  
  private markAllAsRead() {
    // 标记所有消息为已读
    this.messageList.forEach((message: Message) => {
      message.isRead = true;
    });
    
    // 清空未读数
    this.unreadCounts.clear();
  }
}
