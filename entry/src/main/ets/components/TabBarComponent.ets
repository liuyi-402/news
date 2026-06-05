import { CommonConstants } from '../common/CommonConstants';

/**
 * Tab项接口
 */
interface TabItem {
  text: string;
}

/**
 * 底部导航栏组件
 * 完全复刻微博底部导航样式
 */
@Component
export struct TabBarComponent {
  @Prop currentIndex: number = 0;
  onTabChange?: (index: number) => void;
  
  private tabItems: TabItem[] = [
    { text: '首页' },
    { text: '发现' },
    { text: '发布' },
    { text: '消息' },
    { text: '我的' }
  ];
  
  build() {
    Row() {
      ForEach(this.tabItems, (item: TabItem, index: number) => {
        Column() {
          if (index === 2) {
            // 发布按钮特殊样式（圆形大按钮）
            this.PublishButton()
          } else {
            // 普通导航项
            this.TabItem(item, index)
          }
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (this.onTabChange) {
            this.onTabChange(index);
          }
        })
      })
    }
    .width('100%')
    .height(CommonConstants.TAB_BAR_HEIGHT)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .border({ width: { top: 0.5 }, color: { top: CommonConstants.COLORS.DIVIDER } })
  }
  
  @Builder
  TabItem(item: TabItem, index: number) {
    Column({ space: 2 }) {
      // 使用真实图标
      if (index === 0) {
        Image(this.currentIndex === index ? $r('app.media.ic_home_active') : $r('app.media.ic_home'))
          .width(24)
          .height(24)
      } else if (index === 1) {
        Image(this.currentIndex === index ? $r('app.media.ic_discover_active') : $r('app.media.ic_discover'))
          .width(24)
          .height(24)
      } else if (index === 3) {
        Image(this.currentIndex === index ? $r('app.media.ic_message_active') : $r('app.media.ic_message'))
          .width(24)
          .height(24)
      } else if (index === 4) {
        Image(this.currentIndex === index ? $r('app.media.ic_profile_active') : $r('app.media.ic_profile'))
          .width(24)
          .height(24)
      }
      
      Text(item.text)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
    }
  }
  
  @Builder
  PublishButton() {
    Column() {
      Image($r('app.media.ic_publish'))
        .width(48)
        .height(48)
    }
    .offset({ y: -10 })
  }
}
