import { NewsItem } from '../models/NewsModel';
import { MockDataService } from '../services/MockDataService';
import { NetworkNewsService } from '../services/NetworkNewsService';
import { CommonConstants } from '../common/CommonConstants';
import { NewsCardComponent } from '../components/NewsCardComponent';
import router from '@ohos.router';

/**
 * 首页 - 新闻信息流页面
 * 完全复刻微博首页样式
 */
@Component
export struct HomePage {
  @State currentCategory: string = '要闻';
  @State newsList: NewsItem[] = [];
  @State currentPage: number = 1;
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State hasMore: boolean = true;
  
  private scroller: Scroller = new Scroller();
  private categoryScroller: Scroller = new Scroller();
  
  aboutToAppear() {
    this.loadNewsList();
  }
  
  build() {
    Column() {
      // 顶部栏
      this.HeaderBar()
      
      // 分类标签栏
      this.CategoryBar()
      
      // 新闻列表
      this.NewsList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.BACKGROUND)
  }
  
  @Builder
  HeaderBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 标题
      Text('新闻资讯')
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
      
      // 搜索按钮
      Image($r('app.media.ic_search'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.onSearchClick();
        })
      
      // 刷新按钮
      Image($r('app.media.ic_refresh'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.onRefresh();
        })
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }
  
  @Builder
  CategoryBar() {
    Scroll(this.categoryScroller) {
      Row({ space: CommonConstants.SPACING.LG }) {
        ForEach(CommonConstants.NEWS_CATEGORIES, (category: string) => {
          Text(category)
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(this.currentCategory === category ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
            .fontWeight(this.currentCategory === category ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .border({
              width: { bottom: this.currentCategory === category ? 2 : 0 },
              color: { bottom: CommonConstants.COLORS.PRIMARY }
            })
            .onClick(() => {
              this.onCategoryChange(category);
            })
        })
      }
      .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    }
    .width('100%')
    .height(44)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .border({ width: { bottom: 0.5 }, color: { bottom: CommonConstants.COLORS.DIVIDER } })
  }
  
  @Builder
  NewsList() {
    if (this.isLoading && this.newsList.length === 0) {
      // 加载中状态
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
    } else {
      // 新闻列表 - 添加下拉刷新
      Refresh({ refreshing: $$this.isRefreshing }) {
        List({ scroller: this.scroller }) {
          ForEach(this.newsList, (news: NewsItem, index: number) => {
            ListItem() {
              NewsCardComponent({
                newsItem: news,
                onCardClick: (item: NewsItem) => {
                  this.onNewsClick(item);
                },
                onLikeClick: (item: NewsItem) => {
                  this.onLikeClick(index);
                },
                onCommentClick: (item: NewsItem) => {
                  this.onCommentClick(item);
                },
                onShareClick: (item: NewsItem) => {
                  this.onShareClick(item);
                },
                onCollectClick: (item: NewsItem) => {
                  this.onCollectClick(index);
                }
              })
            }
          })
          
          // 加载更多提示
          if (this.hasMore) {
            ListItem() {
              Row() {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color(CommonConstants.COLORS.PRIMARY)
                
                Text('加载更多...')
                  .fontSize(CommonConstants.FONT_SIZE.CAPTION)
                  .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
                  .margin({ left: CommonConstants.SPACING.SM })
              }
              .width('100%')
              .height(50)
              .justifyContent(FlexAlign.Center)
            }
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onReachEnd(() => {
          this.onLoadMore();
        })
      }
      .width('100%')
      .layoutWeight(1)
      .onRefreshing(() => {
        this.onRefresh();
      })
    }
  }
  
  // ==================== 事件处理 ====================
  
  /**
   * 点击搜索按钮，跳转到搜索页面
   */
  private onSearchClick() {
    console.log('HomePage: 点击搜索按钮');
    router.pushUrl({
      url: 'pages/SearchResultPage',
      params: {
        keyword: ''
      }
    }).then(() => {
      console.log('HomePage: 跳转到搜索页面成功');
    }).catch((error: Error) => {
      console.error('HomePage: 跳转到搜索页面失败:', error.message);
    });
  }
  
  private async loadNewsList() {
    this.isLoading = true;
    
    try {
      // 优先从网络获取新闻
      const networkNews = await NetworkNewsService.getNews(this.currentCategory, this.currentPage);
      
      if (networkNews.length > 0) {
        // 使用网络新闻数据
        this.newsList = networkNews;
        this.isLoading = false;
        this.hasMore = this.currentPage < 5;
        console.log(`HomePage: 成功加载${networkNews.length}条网络新闻`);
      } else {
        // 网络获取失败，使用Mock数据
        setTimeout(() => {
          this.newsList = MockDataService.getNewsList(this.currentCategory, this.currentPage);
          this.isLoading = false;
          this.hasMore = this.currentPage < 5;
          console.log('HomePage: 使用Mock数据');
        }, 500);
      }
    } catch (error) {
      console.error('HomePage: 加载新闻失败', error);
      // 出错时使用Mock数据
      setTimeout(() => {
        this.newsList = MockDataService.getNewsList(this.currentCategory, this.currentPage);
        this.isLoading = false;
        this.hasMore = this.currentPage < 5;
      }, 500);
    }
  }
  
  private onCategoryChange(category: string) {
    if (this.currentCategory !== category) {
      this.currentCategory = category;
      this.currentPage = 1;
      this.newsList = [];
      this.loadNewsList();
    }
  }
  
  private async onRefresh() {
    if (this.isRefreshing) {
      return; // 防止重复刷新
    }
    
    this.isRefreshing = true;
    this.currentPage = 1;
    
    try {
      // 优先从网络获取新闻
      const networkNews = await NetworkNewsService.getNews(this.currentCategory, this.currentPage);
      
      if (networkNews.length > 0) {
        this.newsList = networkNews;
        this.isRefreshing = false;
        this.hasMore = true;
        console.log(`HomePage: 刷新成功，加载${networkNews.length}条网络新闻`);
      } else {
        // 网络获取失败，使用Mock数据
        setTimeout(() => {
          this.newsList = MockDataService.getNewsList(this.currentCategory, this.currentPage);
          this.isRefreshing = false;
          this.hasMore = true;
        }, 1000);
      }
    } catch (error) {
      console.error('HomePage: 刷新失败', error);
      setTimeout(() => {
        this.newsList = MockDataService.getNewsList(this.currentCategory, this.currentPage);
        this.isRefreshing = false;
        this.hasMore = true;
      }, 1000);
    }
  }
  
  private async onLoadMore() {
    if (this.isLoading || !this.hasMore) {
      return;
    }
    
    this.isLoading = true;
    this.currentPage++;
    
    try {
      // 优先从网络获取新闻
      const networkNews = await NetworkNewsService.getNews(this.currentCategory, this.currentPage);
      
      if (networkNews.length > 0) {
        this.newsList = [...this.newsList, ...networkNews];
        this.isLoading = false;
        this.hasMore = this.currentPage < 5;
        console.log(`HomePage: 加载更多成功，新增${networkNews.length}条网络新闻`);
      } else {
        // 网络获取失败，使用Mock数据
        setTimeout(() => {
          const newNews = MockDataService.getNewsList(this.currentCategory, this.currentPage);
          this.newsList = [...this.newsList, ...newNews];
          this.isLoading = false;
          this.hasMore = this.currentPage < 5;
        }, 800);
      }
    } catch (error) {
      console.error('HomePage: 加载更多失败', error);
      setTimeout(() => {
        const newNews = MockDataService.getNewsList(this.currentCategory, this.currentPage);
        this.newsList = [...this.newsList, ...newNews];
        this.isLoading = false;
        this.hasMore = this.currentPage < 5;
      }, 800);
    }
  }
  
  private onNewsClick(news: NewsItem) {
    // 跳转到新闻详情页，传递完整的新闻对象
    router.pushUrl({
      url: 'pages/NewsDetailPage',
      params: {
        newsId: news.id,
        newsItem: news  // 传递完整的新闻对象
      }
    }).catch((error: Error) => {
      console.error('跳转新闻详情失败:', error.message);
    });
  }
  
  private onLikeClick(index: number) {
    const news = this.newsList[index];
    news.isLiked = !news.isLiked;
    news.likeCount += news.isLiked ? 1 : -1;
  }
  
  private onCommentClick(news: NewsItem) {
    // TODO: 跳转到评论页
    console.log(`点击评论: ${news.title}`);
  }
  
  private onShareClick(news: NewsItem) {
    // TODO: 显示分享菜单
    console.log(`点击分享: ${news.title}`);
  }
  
  private onCollectClick(index: number) {
    const news = this.newsList[index];
    news.isCollected = !news.isCollected;
    news.collectCount += news.isCollected ? 1 : -1;
  }
}
