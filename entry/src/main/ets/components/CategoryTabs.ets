// 分类标签栏组件
import { NewsCategory } from '../models/NewsModel'

@Component
export struct CategoryTabs {
  @Link currentCategory: NewsCategory
  private categories: NewsCategory[] = [
    NewsCategory.FOLLOW,
    NewsCategory.RECOMMEND,
    NewsCategory.HOT,
    NewsCategory.LOCAL
  ]
  onCategoryChange?: (category: NewsCategory) => void

  build() {
    Column() {
      Row() {
        ForEach(this.categories, (category: NewsCategory) => {
          Column() {
            Text(category)
              .fontSize(this.currentCategory === category ? 18 : 16)
              .fontColor(this.currentCategory === category ? '#FF6B6B' : '#666666')
              .fontWeight(this.currentCategory === category ? FontWeight.Bold : FontWeight.Normal)

            // 下划线指示器
            Column()
              .width(this.currentCategory === category ? 24 : 0)
              .height(3)
              .backgroundColor('#FF6B6B')
              .borderRadius(2)
              .margin({ top: 6 })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
          }
          .layoutWeight(1)
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.currentCategory = category
            if (this.onCategoryChange) {
              this.onCategoryChange(category)
            }
          })
        }, (category: NewsCategory) => category)
      }
      .width('100%')
      .height(48)
      .backgroundColor('#FFFFFF')

      // 分割线
      Column()
        .width('100%')
        .height(1)
        .backgroundColor('#EEEEEE')
    }
    .width('100%')
  }
}
