import { AuthorInfo, NewsItem, NewsType } from '../models/NewsModel';
import { MockDataService } from '../services/MockDataService';
import { CommonConstants } from '../common/CommonConstants';
import router from '@ohos.router';

/**
 * 用户主页 - 显示其他用户的个人信息和发布内容
 * 参考抖音用户主页样式
 */
@Entry
@Component
struct UserProfilePage {
  @State userInfo: AuthorInfo | null = null;
  @State userNews: NewsItem[] = [];
  @State isFollowing: boolean = false;
  @State avatarLoadFailed: boolean = false;
  @State currentTab: number = 0; // 0: 作品, 1: 喜欢

  aboutToAppear() {
    // 从路由参数获取用户信息
    const params = router.getParams() as Record<string, Object>;
    if (params && params['user']) {
      this.userInfo = params['user'] as AuthorInfo;
      this.loadUserNews();
      // 模拟关注状态
      this.isFollowing = Math.random() > 0.5;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderBar()

      Scroll() {
        Column() {
          // 用户信息区域
          this.UserInfoSection()

          // 数据统计
          this.StatisticsSection()

          // Tab栏
          this.TabBar()

          // 内容列表
          this.ContentList()
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.BACKGROUND)
  }

  @Builder
  HeaderBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 返回按钮
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .onClick(() => {
          router.back();
        })

      Text(this.userInfo?.name || '用户主页')
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)

      // 更多按钮
      Image($r('app.media.ic_more'))
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }

  @Builder
  UserInfoSection() {
    Column({ space: CommonConstants.SPACING.LG }) {
      // 头像和基本信息
      Row({ space: CommonConstants.SPACING.LG }) {
        // 头像
        if (!this.avatarLoadFailed && this.userInfo) {
          Image(this.userInfo!.avatar)
            .width(80)
            .height(80)
            .borderRadius(40)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              this.avatarLoadFailed = true;
            })
        } else {
          Image($r('app.media.default_avatar'))
            .width(80)
            .height(80)
            .borderRadius(40)
            .objectFit(ImageFit.Cover)
        }

        // 用户名和简介
        Column({ space: 8 }) {
          Text(this.userInfo?.name || '用户')
            .fontSize(CommonConstants.FONT_SIZE.TITLE)
            .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)

          if (this.userInfo?.isVerified) {
            Row({ space: 4 }) {
              Image($r('app.media.ic_verified'))
                .width(16)
                .height(16)
              Text('已认证')
                .fontSize(CommonConstants.FONT_SIZE.CAPTION)
                .fontColor(CommonConstants.COLORS.PRIMARY)
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 操作按钮
      Row({ space: CommonConstants.SPACING.MD }) {
        // 关注按钮
        Button(this.isFollowing ? '已关注' : '关注')
          .width(120)
          .height(36)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(this.isFollowing ? CommonConstants.COLORS.TEXT_SECONDARY : CommonConstants.COLORS.WHITE)
          .backgroundColor(this.isFollowing ? '#F0F0F0' : CommonConstants.COLORS.PRIMARY)
          .borderRadius(18)
          .onClick(() => {
            this.toggleFollow();
          })

        // 私信按钮
        Button('私信')
          .width(80)
          .height(36)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.PRIMARY)
          .backgroundColor('#E8F0FF')
          .borderRadius(18)
          .onClick(() => {
            this.sendMessage();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(CommonConstants.SPACING.LG)
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }

  @Builder
  StatisticsSection() {
    Row() {
      this.StatItem('获赞', this.getRandomCount())
      Divider().vertical(true).height(20).color(CommonConstants.COLORS.DIVIDER)
      this.StatItem('关注', this.getRandomCount())
      Divider().vertical(true).height(20).color(CommonConstants.COLORS.DIVIDER)
      this.StatItem('粉丝', this.getRandomCount())
    }
    .width('100%')
    .height(60)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .justifyContent(FlexAlign.SpaceEvenly)
    .margin({ top: 0.5 })
  }

  @Builder
  StatItem(label: string, count: number) {
    Column({ space: 4 }) {
      Text(count.toString())
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)

      Text(label)
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
    }
  }

  @Builder
  TabBar() {
    Row() {
      ForEach(['作品', '喜欢'], (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize(CommonConstants.FONT_SIZE.BODY)
            .fontColor(this.currentTab === index ? CommonConstants.COLORS.TEXT_PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
            .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)

          if (this.currentTab === index) {
            Column()
              .width(20)
              .height(2)
              .backgroundColor(CommonConstants.COLORS.PRIMARY)
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .padding({ top: 12, bottom: 12 })
        .onClick(() => {
          this.currentTab = index;
        })
      })
    }
    .width('100%')
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .margin({ top: CommonConstants.SPACING.SM })
  }

  @Builder
  ContentList() {
    if (this.userNews.length === 0) {
      Column() {
        Text('暂无内容')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
          .margin({ top: 60 })
      }
      .width('100%')
      .height(200)
    } else {
      // 瀑布流布局
      Column() {
        ForEach(this.userNews, (news: NewsItem) => {
          this.NewsCard(news)
        })
      }
      .width('100%')
      .padding(CommonConstants.SPACING.MD)
    }
  }

  @Builder
  NewsCard(news: NewsItem) {
    Row({ space: CommonConstants.SPACING.MD }) {
      // 封面图
      Image(news.coverImages[0])
        .width(100)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      // 内容信息
      Column({ space: 6 }) {
        Text(news.title)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 12 }) {
          Text(`${news.likeCount} 赞`)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)

          Text(`${news.commentCount} 评论`)
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(CommonConstants.SPACING.MD)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .borderRadius(CommonConstants.BORDER_RADIUS.MD)
    .margin({ bottom: CommonConstants.SPACING.SM })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/NewsDetailPage',
        params: { newsId: news.id }
      });
    })
  }

  // ==================== 辅助方法 ====================

  private getRandomCount(): number {
    return Math.floor(Math.random() * 10000);
  }

  private loadUserNews() {
    // 模拟加载用户发布的新闻
    this.userNews = MockDataService.getNewsList(NewsType.SINGLE_IMAGE);
  }

  // ==================== 事件处理 ====================

  private toggleFollow() {
    this.isFollowing = !this.isFollowing;
    console.log(this.isFollowing ? '关注用户' : '取消关注');
  }

  private sendMessage() {
    console.log('发送私信');
    // TODO: 跳转到聊天页面
  }
}
