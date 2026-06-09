import { PublishItem } from '../models/NewsModel';
import { PublishService } from '../services/PublishService';
import { CommonConstants } from '../common/CommonConstants';
import { CommentDialog } from '../components/CommentDialog';
import { router } from '@kit.ArkUI';

/**
 * 我的发布页面
 * 显示已发布的爆料列表
 */
@Entry
@Component
struct MyPublishPage {
  @State publishList: PublishItem[] = [];
  @State isLoading: boolean = true;
  
  // 监听发布状态变化，自动刷新列表
  @StorageLink(PublishService.STATE_VERSION_KEY) @Watch('onStateChanged') stateVersion: number = 0;
  
  // 评论弹窗控制器
  private commentDialogController: CustomDialogController | null = null;
  
  aboutToAppear() {
    this.loadPublishList();
  }
  
  aboutToDisappear() {
    // 清理弹窗控制器
    if (this.commentDialogController) {
      this.commentDialogController = null;
    }
  }
  
  // 状态变化时自动刷新列表
  onStateChanged() {
    if (!this.isLoading) {
      this.publishList = PublishService.getPublishList();
      console.log('状态变化，刷新列表');
    }
  }
  
  build() {
    Column() {
      // 顶部栏
      this.HeaderBar()
      
      // 内容区域
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.publishList.length === 0) {
        this.EmptyView()
      } else {
        this.PublishList()
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
      
      Text('我的发布')
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
      
      // 发布数量
      Text(`${this.publishList.length}`)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
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
  EmptyView() {
    Column({ space: CommonConstants.SPACING.LG }) {
      Image($r('app.media.ic_not_login'))
        .width(120)
        .height(120)
      
      Text('暂无发布内容')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      
      Text('快去发布你的第一条爆料吧！')
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(CommonConstants.COLORS.TEXT_HINT)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
  
  @Builder
  PublishList() {
    List({ space: CommonConstants.SPACING.MD }) {
      ForEach(this.publishList, (item: PublishItem) => {
        ListItem() {
          this.PublishCard(item)
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding(CommonConstants.SPACING.MD)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
  
  @Builder
  PublishCard(item: PublishItem) {
    Column({ space: CommonConstants.SPACING.MD }) {
      // 作者信息
      Row({ space: CommonConstants.SPACING.SM }) {
        Image(item.author.avatar)
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)
        
        Column({ space: 2 }) {
          Text(item.author.name)
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
          
          Text(PublishService.formatDisplayTime(item.publishTime))
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 删除按钮
        Image($r('app.media.ic_close'))
          .width(20)
          .height(20)
          .opacity(0.5)
          .onClick(() => {
            this.deletePublish(item.id);
          })
      }
      .width('100%')
      
      // 内容
      Text(item.content)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .width('100%')
      
      // 图片网格
      if (item.images.length > 0) {
        Grid() {
          ForEach(item.images, (image: string, index: number) => {
            GridItem() {
              Image(image)
                .width('100%')
                .height('100%')
                .borderRadius(CommonConstants.BORDER_RADIUS.SM)
                .objectFit(ImageFit.Cover)
            }
          })
        }
        .columnsTemplate(item.images.length === 1 ? '1fr' : 
                        item.images.length === 2 ? '1fr 1fr' : 
                        '1fr 1fr 1fr')
        .rowsTemplate(item.images.length === 1 ? '1fr' : '1fr 1fr')
        .columnsGap(CommonConstants.SPACING.SM)
        .rowsGap(CommonConstants.SPACING.SM)
        .width('100%')
        .height(item.images.length === 1 ? 200 : 240)
      }
      
      // 话题和来源
      Row({ space: CommonConstants.SPACING.SM }) {
        if (item.topic) {
          Text(`#${item.topic}#`)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.PRIMARY)
        }
        
        if (item.source) {
          Text(`来源: ${item.source}`)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }
        
        if (!item.isPublic) {
          Text('私密')
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
            .padding({ left: 4, right: 4, top: 2, bottom: 2 })
            .backgroundColor('#FFF5F5F5')
            .borderRadius(4)
        }
      }
      .width('100%')
      
      // 互动数据
      Row({ space: CommonConstants.SPACING.LG }) {
        this.InteractionItem($r('app.media.ic_like'), item.likeCount, item.isLiked, () => {
          this.toggleLike(item.id);
        })
        
        this.InteractionItem($r('app.media.ic_comment'), item.commentCount, false, () => {
          this.showCommentDialog(item.id);
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(CommonConstants.SPACING.LG)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .borderRadius(CommonConstants.BORDER_RADIUS.LG)
  }
  
  @Builder
  InteractionItem(icon: Resource, count: number, isActive: boolean, onClick: () => void) {
    Row({ space: 4 }) {
      Image(icon)
        .width(18)
        .height(18)
        .fillColor(isActive ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_HINT)
      
      Text(count.toString())
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(isActive ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
    }
    .onClick(() => onClick())
  }
  
  // ==================== 事件处理 ====================
  
  private loadPublishList() {
    setTimeout(() => {
      this.publishList = PublishService.getPublishList();
      this.isLoading = false;
      console.log(`加载了 ${this.publishList.length} 条发布内容`);
    }, 500);
  }
  
  private deletePublish(id: string) {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这条发布吗？',
      primaryButton: {
        value: '删除',
        fontColor: CommonConstants.COLORS.DANGER,
        action: () => {
          const success = PublishService.deletePublish(id);
          if (success) {
            this.publishList = PublishService.getPublishList();
          }
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }
  
  private toggleLike(id: string) {
    const result = PublishService.togglePublishLike(id);
    // 刷新列表
    this.publishList = PublishService.getPublishList();
  }
  
  private showCommentDialog(publishId: string) {
    // 创建评论弹窗
    this.commentDialogController = new CustomDialogController({
      builder: CommentDialog({
        publishId: publishId
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true
    });
    
    // 打开弹窗
    this.commentDialogController.open();
  }
}
