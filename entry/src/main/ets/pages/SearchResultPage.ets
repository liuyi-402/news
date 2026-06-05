import { NewsItem, HotSearch } from '../models/NewsModel';
import { MockDataService } from '../services/MockDataService';
import { SearchHistoryService } from '../services/SearchHistoryService';
import { CommonConstants } from '../common/CommonConstants';
import { NewsCardComponent } from '../components/NewsCardComponent';
import router from '@ohos.router';

/**
 * 搜索结果页
 * 支持搜索历史、热门搜索、搜索结果展示
 */
@Entry
@Component
struct SearchResultPage {
  @State searchKeyword: string = '';
  @State searchResults: NewsItem[] = [];
  @State currentSort: number = 0; // 0: 综合, 1: 最新, 2: 最热
  @State isLoading: boolean = false;
  @State isSearching: boolean = false; // 是否正在搜索（显示结果页）
  @State searchHistory: string[] = []; // 搜索历史
  @State hotSearchList: HotSearch[] = []; // 热门搜索列表
  
  private sortOptions: string[] = ['综合', '最新', '最热'];
  
  aboutToAppear() {
    // 加载搜索历史和热门搜索
    this.loadSearchData();
    
    // 获取路由传递的搜索关键词
    const params = router.getParams() as Record<string, string>;
    if (params && params['keyword'] && params['keyword'].trim().length > 0) {
      this.searchKeyword = params['keyword'];
      this.search();
    }
  }
  
  build() {
    Column() {
      // 搜索栏
      this.SearchBar()
      
      if (this.isSearching) {
        // 搜索结果模式
        // 排序栏
        this.SortBar()
        
        // 搜索结果列表
        this.ResultList()
      } else {
        // 搜索首页模式（历史 + 热门搜索）
        this.SearchHomePage()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.BACKGROUND)
  }
  
  @Builder
  SearchBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.onBack();
        })
      
      Row({ space: CommonConstants.SPACING.SM }) {
        Image($r('app.media.ic_search'))
          .width(18)
          .height(18)
          .opacity(0.5)
        
        TextInput({ text: this.searchKeyword, placeholder: '搜索新闻、专题、作者' })
          .layoutWeight(1)
          .height(36)
          .backgroundColor(Color.Transparent)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .placeholderColor(CommonConstants.COLORS.TEXT_HINT)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.search();
          })
      }
      .layoutWeight(1)
      .height(36)
      .backgroundColor('#FFF0F0F0')
      .borderRadius(18)
      .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD })
      
      Text('搜索')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.PRIMARY)
        .onClick(() => {
          this.search();
        })
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }
  
  @Builder
  SearchHomePage() {
    Scroll() {
      Column() {
        // 搜索历史
        if (this.searchHistory.length > 0) {
          this.SearchHistorySection()
        }
        
        // 热门搜索
        this.HotSearchSection()
      }
      .width('100%')
      .padding(CommonConstants.SPACING.LG)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
  
  @Builder
  SearchHistorySection() {
    Column({ space: CommonConstants.SPACING.MD }) {
      // 标题栏
      Row() {
        Text('搜索历史')
          .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Row({ space: CommonConstants.SPACING.SM }) {
          Image($r('app.media.ic_delete'))
            .width(16)
            .height(16)
            .opacity(0.6)
          
          Text('清空')
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        }
        .onClick(() => {
          this.onClearHistory();
        })
      }
      .width('100%')
      
      // 历史标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.searchHistory, (keyword: string) => {
          Row({ space: 4 }) {
            Text(keyword)
              .fontSize(CommonConstants.FONT_SIZE.BODY)
              .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            
            Image($r('app.media.ic_close'))
              .width(14)
              .height(14)
              .opacity(0.4)
              .onClick(() => {
                this.onRemoveHistory(keyword);
              })
          }
          .padding({ left: 12, right: 8, top: 6, bottom: 6 })
          .backgroundColor(CommonConstants.COLORS.WHITE)
          .borderRadius(16)
          .margin({ right: CommonConstants.SPACING.SM, bottom: CommonConstants.SPACING.SM })
          .onClick(() => {
            this.onHistoryClick(keyword);
          })
        })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: CommonConstants.SPACING.XL })
  }
  
  @Builder
  HotSearchSection() {
    Column({ space: CommonConstants.SPACING.MD }) {
      // 标题栏
      Row() {
        Image($r('app.media.ic_hot'))
          .width(20)
          .height(20)
        
        Text('热门搜索')
          .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 6 })
      }
      .width('100%')
      
      // 热搜列表
      Column({ space: CommonConstants.SPACING.SM }) {
        ForEach(this.hotSearchList, (hotSearch: HotSearch, index: number) => {
          Row({ space: CommonConstants.SPACING.MD }) {
            // 排名
            Text(`${hotSearch.rank}`)
              .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
              .fontColor(this.getRankColor(hotSearch.rank))
              .fontWeight(FontWeight.Bold)
              .width(24)
            
            // 关键词
            Text(hotSearch.keyword)
              .fontSize(CommonConstants.FONT_SIZE.BODY)
              .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
              .layoutWeight(1)
            
            // 热度标签
            if (hotSearch.label) {
              Text(hotSearch.label)
                .fontSize(10)
                .fontColor(Color.White)
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                .backgroundColor(this.getLabelColor(hotSearch.trend))
                .borderRadius(2)
            } else {
              // 趋势图标
              Image(this.getTrendIcon(hotSearch.trend))
                .width(16)
                .height(16)
                .opacity(0.6)
            }
          }
          .width('100%')
          .height(44)
          .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD })
          .backgroundColor(CommonConstants.COLORS.WHITE)
          .borderRadius(CommonConstants.BORDER_RADIUS.SM)
          .onClick(() => {
            this.onHotSearchClick(hotSearch.keyword);
          })
        })
      }
      .width('100%')
    }
    .width('100%')
  }
  
  @Builder
  SortBar() {
    Column() {
      Row({ space: CommonConstants.SPACING.XL }) {
        ForEach(this.sortOptions, (option: string, index: number) => {
          Column({ space: 4 }) {
            Text(option)
              .fontSize(CommonConstants.FONT_SIZE.BODY)
              .fontColor(this.currentSort === index ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
              .fontWeight(this.currentSort === index ? FontWeight.Bold : FontWeight.Normal)
            
            if (this.currentSort === index) {
              Divider()
                .width(20)
                .height(2)
                .color(CommonConstants.COLORS.PRIMARY)
            }
          }
          .onClick(() => {
            this.onSortChange(index);
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      
      // 显示搜索结果数量
      if (this.searchKeyword.trim().length > 0 && !this.isLoading && this.searchResults.length > 0) {
        Text(`找到 ${this.searchResults.length} 条相关结果`)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
          .width('100%')
          .margin({ top: CommonConstants.SPACING.SM })
      }
    }
    .width('100%')
    .padding(CommonConstants.SPACING.MD)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .border({ width: { bottom: 0.5 }, color: { bottom: CommonConstants.COLORS.DIVIDER } })
  }
  
  @Builder
  ResultList() {
    if (this.isLoading) {
      // 加载状态
      Column() {
        LoadingProgress()
          .width(48)
          .height(48)
          .color(CommonConstants.COLORS.PRIMARY)
        
        Text('搜索中...')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          .margin({ top: CommonConstants.SPACING.MD })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (this.searchKeyword.trim().length === 0) {
      // 未输入关键词状态
      Column() {
        Image($r('app.media.ic_search'))
          .width(80)
          .height(80)
          .opacity(0.3)
        
        Text('输入关键词开始搜索')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          .margin({ top: CommonConstants.SPACING.MD })
        
        Text('可以搜索新闻标题、内容、作者等')
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
          .margin({ top: CommonConstants.SPACING.SM })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (this.searchResults.length === 0) {
      // 无结果状态
      Column() {
        Image($r('app.media.default_cover'))
          .width(120)
          .height(120)
          .opacity(0.3)
        
        Text('暂无搜索结果')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          .margin({ top: CommonConstants.SPACING.MD })
        
        Text('换个关键词试试吧')
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
          .margin({ top: CommonConstants.SPACING.SM })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      // 搜索结果列表
      List() {
        ForEach(this.searchResults, (news: NewsItem) => {
          ListItem() {
            NewsCardComponent({
              newsItem: news,
              onCardClick: (item: NewsItem) => {
                this.onNewsClick(item);
              }
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
  
  // ==================== 事件处理 ====================
  
  /**
   * 加载搜索数据（历史 + 热门）
   */
  private loadSearchData() {
    this.searchHistory = SearchHistoryService.getSearchHistory();
    this.hotSearchList = MockDataService.getHotSearchList();
  }
  
  /**
   * 执行搜索
   */
  private search() {
    if (this.searchKeyword.trim().length === 0) {
      return;
    }
    
    // 添加到搜索历史
    SearchHistoryService.addSearchHistory(this.searchKeyword);
    this.searchHistory = SearchHistoryService.getSearchHistory();
    
    this.isLoading = true;
    this.isSearching = true;
    
    setTimeout(() => {
      // 使用搜索方法获取结果
      this.searchResults = MockDataService.searchNews(this.searchKeyword, this.currentSort);
      this.isLoading = false;
    }, 800);
  }
  
  /**
   * 点击搜索历史
   */
  private onHistoryClick(keyword: string) {
    this.searchKeyword = keyword;
    this.search();
  }
  
  /**
   * 删除单条搜索历史
   */
  private onRemoveHistory(keyword: string) {
    SearchHistoryService.removeSearchHistory(keyword);
    this.searchHistory = SearchHistoryService.getSearchHistory();
  }
  
  /**
   * 清空搜索历史
   */
  private onClearHistory() {
    SearchHistoryService.clearSearchHistory();
    this.searchHistory = [];
  }
  
  /**
   * 点击热门搜索
   */
  private onHotSearchClick(keyword: string) {
    this.searchKeyword = keyword;
    this.search();
  }
  
  private onSortChange(index: number) {
    if (this.currentSort !== index) {
      this.currentSort = index;
      // 重新搜索
      this.search();
    }
  }
  
  private onBack() {
    if (this.isSearching) {
      // 如果在搜索结果页，返回搜索首页
      this.isSearching = false;
      this.searchResults = [];
      this.searchKeyword = '';
    } else {
      // 否则返回上一页
      router.back();
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
  
  // ==================== 辅助方法 ====================
  
  /**
   * 获取排名颜色
   */
  private getRankColor(rank: number): ResourceColor {
    if (rank === 1) {
      return '#FF6B6B'; // 红色
    } else if (rank === 2) {
      return '#FFA94D'; // 橙色
    } else if (rank === 3) {
      return '#FFD93D'; // 黄色
    }
    return CommonConstants.COLORS.TEXT_SECONDARY;
  }
  
  /**
   * 获取标签颜色
   */
  private getLabelColor(trend: string): ResourceColor {
    if (trend === 'hot') {
      return '#FF6B6B'; // 红色 - 热
    } else if (trend === 'new') {
      return '#4DABF7'; // 蓝色 - 新
    } else if (trend === 'up') {
      return '#51CF66'; // 绿色 - 升
    }
    return CommonConstants.COLORS.TEXT_SECONDARY;
  }
  
  /**
   * 获取趋势图标
   */
  private getTrendIcon(trend: string): Resource {
    if (trend === 'up') {
      return $r('app.media.ic_arrow_up');
    } else if (trend === 'down') {
      return $r('app.media.ic_arrow_down');
    }
    return $r('app.media.ic_hot');
  }
}
