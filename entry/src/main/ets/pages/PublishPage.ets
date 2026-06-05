import { CommonConstants } from '../common/CommonConstants';

/**
 * 发布页 - 新闻爆料/投稿
 * 复刻微博发布页样式
 */
@Component
export struct PublishPage {
  @State content: string = '';
  @State images: string[] = [];
  @State topic: string = '';
  @State source: string = '';
  @State isPublic: boolean = true;
  @State maxImageCount: number = 9;
  
  build() {
    Column() {
      // 顶部栏
      this.HeaderBar()
      
      // 编辑区域
      Scroll() {
        Column({ space: CommonConstants.SPACING.MD }) {
          // 文字输入
          this.ContentInput()
          
          // 图片上传
          this.ImageUpload()
          
          // 话题选择
          this.TopicSelector()
          
          // 来源标注
          this.SourceInput()
          
          // 权限设置
          this.PermissionSetting()
        }
        .width('100%')
        .padding(CommonConstants.SPACING.LG)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }
  
  @Builder
  HeaderBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 取消按钮
      Text('取消')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        .onClick(() => {
          this.onCancel();
        })
      
      // 标题
      Text('发布爆料')
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // 发布按钮
      Button('发布')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.WHITE)
        .backgroundColor(this.canPublish() ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_HINT)
        .borderRadius(CommonConstants.BORDER_RADIUS.ROUND)
        .height(32)
        .padding({ left: 16, right: 16 })
        .enabled(this.canPublish())
        .onClick(() => {
          this.onPublish();
        })
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .border({ width: { bottom: 0.5 }, color: { bottom: CommonConstants.COLORS.DIVIDER } })
  }
  
  @Builder
  ContentInput() {
    Column({ space: CommonConstants.SPACING.SM }) {
      TextArea({ placeholder: '分享新鲜事，爆料新闻线索...' })
        .width('100%')
        .height(200)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .placeholderColor(CommonConstants.COLORS.TEXT_HINT)
        .backgroundColor('#FFF5F5F5')
        .borderRadius(CommonConstants.BORDER_RADIUS.MD)
        .onChange((value: string) => {
          this.content = value;
        })
      
      // 字数统计
      Row() {
        Text(`${this.content.length}/500`)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(this.content.length > 500 ? CommonConstants.COLORS.DANGER : CommonConstants.COLORS.TEXT_HINT)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
  }
  
  @Builder
  ImageUpload() {
    Column({ space: CommonConstants.SPACING.SM }) {
      // 标题
      Row({ space: CommonConstants.SPACING.SM }) {
        Image($r('app.media.ic_add_image'))
          .width(20)
          .height(20)
        
        Text('添加图片')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
        
        Text(`(${this.images.length}/${this.maxImageCount})`)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
      .width('100%')
      
      // 图片网格
      Grid() {
        ForEach(this.images, (image: string, index: number) => {
          GridItem() {
            Stack() {
              Image($r('app.media.default_cover'))
                .width('100%')
                .height('100%')
                .borderRadius(CommonConstants.BORDER_RADIUS.SM)
                .objectFit(ImageFit.Cover)
              
              // 删除按钮
              Column() {
                Image($r('app.media.ic_close'))
                  .width(16)
                  .height(16)
              }
              .width(20)
              .height(20)
              .borderRadius(10)
              .backgroundColor('rgba(0, 0, 0, 0.5)')
              .position({ x: '100%', y: 0 })
              .translate({ x: -8, y: 8 })
              .onClick(() => {
                this.removeImage(index);
              })
            }
            .width('100%')
            .height('100%')
          }
        })
        
        // 添加图片按钮
        if (this.images.length < this.maxImageCount) {
          GridItem() {
            Column() {
              Image($r('app.media.ic_add_image'))
                .width(32)
                .height(32)
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#FFF5F5F5')
            .borderRadius(CommonConstants.BORDER_RADIUS.SM)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.addImage();
            })
          }
        }
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr')
      .columnsGap(CommonConstants.SPACING.SM)
      .rowsGap(CommonConstants.SPACING.SM)
      .width('100%')
      .height(240)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  TopicSelector() {
    Row({ space: CommonConstants.SPACING.MD }) {
      Image($r('app.media.ic_topic'))
        .width(20)
        .height(20)
      
      Text('话题')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .layoutWeight(1)
      
      if (this.topic) {
        Text(`#${this.topic}#`)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.PRIMARY)
      } else {
        Text('选择话题')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
      
      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .opacity(0.5)
    }
    .width('100%')
    .height(56)
    .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD })
    .backgroundColor('#FFF5F5F5')
    .borderRadius(CommonConstants.BORDER_RADIUS.MD)
    .onClick(() => {
      this.selectTopic();
    })
  }
  
  @Builder
  SourceInput() {
    Row({ space: CommonConstants.SPACING.MD }) {
      Image($r('app.media.ic_source'))
        .width(20)
        .height(20)
      
      Text('来源')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .layoutWeight(1)
      
      if (this.source) {
        Text(this.source)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      } else {
        Text('标注来源')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
      
      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .opacity(0.5)
    }
    .width('100%')
    .height(56)
    .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD })
    .backgroundColor('#FFF5F5F5')
    .borderRadius(CommonConstants.BORDER_RADIUS.MD)
    .onClick(() => {
      this.inputSource();
    })
  }
  
  @Builder
  PermissionSetting() {
    Row({ space: CommonConstants.SPACING.MD }) {
      Image($r('app.media.ic_permission'))
        .width(20)
        .height(20)
      
      Text('权限')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .layoutWeight(1)
      
      Text(this.isPublic ? '公开可见' : '仅自己可见')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      
      Toggle({ type: ToggleType.Switch, isOn: this.isPublic })
        .onChange((value: boolean) => {
          this.isPublic = value;
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD })
    .backgroundColor('#FFF5F5F5')
    .borderRadius(CommonConstants.BORDER_RADIUS.MD)
  }
  
  // ==================== 事件处理 ====================
  
  private canPublish(): boolean {
    return this.content.trim().length > 0 && this.content.length <= 500;
  }
  
  private onCancel() {
    // TODO: 返回上一页或显示确认对话框
    console.log('取消发布');
  }
  
  private onPublish() {
    if (!this.canPublish()) {
      return;
    }
    
    // TODO: 发布新闻
    console.log(`发布内容: ${this.content}`);
    console.log(`图片数量: ${this.images.length}`);
    console.log(`话题: ${this.topic}`);
    console.log(`来源: ${this.source}`);
    console.log(`权限: ${this.isPublic ? '公开' : '私密'}`);
  }
  
  private addImage() {
    if (this.images.length < this.maxImageCount) {
      // TODO: 打开图片选择器
      this.images.push(`image_${this.images.length + 1}`);
      console.log('添加图片');
    }
  }
  
  private removeImage(index: number) {
    this.images.splice(index, 1);
  }
  
  private selectTopic() {
    // TODO: 打开话题选择器
    this.topic = '热点新闻';
    console.log('选择话题');
  }
  
  private inputSource() {
    // TODO: 打开来源输入对话框
    this.source = '网络整理';
    console.log('输入来源');
  }
}
