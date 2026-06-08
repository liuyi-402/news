// 新闻列表组件
import { NewsItem } from '../models/NewsModel'
import { NewsCard } from './NewsCard'

@Component
export struct NewsList {
  @Prop newsList: NewsItem[] = []
  @State isLoading: boolean = false
  onRefresh?: () => void
  onLoadMore?: () => void
  onLike?: (newsId: string) => void
  onComment?: (newsId: string) => void
  onShare?: (newsId: string) => void
  onCollect?: (newsId: string) => void

  build() {
    Column() {
      if (this.newsList.length === 0 && !this.isLoading) {
        // 空状态
        this.EmptyState()
      } else {
        // 新闻列表
        List() {
          ForEach(this.newsList, (newsItem: NewsItem) => {
            ListItem() {
              NewsCard({
                newsItem: newsItem,
                onLike: (newsId: string) => {
                  if (this.onLike) {
                    this.onLike(newsId)
                  }
                },
                onComment: (newsId: string) => {
                  if (this.onComment) {
                    this.onComment(newsId)
                  }
                },
                onShare: (newsId: string) => {
                  if (this.onShare) {
                    this.onShare(newsId)
                  }
                },
                onCollect: (newsId: string) => {
                  if (this.onCollect) {
                    this.onCollect(newsId)
                  }
                }
              })
            }
          }, (newsItem: NewsItem) => newsItem.id)

          // 加载更多指示器
          if (this.isLoading) {
            ListItem() {
              Row() {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color('#999999')

                Text('加载中...')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ left: 8 })
              }
              .width('100%')
              .height(60)
              .justifyContent(FlexAlign.Center)
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
        .edgeEffect(EdgeEffect.Spring)
        .onReachEnd(() => {
          if (!this.isLoading && this.onLoadMore) {
            this.onLoadMore()
          }
        })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  // 空状态
  @Builder
  EmptyState() {
    Column() {
      Text('📭')
        .fontSize(64)

      Text('暂无新闻')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 16 })

      Button('刷新试试')
        .fontSize(14)
        .fontColor('#FF6B6B')
        .backgroundColor('#FFE5E5')
        .borderRadius(20)
        .height(36)
        .padding({ left: 24, right: 24 })
        .margin({ top: 24 })
        .onClick(() => {
          if (this.onRefresh) {
            this.onRefresh()
          }
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
