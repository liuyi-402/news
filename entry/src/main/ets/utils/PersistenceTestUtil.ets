import { PreferencesUtil } from './PreferencesUtil';

/**
 * 测试数据接口
 */
interface TestDataType {
  message: string;
  timestamp: number;
  number: number;
}

/**
 * 持久化测试工具
 * 用于测试和验证Preferences是否正常工作
 */
export class PersistenceTestUtil {
  private static readonly TEST_KEY = 'test_persistence_key';
  
  /**
   * 测试保存和读取功能
   */
  static async testPersistence(): Promise<boolean> {
    try {
      console.info('========== 持久化测试开始 ==========');
      
      // 测试数据
      const testData: TestDataType = {
        message: '测试数据',
        timestamp: Date.now(),
        number: 12345
      };
      
      // 保存测试数据
      console.info('PersistenceTest: 准备保存测试数据...');
      await PreferencesUtil.put(PersistenceTestUtil.TEST_KEY, JSON.stringify(testData));
      console.info('PersistenceTest: ✅ 保存成功');
      
      // 立即读取验证
      console.info('PersistenceTest: 准备读取测试数据...');
      const readData = await PreferencesUtil.get(PersistenceTestUtil.TEST_KEY, '{}') as string;
      const parsedData: TestDataType = JSON.parse(readData) as TestDataType;
      
      console.info(`PersistenceTest: 读取到的数据: ${readData}`);
      console.info(`PersistenceTest: 时间戳匹配: ${parsedData.timestamp === testData.timestamp}`);
      
      if (parsedData.timestamp === testData.timestamp) {
        console.info('PersistenceTest: ✅ 持久化功能正常');
        console.info('========== 持久化测试成功 ==========');
        return true;
      } else {
        console.error('PersistenceTest: ❌ 数据不匹配');
        console.info('========== 持久化测试失败 ==========');
        return false;
      }
    } catch (error) {
      console.error('PersistenceTest: ❌ 测试失败', error);
      console.info('========== 持久化测试异常 ==========');
      return false;
    }
  }
  
  /**
   * 检查评论数据是否保存成功
   */
  static async checkCommentsData(): Promise<void> {
    try {
      console.info('========== 评论数据检查 ==========');
      
      const COMMENTS_STORAGE_KEY = 'news_comments_data';
      const COMMENT_COUNT_STORAGE_KEY = 'news_comment_count';
      
      // 检查评论数据
      const hasComments = await PreferencesUtil.has(COMMENTS_STORAGE_KEY);
      console.info(`PersistenceTest: 是否有评论数据: ${hasComments}`);
      
      if (hasComments) {
        const commentsStr = await PreferencesUtil.get(COMMENTS_STORAGE_KEY, '{}') as string;
        const commentsObj: Record<string, Object[]> = JSON.parse(commentsStr) as Record<string, Object[]>;
        const newsIds = Object.keys(commentsObj);
        const newsCount = newsIds.length;
        console.info(`PersistenceTest: 已保存评论的新闻数: ${newsCount}`);
        console.info(`PersistenceTest: 评论数据大小: ${commentsStr.length} 字符`);
        
        // 显示每个新闻的评论数
        for (let i = 0; i < newsIds.length; i++) {
          const newsId = newsIds[i];
          const comments = commentsObj[newsId];
          console.info(`PersistenceTest: 新闻 ${newsId} 有 ${comments.length} 条评论`);
        }
      }
      
      // 检查评论数数据
      const hasCount = await PreferencesUtil.has(COMMENT_COUNT_STORAGE_KEY);
      console.info(`PersistenceTest: 是否有评论数数据: ${hasCount}`);
      
      if (hasCount) {
        const countStr = await PreferencesUtil.get(COMMENT_COUNT_STORAGE_KEY, '{}') as string;
        const countObj: Record<string, number> = JSON.parse(countStr) as Record<string, number>;
        const countKeys = Object.keys(countObj);
        console.info(`PersistenceTest: 评论数数据: ${countStr}`);
        console.info(`PersistenceTest: 有 ${countKeys.length} 个新闻的评论数`);
      }
      
      console.info('========== 检查完成 ==========');
    } catch (error) {
      console.error('PersistenceTest: 检查失败', error);
    }
  }
}
