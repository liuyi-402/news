import { CommonConstants } from '../common/CommonConstants';
import { PublishService } from '../services/PublishService';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

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
  @State isPublishing: boolean = false;
  @State showSuccess: boolean = false;
  
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
      
      // 成功提示
      if (this.showSuccess) {
        Column() {
          Text('发布成功！')
            .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
            .fontColor(CommonConstants.COLORS.WHITE)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .height(60)
        .backgroundColor(CommonConstants.COLORS.SUCCESS)
        .justifyContent(FlexAlign.Center)
        .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
      }
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
              Image(image)
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
    if (!this.canPublish() || this.isPublishing) {
      return;
    }
    
    this.isPublishing = true;
    
    // 调用发布服务
    const result = PublishService.publish(
      this.content,
      this.images,
      this.topic,
      this.source,
      this.isPublic
    );
    
    console.log(`发布成功，ID: ${result.id}`);
    
    // 显示成功提示
    this.showSuccess = true;
    
    // 延迟清空表单并隐藏提示
    setTimeout(() => {
      this.showSuccess = false;
      this.content = '';
      this.images = [];
      this.topic = '';
      this.source = '';
      this.isPublic = true;
      this.isPublishing = false;
    }, 1500);
  }
  
  private async addImage() {
    if (this.images.length >= this.maxImageCount) {
      return;
    }
    
    try {
      // 创建图片选择器
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      
      // 配置选择选项
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = this.maxImageCount - this.images.length;
      
      // 打开图片选择器
      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      
      if (photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        // 添加选中的图片
        this.images.push(...photoSelectResult.photoUris);
        console.log(`添加了 ${photoSelectResult.photoUris.length} 张图片`);
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`选择图片失败: ${err.code} - ${err.message}`);
    }
  }
  
  private removeImage(index: number) {
    this.images.splice(index, 1);
  }
  
  private selectTopic() {
    // 使用AlertDialog选择话题
    AlertDialog.show({
      title: '选择话题',
      message: '请选择一个话题标签',
      primaryButton: {
        value: '热点新闻',
        action: () => {
          this.topic = '热点新闻';
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }
  
  private inputSource() {
    // 使用TextInputDialog输入来源（简化处理，直接设置）
    AlertDialog.show({
      title: '标注来源',
      message: '请选择来源类型',
      primaryButton: {
        value: '网络整理',
        action: () => {
          this.source = '网络整理';
        }
      },
      secondaryButton: {
        value: '原创',
        action: () => {
          this.source = '原创';
        }
      }
    });
  }
}
