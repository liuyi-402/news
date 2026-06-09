import { Comment } from '../models/NewsModel';
import { PublishService } from '../services/PublishService';
import { CommonConstants } from '../common/CommonConstants';

/**
 * 评论弹窗组件
 */
@CustomDialog
@Component
export struct CommentDialog {
  // 弹窗控制器
  controller: CustomDialogController;
  
  // 爆料ID
  publishId: string = '';
  
  // 评论列表
  @State comments: Comment[] = [];
  
  // 输入内容
  @State inputContent: string = '';
  
  // 最大输入长度
  private maxLength: number = 200;
  
  aboutToAppear() {
    this.loadComments();
  }
  
  build() {
    Column() {
      // 标题栏
      this.TitleBar()
      
      // 评论列表
      this.CommentList()
      
      // 输入区域
      this.InputArea()
    }
    .width('100%')
    .height('80%')
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .borderRadius({ topLeft: CommonConstants.BORDER_RADIUS.XL, topRight: CommonConstants.BORDER_RADIUS.XL })
  }
  
  @Builder
  TitleBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      Text('评论')
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
      
      Text(`${this.comments.length}`)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      
      // 关闭按钮
      Image($r('app.media.ic_close'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.controller.close();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
  }
  
  @Builder
  CommentList() {
    if (this.comments.length === 0) {
      // 空状态
      Column() {
        Image($r('app.media.ic_not_login'))
          .width(80)
          .height(80)
          .opacity(0.5)
        
        Text('暂无评论')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          .margin({ top: CommonConstants.SPACING.MD })
        
        Text('快来发表第一条评论吧！')
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      // 评论列表
      List({ space: CommonConstants.SPACING.MD }) {
        ForEach(this.comments, (comment: Comment) => {
          ListItem() {
            this.CommentItem(comment)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
  
  @Builder
  CommentItem(comment: Comment) {
    Column({ space: CommonConstants.SPACING.SM }) {
      // 用户信息
      Row({ space: CommonConstants.SPACING.SM }) {
        Image(comment.author.avatar)
          .width(36)
          .height(36)
          .borderRadius(18)
          .objectFit(ImageFit.Cover)
        
        Column({ space: 2 }) {
          Text(comment.author.name)
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
          
          Text(PublishService.formatDisplayTime(comment.publishTime))
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 删除按钮（仅自己的评论）
        if (comment.author.id === 'user_001') {
          Image($r('app.media.ic_close'))
            .width(16)
            .height(16)
            .opacity(0.5)
            .onClick(() => {
              this.deleteComment(comment.id);
            })
        }
      }
      .width('100%')
      
      // 评论内容
      Text(comment.content)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .width('100%')
        .margin({ left: 36 + CommonConstants.SPACING.SM })
      
      // 分割线
      Divider()
        .color(CommonConstants.COLORS.DIVIDER)
        .margin({ left: 36 + CommonConstants.SPACING.SM })
    }
    .width('100%')
    .padding({ top: CommonConstants.SPACING.SM, bottom: CommonConstants.SPACING.SM })
  }
  
  @Builder
  InputArea() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 输入框
      TextInput({ placeholder: '发表评论...', text: this.inputContent })
        .layoutWeight(1)
        .height(40)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .placeholderColor(CommonConstants.COLORS.TEXT_HINT)
        .backgroundColor(CommonConstants.COLORS.BACKGROUND)
        .borderRadius(CommonConstants.BORDER_RADIUS.MD)
        .maxLength(this.maxLength)
        .onChange((value: string) => {
          this.inputContent = value;
        })
      
      // 发送按钮
      Button('发送')
        .height(40)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.WHITE)
        .backgroundColor(this.canSend() ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_HINT)
        .borderRadius(CommonConstants.BORDER_RADIUS.MD)
        .enabled(this.canSend())
        .onClick(() => {
          this.sendComment();
        })
    }
    .width('100%')
    .padding(CommonConstants.SPACING.LG)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .border({ width: { top: 1 }, color: CommonConstants.COLORS.DIVIDER })
  }
  
  // ==================== 辅助方法 ====================
  
  private canSend(): boolean {
    return this.inputContent.trim().length > 0;
  }
  
  private loadComments() {
    this.comments = PublishService.getComments(this.publishId);
    console.log(`加载了 ${this.comments.length} 条评论`);
  }
  
  private sendComment() {
    if (!this.canSend()) {
      return;
    }
    
    const success = PublishService.addComment(this.publishId, this.inputContent.trim());
    if (success) {
      // 清空输入框
      this.inputContent = '';
      // 重新加载评论列表
      this.loadComments();
    }
  }
  
  private deleteComment(commentId: string) {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这条评论吗？',
      primaryButton: {
        value: '删除',
        fontColor: CommonConstants.COLORS.DANGER,
        action: () => {
          const success = PublishService.deleteComment(this.publishId, commentId);
          if (success) {
            this.loadComments();
          }
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }
}
