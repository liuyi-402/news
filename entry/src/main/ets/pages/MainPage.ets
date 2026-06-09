import { HomePage } from './HomePage';
import { DiscoverPage } from './DiscoverPage';
import { PublishPage } from './PublishPage';
import { MessagePage } from './MessagePage';
import { ProfilePage } from './ProfilePage';
import { TabBarComponent } from '../components/TabBarComponent';
import { CommonConstants } from '../common/CommonConstants';

/**
 * 主页面 - 包含底部导航和页面切换
 * 完全复刻微博主页面结构
 */
@Component
export struct MainPage {
  @State currentIndex: number = 0;
  
  build() {
    Column() {
      // 页面内容区域（占满剩余空间）
      Column() {
        // 根据当前索引显示对应页面
        if (this.currentIndex === 0) {
          HomePage()
        } else if (this.currentIndex === 1) {
          DiscoverPage()
        } else if (this.currentIndex === 2) {
          PublishPage()
        } else if (this.currentIndex === 3) {
          MessagePage()
        } else if (this.currentIndex === 4) {
          ProfilePage()
        }
      }
      .width('100%')
      .layoutWeight(1) // 占据剩余空间
      
      // 底部导航栏（固定在底部）
      TabBarComponent({
        currentIndex: this.currentIndex,
        onTabChange: (index: number) => {
          this.onTabChange(index);
        }
      })
    }
    .width('100%')
    .height('100%')
  }
  
  // ==================== 事件处理 ====================
  
  private onTabChange(index: number) {
    this.currentIndex = index;
  }
}
