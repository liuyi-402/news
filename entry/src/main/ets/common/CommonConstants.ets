/**
 * 颜色常量接口
 */
export interface ColorConstants {
  PRIMARY: string;
  BACKGROUND: string;
  WHITE: string;
  TEXT_PRIMARY: string;
  TEXT_SECONDARY: string;
  TEXT_HINT: string;
  DIVIDER: string;
  DANGER: string;
  SUCCESS: string;
  WARNING: string;
}

/**
 * 字体大小常量接口
 */
export interface FontSizeConstants {
  TITLE: number;
  SUBTITLE: number;
  BODY: number;
  CAPTION: number;
  SMALL: number;
}

/**
 * 间距常量接口
 */
export interface SpacingConstants {
  XS: number;
  SM: number;
  MD: number;
  LG: number;
  XL: number;
  XXL: number;
}

/**
 * 圆角常量接口
 */
export interface BorderRadiusConstants {
  SM: number;
  MD: number;
  LG: number;
  XL: number;
  ROUND: number;
}

/**
 * 公共常量定义
 */
export class CommonConstants {
  // 底部导航栏高度
  static readonly TAB_BAR_HEIGHT: number = 56;
  
  // 顶部栏高度
  static readonly HEADER_HEIGHT: number = 56;
  
  // 状态栏高度
  static readonly STATUS_BAR_HEIGHT: number = 24;
  
  // 新闻分类
  static readonly NEWS_CATEGORIES: string[] = [
    '要闻', '财经', '娱乐', '体育', '科技', '社会', '国际', '军事', '教育', '健康'
  ];
  
  // 默认头像
  static readonly DEFAULT_AVATAR: string = 'app.media.default_avatar';
  
  // 默认新闻封面
  static readonly DEFAULT_COVER: string = 'app.media.default_cover';
  
  // 颜色常量
  static readonly COLORS: ColorConstants = {
    PRIMARY: '#FF1677FF',
    BACKGROUND: '#FFF5F5F5',
    WHITE: '#FFFFFFFF',
    TEXT_PRIMARY: '#FF000000',
    TEXT_SECONDARY: '#FF666666',
    TEXT_HINT: '#FF999999',
    DIVIDER: '#FFE5E5E5',
    DANGER: '#FFFF4444',
    SUCCESS: '#FF4CAF50',
    WARNING: '#FFFF9800',
  };
  
  // 字体大小
  static readonly FONT_SIZE: FontSizeConstants = {
    TITLE: 18,
    SUBTITLE: 16,
    BODY: 14,
    CAPTION: 12,
    SMALL: 10,
  };
  
  // 间距
  static readonly SPACING: SpacingConstants = {
    XS: 4,
    SM: 8,
    MD: 12,
    LG: 16,
    XL: 20,
    XXL: 24,
  };
  
  // 圆角
  static readonly BORDER_RADIUS: BorderRadiusConstants = {
    SM: 4,
    MD: 8,
    LG: 12,
    XL: 16,
    ROUND: 999,
  };
}
