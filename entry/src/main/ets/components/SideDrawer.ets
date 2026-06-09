// 侧边栏组件
import { Message } from '../models/NewsModel'

@Component
export struct SideDrawer {
  @Prop isVisible: boolean = false
  @Prop messages: Message[] = []
  onClose?: () => void
  onNavigate?: (page: string) => void

  build() {
    if (this.isVisible) {
      Row() {
        // 侧边栏内容
        Column() {
          // 用户信息区域
          this.UserProfile()

          // 分割线
          Column()
            .width('100%')
            .height(1)
            .backgroundColor('#EEEEEE')
            .margin({ top: 16, bottom: 16 })

          // 菜单项
          this.MenuItems()

          Blank()

          // 底部设置
          this.BottomSettings()
        }
        .width(280)
        .height('100%')
        .backgroundColor('#FFFFFF')
        .padding({ top: 48, left: 24, right: 24, bottom: 24 })

        // 遮罩层
        Column()
          .layoutWeight(1)
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => {
            if (this.onClose) {
              this.onClose()
            }
          })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(999)
    }
  }

  // 用户信息区域
  @Builder
  UserProfile() {
    Row() {
      // 用户头像
      Image('https://picsum.photos/100/100?random=user')
        .width(60)
        .height(60)
        .borderRadius(30)
        .objectFit(ImageFit.Cover)

      Column() {
        Text('用户昵称')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Row() {
          Text('关注 128')
            .fontSize(12)
            .fontColor('#666666')

          Text(' | ')
            .fontSize(12)
            .fontColor('#CCCCCC')

          Text('粉丝 1.2万')
            .fontSize(12)
            .fontColor('#666666')
        }
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (this.onNavigate) {
        this.onNavigate('profile')
      }
    })
  }

  // 菜单项
  @Builder
  MenuItems() {
    Column() {
      // 消息通知
      this.MenuItem('✉', '消息通知', this.messages.filter(m => !m.isRead).length, () => {
        if (this.onNavigate) {
          this.onNavigate('messages')
        }
      })

      // 发现
      this.MenuItem('🔍', '发现', 0, () => {
        if (this.onNavigate) {
          this.onNavigate('discover')
        }
      })

      // 收藏
      this.MenuItem('⭐', '我的收藏', 0, () => {
        if (this.onNavigate) {
          this.onNavigate('collection')
        }
      })

      // 历史
      this.MenuItem('📖', '浏览历史', 0, () => {
        if (this.onNavigate) {
          this.onNavigate('history')
        }
      })

      // 热门话题
      this.MenuItem('🔥', '热门话题', 0, () => {
        if (this.onNavigate) {
          this.onNavigate('topics')
        }
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 菜单项组件
  @Builder
  MenuItem(icon: string, title: string, badge: number, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(24)

      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ left: 16 })

      Blank()

      // 未读消息数
      if (badge > 0) {
        Text(badge.toString())
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF6B6B')
          .borderRadius(10)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      }

      Text('›')
        .fontSize(20)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .height(50)
    .onClick(onClick)
  }

  // 底部设置
  @Builder
  BottomSettings() {
    Column() {
      Row() {
        Text('⚙')
          .fontSize(24)

        Text('设置')
          .fontSize(16)
          .fontColor('#333333')
          .margin({ left: 16 })
      }
      .width('100%')
      .height(50)
      .onClick(() => {
        if (this.onNavigate) {
          this.onNavigate('settings')
        }
      })

      Row() {
        Text('🌙')
          .fontSize(24)

        Text('夜间模式')
          .fontSize(16)
          .fontColor('#333333')
          .margin({ left: 16 })

        Blank()

        Toggle({ type: ToggleType.Switch, isOn: false })
          .onChange((isOn: boolean) => {
            console.info(`Night mode: ${isOn}`)
          })
      }
      .width('100%')
      .height(50)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
