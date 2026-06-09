import { HotSearch, Topic } from '../models/NewsModel';
import { MockDataService } from '../services/MockDataService';
import { CommonConstants } from '../common/CommonConstants';
import router from '@ohos.router';

/**
 * 发现页 - 热搜和搜索
 * 复刻微博发现页样式
 */
@Component
export struct DiscoverPage {
  @State hotSearchList: HotSearch[] = [];
  @State topicList: Topic[] = [];
  @State currentTab: number = 0; // 0: 热搜榜, 1: 热榜, 2: 新榜
  @State topicImageLoadFailed: Map<string, boolean> = new Map(); // 专题图片加载失败标志
  
  private tabs: string[] = ['热搜榜', '热榜', '新榜'];
  
  aboutToAppear() {
    this.loadData();
  }
  
  build() {
    Column() {
      // 顶部搜索栏
      this.SearchBar()
      
      // 内容区域
      Scroll() {
        Column({ space: CommonConstants.SPACING.MD }) {
          // 热搜榜单
          this.HotSearchSection()
          
          // 推荐专题
          this.TopicSection()
        }
        .width('100%')
        .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD, bottom: CommonConstants.SPACING.XXL })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .friction(0.6)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.BACKGROUND)
  }
  
  @Builder
  SearchBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 标题
      Text('发现')
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
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }
  
  @Builder
  HotSearchSection() {
    Column() {
      // 标题栏
      Row({ space: CommonConstants.SPACING.SM }) {
        Image($r('app.media.ic_hot'))
          .width(20)
          .height(20)
        
        Text(this.tabs[this.currentTab])
          .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
      }
      .width('100%')
      .padding(CommonConstants.SPACING.MD)
      
      // Tab栏
      Row({ space: CommonConstants.SPACING.LG }) {
        ForEach(this.tabs, (tab: string, index: number) => {
          Column({ space: 4 }) {
            Text(tab)
              .fontSize(CommonConstants.FONT_SIZE.BODY)
              .fontColor(this.currentTab === index ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
            
            // 下划线指示器
            if (this.currentTab === index) {
              Divider()
                .width(20)
                .height(2)
                .color(CommonConstants.COLORS.PRIMARY)
            }
          }
          .onClick(() => {
            this.onTabChange(index);
          })
        })
      }
      .width('100%')
      .padding({ left: CommonConstants.SPACING.MD, bottom: CommonConstants.SPACING.SM })
      
      // 热搜列表
      Column({ space: 0 }) {
        ForEach(this.hotSearchList.slice(0, 10), (item: HotSearch) => {
          this.HotSearchItem(item)
        })
      }
    }
    .width('100%')
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .borderRadius(CommonConstants.BORDER_RADIUS.MD)
    .margin({ top: CommonConstants.SPACING.MD })
  }
  
  @Builder
  HotSearchItem(item: HotSearch) {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 排名
      Text(`${item.rank}`)
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(item.rank <= 3 ? CommonConstants.COLORS.DANGER : CommonConstants.COLORS.TEXT_SECONDARY)
        .fontWeight(FontWeight.Bold)
        .width(24)
      
      // 关键词
      Column({ space: 2 }) {
        Row({ space: 4 }) {
          Text(item.keyword)
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .layoutWeight(1)
          
          // 标签
          if (item.label) {
            Text(item.label)
              .fontSize(CommonConstants.FONT_SIZE.SMALL)
              .fontColor(CommonConstants.COLORS.WHITE)
              .backgroundColor(item.label === '爆' ? CommonConstants.COLORS.DANGER : CommonConstants.COLORS.PRIMARY)
              .borderRadius(2)
              .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          }
        }
        
        // 热度
        Text(`${this.formatHeat(item.heat)}热度`)
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // 趋势图标
      if (item.trend === 'up') {
        Image($r('app.media.ic_trend_up'))
          .width(16)
          .height(16)
      } else if (item.trend === 'down') {
        Image($r('app.media.ic_trend_down'))
          .width(16)
          .height(16)
      } else if (item.trend === 'new') {
        Text('新')
          .fontSize(CommonConstants.FONT_SIZE.SMALL)
          .fontColor(CommonConstants.COLORS.PRIMARY)
      } else if (item.trend === 'hot') {
        Text('热')
          .fontSize(CommonConstants.FONT_SIZE.SMALL)
          .fontColor(CommonConstants.COLORS.DANGER)
      }
    }
    .width('100%')
    .padding(CommonConstants.SPACING.MD)
    .onClick(() => {
      this.onHotSearchClick(item);
    })
  }
  
  @Builder
  TopicSection() {
    Column() {
      // 标题栏
      Row({ space: CommonConstants.SPACING.SM }) {
        Image($r('app.media.ic_topic'))
          .width(20)
          .height(20)
        
        Text('推荐专题')
          .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
      }
      .width('100%')
      .padding(CommonConstants.SPACING.MD)
      
      // 专题列表
      Scroll() {
        Row({ space: CommonConstants.SPACING.MD }) {
          ForEach(this.topicList, (topic: Topic) => {
            this.TopicCard(topic)
          })
        }
        .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .borderRadius(CommonConstants.BORDER_RADIUS.MD)
    .margin({ top: CommonConstants.SPACING.MD })
  }
  
  @Builder
  TopicCard(topic: Topic) {
    Column({ space: CommonConstants.SPACING.SM }) {
      // 封面 - 使用网络图片
      if (!this.topicImageLoadFailed.get(topic.id)) {
        Image(topic.cover)
          .width(120)
          .height(80)
          .borderRadius(CommonConstants.BORDER_RADIUS.SM)
          .objectFit(ImageFit.Cover)
          .onError(() => {
            console.log('DiscoverPage: 专题图片加载失败，使用默认图片');
            this.topicImageLoadFailed.set(topic.id, true);
          })
      } else {
        Image($r('app.media.default_cover'))
          .width(120)
          .height(80)
          .borderRadius(CommonConstants.BORDER_RADIUS.SM)
          .objectFit(ImageFit.Cover)
      }
      
      // 名称
      Text(topic.name)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      
      // 关注数
      Text(`${topic.followCount}人关注`)
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(CommonConstants.COLORS.TEXT_HINT)
    }
    .width(120)
    .onClick(() => {
      this.onTopicClick(topic);
    })
  }
  
  // ==================== 事件处理 ====================
  
  /**
   * 点击搜索按钮，跳转到搜索页面
   */
  private onSearchClick() {
    console.log('DiscoverPage: 点击搜索按钮');
    router.pushUrl({
      url: 'pages/SearchResultPage',
      params: {
        keyword: ''
      }
    }).then(() => {
      console.log('DiscoverPage: 跳转到搜索页面成功');
    }).catch((error: Error) => {
      console.error('DiscoverPage: 跳转到搜索页面失败:', error.message);
    });
  }
  
  /**
   * 切换榜单Tab
   */
  private onTabChange(index: number) {
    if (this.currentTab !== index) {
      this.currentTab = index;
      // 重新加载对应榜单的数据
      this.hotSearchList = MockDataService.getHotSearchList(index);
    }
  }
  
  private loadData() {
    // 默认加载热搜榜数据
    this.hotSearchList = MockDataService.getHotSearchList(0);
    this.topicList = MockDataService.getTopicList();
  }
  
  /**
   * 点击热搜项，跳转到搜索结果页
   */
  private onHotSearchClick(item: HotSearch) {
    console.log('DiscoverPage: 点击热搜项:', item.keyword);
    // 跳转到搜索结果页，传递热搜关键词
    router.pushUrl({
      url: 'pages/SearchResultPage',
      params: {
        keyword: item.keyword
      }
    }).then(() => {
      console.log('DiscoverPage: 跳转到搜索页面成功');
    }).catch((error: Error) => {
      console.error('DiscoverPage: 跳转搜索页面失败:', error.message);
    });
  }
  
  private onTopicClick(topic: Topic) {
    console.log(`DiscoverPage: 点击专题: ${topic.name}`);
    // 跳转到专题详情页，传递专题ID
    router.pushUrl({
      url: 'pages/TopicDetailPage',
      params: {
        topicId: topic.id
      }
    }).then(() => {
      console.log('DiscoverPage: 跳转到专题详情页成功');
    }).catch((error: Error) => {
      console.error('DiscoverPage: 跳转到专题详情页失败:', error.message);
    });
  }
  
  /**
   * 格式化热度数值
   */
  private formatHeat(heat: number): string {
    if (heat >= 10000) {
      return `${(heat / 10000).toFixed(1)}万`;
    }
    return heat.toString();
  }
}
