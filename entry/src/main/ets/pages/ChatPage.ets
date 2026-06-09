import { Message, AuthorInfo } from '../models/NewsModel';
import { CommonConstants } from '../common/CommonConstants';
import router from '@ohos.router';

/**
 * 聊天消息接口
 */
interface ChatMessage {
  id: string;
  content: string;
  isSelf: boolean; // 是否是自己发送的
  time: string;
}

/**
 * 聊天页面 - 参考抖音聊天界面
 */
@Entry
@Component
struct ChatPage {
  @State message: Message | null = null;
  @State chatMessages: ChatMessage[] = [];
  @State inputText: string = '';
  @State avatarLoadFailed: boolean = false;

  aboutToAppear() {
    // 从路由参数获取消息数据
    const params = router.getParams() as Record<string, Object>;
    if (params && params['message']) {
      this.message = params['message'] as Message;
      this.loadChatHistory();
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderBar()

      // 聊天记录列表
      this.ChatList()

      // 输入框
      this.InputBar()
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

      // 用户信息
      Row({ space: CommonConstants.SPACING.SM }) {
        if (this.message?.sender) {
          if (!this.avatarLoadFailed) {
            Image(this.message!.sender!.avatar)
              .width(36)
              .height(36)
              .borderRadius(18)
              .objectFit(ImageFit.Cover)
              .onError(() => {
                this.avatarLoadFailed = true;
              })
          } else {
            Image($r('app.media.default_avatar'))
              .width(36)
              .height(36)
              .borderRadius(18)
              .objectFit(ImageFit.Cover)
          }
        }

        Text(this.message?.sender?.name || '用户')
          .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      // 更多按钮
      Image($r('app.media.ic_more'))
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }

  @Builder
  ChatList() {
    List() {
      ForEach(this.chatMessages, (chatMsg: ChatMessage) => {
        ListItem() {
          this.ChatMessageItem(chatMsg)
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({ top: CommonConstants.SPACING.MD, bottom: CommonConstants.SPACING.MD })
  }

  @Builder
  ChatMessageItem(chatMsg: ChatMessage) {
    if (chatMsg.isSelf) {
      // 自己发送的消息 - 右侧
      Row({ space: CommonConstants.SPACING.SM }) {
        // 消息气泡
        Column() {
          Text(chatMsg.content)
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.WHITE)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        }
        .backgroundColor(CommonConstants.COLORS.PRIMARY)
        .borderRadius(16)
        .constraintSize({ maxWidth: '70%' })

        // 头像
        Image($r('app.media.default_avatar'))
          .width(36)
          .height(36)
          .borderRadius(18)
          .objectFit(ImageFit.Cover)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG, top: 4, bottom: 4 })
    } else {
      // 对方发送的消息 - 左侧
      Row({ space: CommonConstants.SPACING.SM }) {
        // 头像
        if (this.message?.sender) {
          if (!this.avatarLoadFailed) {
            Image(this.message!.sender!.avatar)
              .width(36)
              .height(36)
              .borderRadius(18)
              .objectFit(ImageFit.Cover)
              .onError(() => {
                this.avatarLoadFailed = true;
              })
          } else {
            Image($r('app.media.default_avatar'))
              .width(36)
              .height(36)
              .borderRadius(18)
              .objectFit(ImageFit.Cover)
          }
        }

        // 消息气泡
        Column() {
          Text(chatMsg.content)
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        }
        .backgroundColor(CommonConstants.COLORS.WHITE)
        .borderRadius(16)
        .constraintSize({ maxWidth: '70%' })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG, top: 4, bottom: 4 })
    }
  }

  @Builder
  InputBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 输入框
      TextInput({ placeholder: '发送消息...', text: this.inputText })
        .layoutWeight(1)
        .height(40)
        .backgroundColor(CommonConstants.COLORS.WHITE)
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.inputText = value;
        })

      // 发送按钮
      Button('发送')
        .height(40)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.WHITE)
        .backgroundColor(this.inputText.length > 0 ? CommonConstants.COLORS.PRIMARY : '#CCCCCC')
        .borderRadius(20)
        .enabled(this.inputText.length > 0)
        .onClick(() => {
          this.sendMessage();
        })
    }
    .width('100%')
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG, top: 8, bottom: 8 })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }

  // ==================== 事件处理 ====================

  private loadChatHistory() {
    // 模拟聊天记录
    this.chatMessages = [
      {
        id: '1',
        content: '你好！',
        isSelf: false,
        time: '10:00'
      },
      {
        id: '2',
        content: '你好，有什么事吗？',
        isSelf: true,
        time: '10:01'
      },
      {
        id: '3',
        content: '想问一下你最近发布的新闻内容',
        isSelf: false,
        time: '10:02'
      },
      {
        id: '4',
        content: '好的，请问具体是哪一篇呢？',
        isSelf: true,
        time: '10:03'
      },
      {
        id: '5',
        content: '就是关于科技的那篇',
        isSelf: false,
        time: '10:04'
      }
    ];
  }

  private sendMessage() {
    if (this.inputText.trim().length === 0) {
      return;
    }

    // 添加新消息
    this.chatMessages.push({
      id: `msg_${this.chatMessages.length}`,
      content: this.inputText,
      isSelf: true,
      time: new Date().toLocaleTimeString()
    });

    // 清空输入框
    this.inputText = '';

    // 模拟对方回复
    setTimeout(() => {
      this.chatMessages.push({
        id: `msg_${this.chatMessages.length}`,
        content: '收到你的消息了！',
        isSelf: false,
        time: new Date().toLocaleTimeString()
      });
    }, 1000);
  }
}
