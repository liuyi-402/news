// 轮播Banner组件
import { BannerItem } from '../models/NewsModel'

@Component
export struct BannerCarousel {
  @Prop banners: BannerItem[] = []
  @State currentIndex: number = 0
  private swiperController: SwiperController = new SwiperController()

  build() {
    Column() {
      if (this.banners.length > 0) {
        Stack({ alignContent: Alignment.Bottom }) {
          // 轮播图
          Swiper(this.swiperController) {
            ForEach(this.banners, (banner: BannerItem) => {
              Stack() {
                // 图片
                Image(banner.image)
                  .width('100%')
                  .height(180)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)

                // 渐变遮罩
                Column()
                  .width('100%')
                  .height(60)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(0,0,0,0)', 0.0], ['rgba(0,0,0,0.6)', 1.0]]
                  })
                  .position({ x: 0, y: 120 })

                // 标题
                Text(banner.title)
                  .width('90%')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .position({ x: 16, y: 140 })
              }
              .width('100%')
              .height(180)
              .onClick(() => {
                console.info(`Banner clicked: ${banner.id}`)
              })
            }, (banner: BannerItem) => banner.id)
          }
          .index(this.currentIndex)
          .autoPlay(true)
          .interval(3000)
          .indicator(false)
          .loop(true)
          .onChange((index: number) => {
            this.currentIndex = index
          })

          // 自定义指示器
          Row() {
            ForEach(this.banners, (banner: BannerItem, index: number) => {
              Column()
                .width(index === this.currentIndex ? 20 : 8)
                .height(8)
                .backgroundColor(index === this.currentIndex ? '#FFFFFF' : 'rgba(255,255,255,0.5)')
                .borderRadius(4)
                .margin({ left: 4, right: 4 })
                .onClick(() => {
                  this.swiperController.changeIndex(index)
                })
            }, (banner: BannerItem) => banner.id)
          }
          .margin({ bottom: 12 })
        }
        .width('100%')
        .height(180)
        .padding({ left: 16, right: 16 })
      } else {
        // 加载占位
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#999999')
        }
        .width('100%')
        .height(180)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .margin({ left: 16, right: 16 })
      }
    }
    .width('100%')
  }
}
