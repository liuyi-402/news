import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { MockDataService } from '../services/MockDataService';
import { PersistenceTestUtil } from '../utils/PersistenceTestUtil';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    
    // 在onCreate中初始化Preferences并加载持久化数据
    try {
      await PreferencesUtil.init(this.context);
      
      // 测试持久化功能
      hilog.info(DOMAIN, 'testTag', '开始测试持久化功能...');
      const testResult = await PersistenceTestUtil.testPersistence();
      hilog.info(DOMAIN, 'testTag', `持久化测试结果: ${testResult}`);
      
      // 加载评论数据
      await MockDataService.loadCommentsFromStorage();
      
      // 检查评论数据
      await PersistenceTestUtil.checkCommentsData();
      
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading persistent data.');
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to load persistent data. Cause: %{public}s', JSON.stringify(error));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}