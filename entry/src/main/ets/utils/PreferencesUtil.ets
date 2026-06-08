import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

/**
 * Preferences工具类
 * 用于数据的持久化存储
 */
export class PreferencesUtil {
  private static readonly STORE_NAME = 'news_app_storage';
  private static preferences: preferences.Preferences | null = null;

  /**
   * 初始化Preferences实例
   * @param context 应用上下文
   */
  static async init(context: Context): Promise<void> {
    try {
      PreferencesUtil.preferences = await preferences.getPreferences(context, PreferencesUtil.STORE_NAME);
      console.info('PreferencesUtil: 初始化成功');
    } catch (error) {
      console.error('PreferencesUtil: 初始化失败', error);
    }
  }

  /**
   * 保存数据
   * @param key 键
   * @param value 值
   */
  static async put(key: string, value: preferences.ValueType): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil: preferences未初始化');
      return;
    }
    try {
      await PreferencesUtil.preferences.put(key, value);
      await PreferencesUtil.preferences.flush();
      console.info(`PreferencesUtil: 保存数据成功 - ${key}`);
    } catch (error) {
      console.error(`PreferencesUtil: 保存数据失败 - ${key}`, error);
    }
  }

  /**
   * 读取数据
   * @param key 键
   * @param defaultValue 默认值
   * @returns 值
   */
  static async get(key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil: preferences未初始化');
      return defaultValue;
    }
    try {
      const value = await PreferencesUtil.preferences.get(key, defaultValue);
      console.info(`PreferencesUtil: 读取数据成功 - ${key}`);
      return value;
    } catch (error) {
      console.error(`PreferencesUtil: 读取数据失败 - ${key}`, error);
      return defaultValue;
    }
  }

  /**
   * 删除数据
   * @param key 键
   */
  static async delete(key: string): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil: preferences未初始化');
      return;
    }
    try {
      await PreferencesUtil.preferences.delete(key);
      await PreferencesUtil.preferences.flush();
      console.info(`PreferencesUtil: 删除数据成功 - ${key}`);
    } catch (error) {
      console.error(`PreferencesUtil: 删除数据失败 - ${key}`, error);
    }
  }

  /**
   * 清空所有数据
   */
  static async clear(): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil: preferences未初始化');
      return;
    }
    try {
      await PreferencesUtil.preferences.clear();
      await PreferencesUtil.preferences.flush();
      console.info('PreferencesUtil: 清空数据成功');
    } catch (error) {
      console.error('PreferencesUtil: 清空数据失败', error);
    }
  }

  /**
   * 检查是否存在指定key
   * @param key 键
   * @returns 是否存在
   */
  static async has(key: string): Promise<boolean> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil: preferences未初始化');
      return false;
    }
    try {
      return await PreferencesUtil.preferences.has(key);
    } catch (error) {
      console.error(`PreferencesUtil: 检查数据失败 - ${key}`, error);
      return false;
    }
  }
}
