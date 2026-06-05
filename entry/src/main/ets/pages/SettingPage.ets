import { CommonConstants } from '../common/CommonConstants';

/**
 * 设置页面
 */
@Component
export struct SettingPage {
  @State notificationEnabled: boolean = true;
  @State privateMode: boolean = false;
  @State nightMode: boolean = false;
  @State cacheSize: string = '23.5MB';
  
  private settingGroups: Array<Array<{icon: Resource, title: string, type: string, route?: string}>> = [
    [
      { icon: $r('app.media.ic_notification'), title: '消息通知', type: 'switch' },
      { icon: $r('app.media.ic_private'), title: '隐私模式', type: 'switch' },
      { icon: $r('app.media.ic_night_mode'), title: '夜间模式', type: 'switch' }
    ],
    [
      { icon: $r('app.media.ic_cache'), title: '清理缓存', type: 'action' },
      { icon: $r('app.media.ic_font'), title: '字体大小', type: 'route', route: 'FontSizeSetting' },
      { icon: $r('app.media.ic_language'), title: '语言设置', type: 'route', route: 'LanguageSetting' }
    ],
    [
      { icon: $r('app.media.ic_about'), title: '关于我们', type: 'route', route: 'About' },
      { icon: $r('app.media.ic_feedback'), title: '意见反馈', type: 'route', route: 'Feedback' },
      { icon: $r('app.media.ic_help'), title: '帮助中心', type: 'route', route: 'Help' }
    ]
  ];
  
  build() {
    Column() {
      // 顶部栏
      this.HeaderBar()
      
      // 设置列表
      Scroll() {
        Column({ space: CommonConstants.SPACING.MD }) {
          ForEach(this.settingGroups, (group: Array<{icon: Resource, title: string, type: string, route?: string}>, groupIndex: number) => {
            this.SettingGroup(group, groupIndex)
          })
          
          // 版本信息
          this.VersionInfo()
        }
        .width('100%')
        .padding(CommonConstants.SPACING.MD)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.BACKGROUND)
  }
  
  @Builder
  HeaderBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.onBack();
        })
      
      Text('设置')
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Blank()
        .width(24)
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }
  
  @Builder
  SettingGroup(group: Array<{icon: Resource, title: string, type: string, route?: string}>, groupIndex: number) {
    Column({ space: 0 }) {
      ForEach(group, (item: {icon: Resource, title: string, type: string, route?: string}, index: number) => {
        Column() {
          Row({ space: CommonConstants.SPACING.MD }) {
            Image(item.icon)
              .width(24)
              .height(24)
            
            Text(item.title)
              .fontSize(CommonConstants.FONT_SIZE.BODY)
              .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
              .layoutWeight(1)
            
            if (item.type === 'switch') {
              Toggle({ type: ToggleType.Switch, isOn: this.getSwitchValue(item.title) })
                .onChange((value: boolean) => {
                  this.onSwitchChange(item.title, value);
                })
            } else if (item.type === 'action') {
              if (item.title === '清理缓存') {
                Text(this.cacheSize)
                  .fontSize(CommonConstants.FONT_SIZE.CAPTION)
                  .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
              }
            } else {
              Image($r('app.media.ic_arrow_right'))
                .width(16)
                .height(16)
                .opacity(0.5)
            }
          }
          .width('100%')
          .height(56)
          .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
          .onClick(() => {
            if (item.type !== 'switch') {
              this.onItemClick(item);
            }
          })
          
          if (index < group.length - 1) {
            Divider()
              .color(CommonConstants.COLORS.DIVIDER)
              .margin({ left: 56 })
          }
        }
        .width('100%')
        .backgroundColor(CommonConstants.COLORS.WHITE)
      })
    }
    .width('100%')
    .borderRadius(CommonConstants.BORDER_RADIUS.LG)
  }
  
  @Builder
  VersionInfo() {
    Column({ space: CommonConstants.SPACING.SM }) {
      Text('新闻资讯 v1.0.0')
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(CommonConstants.COLORS.TEXT_HINT)
      
      Text('© 2024 News App. All rights reserved.')
        .fontSize(CommonConstants.FONT_SIZE.SMALL)
        .fontColor(CommonConstants.COLORS.TEXT_HINT)
    }
    .width('100%')
    .padding(CommonConstants.SPACING.XL)
  }
  
  // ==================== 事件处理 ====================
  
  private getSwitchValue(title: string): boolean {
    switch (title) {
      case '消息通知':
        return this.notificationEnabled;
      case '隐私模式':
        return this.privateMode;
      case '夜间模式':
        return this.nightMode;
      default:
        return false;
    }
  }
  
  private onSwitchChange(title: string, value: boolean) {
    switch (title) {
      case '消息通知':
        this.notificationEnabled = value;
        break;
      case '隐私模式':
        this.privateMode = value;
        break;
      case '夜间模式':
        this.nightMode = value;
        break;
    }
  }
  
  private onBack() {
    // TODO: 返回上一页
    console.log('返回上一页');
  }
  
  private onItemClick(item: {icon: Resource, title: string, type: string, route?: string}) {
    if (item.title === '清理缓存') {
      this.clearCache();
    } else if (item.route) {
      this.navigateTo(item.route);
    }
  }
  
  private clearCache() {
    // TODO: 清理缓存
    console.log('清理缓存');
    this.cacheSize = '0KB';
  }
  
  private navigateTo(route: string) {
    // TODO: 路由跳转
    console.log(`跳转到: ${route}`);
  }
}
