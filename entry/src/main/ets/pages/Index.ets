import { MainPage } from './MainPage';

/**
 * 应用入口页面
 */
@Entry
@Component
struct Index {
  build() {
    // 直接加载主页面
    Column() {
      MainPage()
    }
    .width('100%')
    .height('100%')
  }
}
