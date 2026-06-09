/**
 * 搜索历史管理服务
 * 使用本地存储保存搜索历史
 */
export class SearchHistoryService {
  private static readonly MAX_HISTORY_COUNT = 10; // 最多保存10条历史记录
  private static readonly STORAGE_KEY = 'search_history';
  
  /**
   * 获取搜索历史列表
   */
  static getSearchHistory(): string[] {
    try {
      // 从本地存储获取历史记录
      const historyStr = AppStorage.get<string>(SearchHistoryService.STORAGE_KEY) || '[]';
      const history: string[] = JSON.parse(historyStr) as string[];
      return history;
    } catch (error) {
      console.error('SearchHistoryService: 获取搜索历史失败', error);
      return [];
    }
  }
  
  /**
   * 添加搜索关键词到历史
   */
  static addSearchHistory(keyword: string): void {
    if (!keyword || keyword.trim().length === 0) {
      return;
    }
    
    try {
      let history = SearchHistoryService.getSearchHistory();
      
      // 移除重复项（如果已存在）
      const trimmedKeyword = keyword.trim();
      history = history.filter((item: string) => item !== trimmedKeyword);
      
      // 添加到最前面
      history.unshift(trimmedKeyword);
      
      // 限制历史记录数量
      if (history.length > SearchHistoryService.MAX_HISTORY_COUNT) {
        history = history.slice(0, SearchHistoryService.MAX_HISTORY_COUNT);
      }
      
      // 保存到本地存储
      AppStorage.set<string>(SearchHistoryService.STORAGE_KEY, JSON.stringify(history));
      console.log(`SearchHistoryService: 添加搜索历史 "${trimmedKeyword}"`);
    } catch (error) {
      console.error('SearchHistoryService: 添加搜索历史失败', error);
    }
  }
  
  /**
   * 删除单条搜索历史
   */
  static removeSearchHistory(keyword: string): void {
    try {
      let history = SearchHistoryService.getSearchHistory();
      history = history.filter((item: string) => item !== keyword);
      AppStorage.set<string>(SearchHistoryService.STORAGE_KEY, JSON.stringify(history));
      console.log(`SearchHistoryService: 删除搜索历史 "${keyword}"`);
    } catch (error) {
      console.error('SearchHistoryService: 删除搜索历史失败', error);
    }
  }
  
  /**
   * 清空所有搜索历史
   */
  static clearSearchHistory(): void {
    try {
      AppStorage.set<string>(SearchHistoryService.STORAGE_KEY, '[]');
      console.log('SearchHistoryService: 清空搜索历史');
    } catch (error) {
      console.error('SearchHistoryService: 清空搜索历史失败', error);
    }
  }
}
