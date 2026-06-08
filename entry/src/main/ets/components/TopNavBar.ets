// 顶部导航栏组件
@Component
export struct TopNavBar {
  @Link searchText: string
  onSearch?: () => void
  onMessage?: () => void
  onPublish?: () => void
  onMenu?: () => void

  build() {
    Column() {
      // 状态栏占位
      Row()
        .height(24)
        .width('100%')
        .backgroundColor('#000000')

      // 导航栏主体
      Row() {
        // Logo和菜单按钮
        Row() {
          // 菜单按钮（汉堡菜单）
          Button() {
            Text('☰')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            if (this.onMenu) {
              this.onMenu()
            }
          })

          // Logo
          Text('新闻')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 8 })
        }
        .layoutWeight(1)

        // 搜索框
        Row() {
          Text('🔍')
            .fontSize(16)
            .margin({ left: 12, right: 8 })

          TextInput({ placeholder: '搜索新闻、话题', text: this.searchText })
            .layoutWeight(1)
            .height(32)
            .backgroundColor(Color.Transparent)
            .placeholderColor('#CCCCCC')
            .fontColor('#FFFFFF')
            .fontSize(14)
            .onChange((value: string) => {
              this.searchText = value
            })
            .onSubmit(() => {
              if (this.onSearch) {
                this.onSearch()
              }
            })
        }
        .layoutWeight(2)
        .height(36)
        .backgroundColor('rgba(255, 255, 255, 0.15)')
        .borderRadius(18)
        .margin({ left: 16, right: 16 })

        // 消息和发布按钮
        Row() {
          // 消息按钮
          Badge({
            count: 5,
            position: BadgePosition.RightTop,
            style: { badgeSize: 16, badgeColor: '#FF0000' }
          }) {
            Button() {
              Text('✉')
                .fontSize(20)
                .fontColor('#FFFFFF')
            }
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
          }
          .onClick(() => {
            if (this.onMessage) {
              this.onMessage()
            }
          })

          // 发布按钮
          Button() {
            Text('+')
              .fontSize(24)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
          .width(40)
          .height(40)
          .backgroundColor('#FF6B6B')
          .borderRadius(20)
          .margin({ left: 8 })
          .onClick(() => {
            if (this.onPublish) {
              this.onPublish()
            }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .linearGradient({
        angle: 180,
        colors: [['#1A1A1A', 0.0], ['#000000', 1.0]]
      })
    }
    .width('100%')
  }
}
