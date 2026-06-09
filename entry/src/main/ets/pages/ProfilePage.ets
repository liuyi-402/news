import { UserInfo } from '../models/NewsModel';
import { MockDataService } from '../services/MockDataService';
import { PublishService } from '../services/PublishService';
import { CommonConstants } from '../common/CommonConstants';
import { router } from '@kit.ArkUI';

/**
 * 菜单项接口
 */
interface MenuItem {
  title: string;
  count?: string;
  route: string;
}

/**
 * 我的页面 - 个人中心
 * 复刻微博个人中心样式
 */
@Component
export struct ProfilePage {
  @State userInfo: UserInfo | null = null;
  @State isLoggedIn: boolean = false;
  @State avatarLoadFailed: boolean = false; // 头像加载失败标志
  
  private menuItems: MenuItem[] = [
    { title: '我的发布', count: '128', route: 'MyPublish' },
    { title: '我的收藏', count: '167', route: 'MyCollect' },
    { title: '阅读历史', route: 'History' },
    { title: '意见反馈', route: 'Feedback' },
    { title: '设置', route: 'Setting' },
    { title: '关于我们', route: 'About' }
  ];
  
  aboutToAppear() {
    this.loadUserInfo();
    // 更新我的发布数量
    this.updatePublishCount();
  }
  
  // 更新我的发布数量
  private updatePublishCount() {
    const count = PublishService.getPublishCount();
    this.menuItems[0].count = count.toString();
  }
  
  build() {
    Column() {
      // 顶部栏
      this.HeaderBar()
      
      Scroll() {
        Column({ space: CommonConstants.SPACING.MD }) {
          if (this.isLoggedIn && this.userInfo) {
            // 用户信息卡片
            this.UserInfoCard()
            
            // 数据统计
            this.StatisticsCard()
            
            // 功能菜单
            this.MenuList()
            
            // 退出登录
            this.LogoutButton()
          } else {
            // 未登录状态
            this.LoginPrompt()
          }
        }
        .width('100%')
        .padding(CommonConstants.SPACING.MD)
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
  HeaderBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      Text('我的')
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
      
      // 设置按钮
      Image($r('app.media.ic_setting'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.navigateTo('Setting');
        })
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }
  
  @Builder
  UserInfoCard() {
    Row({ space: CommonConstants.SPACING.LG }) {
      // 头像 - 使用网络头像
      Stack() {
        if (!this.avatarLoadFailed && this.userInfo?.avatar) {
          Image(this.userInfo.avatar)
            .width(72)
            .height(72)
            .borderRadius(36)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              console.log('ProfilePage: 头像加载失败，使用默认头像');
              this.avatarLoadFailed = true;
            })
        } else {
          Image($r('app.media.default_avatar'))
            .width(72)
            .height(72)
            .borderRadius(36)
            .objectFit(ImageFit.Cover)
        }
        
        // 认证标识
        if (this.userInfo?.isVerified) {
          Image($r('app.media.ic_verified'))
            .width(20)
            .height(20)
            .position({ x: '100%', y: '100%' })
            .translate({ x: -10, y: -10 })
        }
      }
      .width(72)
      .height(72)
      
      // 用户信息
      Column({ space: 4 }) {
        Text(this.userInfo?.name || '用户昵称')
          .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
        
        Text(this.userInfo?.signature || '这个人很懒，什么都没写')
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Row({ space: CommonConstants.SPACING.SM }) {
          if (this.userInfo?.gender) {
            Image(this.userInfo.gender === '男' ? $r('app.media.ic_male') : $r('app.media.ic_female'))
              .width(14)
              .height(14)
          }
          
          if (this.userInfo?.location) {
            Text(this.userInfo.location)
              .fontSize(CommonConstants.FONT_SIZE.CAPTION)
              .fontColor(CommonConstants.COLORS.TEXT_HINT)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // 编辑按钮
      Image($r('app.media.ic_edit'))
        .width(20)
        .height(20)
        .onClick(() => {
          this.navigateTo('EditProfile');
        })
    }
    .width('100%')
    .padding(CommonConstants.SPACING.LG)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .borderRadius(CommonConstants.BORDER_RADIUS.LG)
  }
  
  @Builder
  StatisticsCard() {
    Row() {
      this.StatItem('发布', this.userInfo?.publishCount || 0, () => {
        this.navigateTo('MyPublish');
      })
      
      Divider()
        .vertical(true)
        .height(40)
        .color(CommonConstants.COLORS.DIVIDER)
      
      this.StatItem('关注', this.userInfo?.followCount || 0, () => {
        this.navigateTo('Follow');
      })
      
      Divider()
        .vertical(true)
        .height(40)
        .color(CommonConstants.COLORS.DIVIDER)
      
      this.StatItem('粉丝', this.userInfo?.fansCount || 0, () => {
        this.navigateTo('Fans');
      })
      
      Divider()
        .vertical(true)
        .height(40)
        .color(CommonConstants.COLORS.DIVIDER)
      
      this.StatItem('获赞', this.userInfo?.likeCount || 0, () => {
        this.navigateTo('Liked');
      })
    }
    .width('100%')
    .height(80)
    .backgroundColor(CommonConstants.COLORS.WHITE)
    .borderRadius(CommonConstants.BORDER_RADIUS.LG)
    .justifyContent(FlexAlign.SpaceEvenly)
  }
  
  @Builder
  StatItem(label: string, count: number, onClick: () => void) {
    Column({ space: 4 }) {
      Text(this.formatCount(count))
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
      
      Text(label)
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
    }
    .onClick(() => onClick())
  }
  
  @Builder
  MenuList() {
    Column({ space: 0 }) {
      ForEach(this.menuItems, (item: MenuItem, index: number) => {
        Column() {
          Row({ space: CommonConstants.SPACING.MD }) {
            Image(this.getMenuIcon(index))
              .width(24)
              .height(24)
            
            Text(item.title)
              .fontSize(CommonConstants.FONT_SIZE.BODY)
              .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
              .layoutWeight(1)
            
            if (item.count) {
              Text(item.count)
                .fontSize(CommonConstants.FONT_SIZE.BODY)
                .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
            }
            
            Image($r('app.media.ic_arrow_right'))
              .width(16)
              .height(16)
              .opacity(0.5)
          }
          .width('100%')
          .height(56)
          .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
          
          if (index < this.menuItems.length - 1) {
            Divider()
              .color(CommonConstants.COLORS.DIVIDER)
              .margin({ left: 56 })
          }
        }
        .width('100%')
        .backgroundColor(CommonConstants.COLORS.WHITE)
        .onClick(() => {
          this.navigateTo(item.route);
        })
      })
    }
    .width('100%')
    .borderRadius(CommonConstants.BORDER_RADIUS.LG)
  }
  
  @Builder
  LogoutButton() {
    Button('退出登录')
      .width('100%')
      .height(48)
      .fontSize(CommonConstants.FONT_SIZE.BODY)
      .fontColor(CommonConstants.COLORS.DANGER)
      .backgroundColor(CommonConstants.COLORS.WHITE)
      .borderRadius(CommonConstants.BORDER_RADIUS.LG)
      .onClick(() => {
        this.onLogout();
      })
  }
  
  @Builder
  LoginPrompt() {
    Column({ space: CommonConstants.SPACING.LG }) {
      Image($r('app.media.ic_not_login'))
        .width(120)
        .height(120)
      
      Text('登录后查看更多内容')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
      
      Button('立即登录')
        .width(200)
        .height(44)
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.WHITE)
        .backgroundColor(CommonConstants.COLORS.PRIMARY)
        .borderRadius(CommonConstants.BORDER_RADIUS.ROUND)
        .onClick(() => {
          this.navigateTo('Login');
        })
    }
    .width('100%')
    .height(400)
    .justifyContent(FlexAlign.Center)
  }
  
  // ==================== 事件处理 ====================
  
  private loadUserInfo() {
    // 模拟已登录状态
    this.isLoggedIn = true;
    this.userInfo = MockDataService.getUserInfo();
  }
  
  private formatCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    }
    return count.toString();
  }
  
  private getMenuIcon(index: number): Resource {
    switch (index) {
      case 0:
        return $r('app.media.ic_my_publish');
      case 1:
        return $r('app.media.ic_my_collect');
      case 2:
        return $r('app.media.ic_history');
      case 3:
        return $r('app.media.ic_feedback');
      case 4:
        return $r('app.media.ic_setting');
      case 5:
        return $r('app.media.ic_about');
      default:
        return $r('app.media.ic_about');
    }
  }
  
  private navigateTo(route: string) {
    console.log(`跳转到: ${route}`);
    
    switch (route) {
      case 'MyPublish':
        // 跳转到我的发布页面
        router.pushUrl({
          url: 'pages/MyPublishPage'
        }).catch((err: Error) => {
          console.error(`跳转失败: ${err.message}`);
        });
        break;
      case 'Setting':
        // 跳转到设置页面
        router.pushUrl({
          url: 'pages/SettingPage'
        }).catch((err: Error) => {
          console.error(`跳转失败: ${err.message}`);
        });
        break;
      case 'Login':
        // 跳转到登录页面
        router.pushUrl({
          url: 'pages/LoginPage'
        }).catch((err: Error) => {
          console.error(`跳转失败: ${err.message}`);
        });
        break;
      default:
        console.log(`未实现的路由: ${route}`);
        break;
    }
  }
  
  private onLogout() {
    // TODO: 显示确认对话框并退出登录
    console.log('退出登录');
    this.isLoggedIn = false;
    this.userInfo = null;
  }
}
