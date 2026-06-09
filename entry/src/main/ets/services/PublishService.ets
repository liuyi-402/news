import { PublishItem, AuthorInfo, Comment } from '../models/NewsModel';

/**
 * 点赞结果接口
 */
interface LikeResult {
  isLiked: boolean;
  likeCount: number;
}

/**
 * 爆料发布服务
 * 管理爆料的发布、存储和查询
 */
export class PublishService {
  // 静态存储已发布的爆料列表
  private static publishList: PublishItem[] = [];
  
  // 状态版本号，用于通知页面刷新
  private static stateVersion: number = 0;
  public static readonly STATE_VERSION_KEY = 'publishStateVersion';
  
  /**
   * 发布爆料
   * @param content 爆料内容
   * @param images 图片列表
   * @param topic 话题
   * @param source 来源
   * @param isPublic 是否公开
   * @returns 发布的爆料
   */
  static publish(
    content: string,
    images: string[],
    topic?: string,
    source?: string,
    isPublic: boolean = true
  ): PublishItem {
    // 创建新的爆料
    const newPublish: PublishItem = {
      id: `publish_${Date.now()}`,
      content: content,
      images: images,
      topic: topic,
      source: source,
      isPublic: isPublic,
      author: {
        id: 'user_001',
        name: '测试用户',
        avatar: 'https://picsum.photos/200/200?random=301',
        isVerified: true
      },
      publishTime: PublishService.formatTime(new Date()),
      likeCount: 0,
      commentCount: 0,
      shareCount: 0,
      isLiked: false
    };
    
    // 添加到列表开头（最新的在前面）
    PublishService.publishList.unshift(newPublish);
    
    // 通知状态变化
    PublishService.notifyPublishChanged();
    
    console.log(`PublishService: 发布爆料成功，ID: ${newPublish.id}`);
    
    return newPublish;
  }
  
  /**
   * 获取已发布的爆料列表
   * @returns 爆料列表
   */
  static getPublishList(): PublishItem[] {
    return PublishService.publishList;
  }
  
  /**
   * 根据ID获取爆料详情
   * @param id 爆料ID
   * @returns 爆料详情
   */
  static getPublishById(id: string): PublishItem | undefined {
    return PublishService.publishList.find((item: PublishItem) => item.id === id);
  }
  
  /**
   * 删除爆料
   * @param id 爆料ID
   * @returns 是否删除成功
   */
  static deletePublish(id: string): boolean {
    const index = PublishService.publishList.findIndex((item: PublishItem) => item.id === id);
    if (index !== -1) {
      PublishService.publishList.splice(index, 1);
      PublishService.notifyPublishChanged();
      console.log(`PublishService: 删除爆料成功，ID: ${id}`);
      return true;
    }
    return false;
  }
  
  /**
   * 切换爆料点赞状态
   * @param id 爆料ID
   * @returns 点赞结果
   */
  static togglePublishLike(id: string): LikeResult {
    const publish = PublishService.getPublishById(id);
    if (!publish) {
      const result: LikeResult = {
        isLiked: false,
        likeCount: 0
      };
      return result;
    }
    
    publish.isLiked = !publish.isLiked;
    publish.likeCount += publish.isLiked ? 1 : -1;
    
    PublishService.notifyPublishChanged();
    
    const result: LikeResult = {
      isLiked: publish.isLiked,
      likeCount: publish.likeCount
    };
    
    return result;
  }
  
  /**
   * 获取爆料数量
   * @returns 爆料数量
   */
  static getPublishCount(): number {
    return PublishService.publishList.length;
  }
  
  /**
   * 通知爆料状态变化
   */
  static notifyPublishChanged() {
    PublishService.stateVersion++;
    AppStorage.set<number>(PublishService.STATE_VERSION_KEY, PublishService.stateVersion);
    console.log(`PublishService: 状态变化，版本号: ${PublishService.stateVersion}`);
  }
  
  /**
   * 格式化时间
   * @param date 日期对象
   * @returns 格式化后的时间字符串
   */
  private static formatTime(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }
  
  /**
   * 格式化显示时间（相对时间）
   * @param timeStr 时间字符串
   * @returns 相对时间字符串
   */
  static formatDisplayTime(timeStr: string): string {
    const publishTime = new Date(timeStr);
    const now = new Date();
    const diff = now.getTime() - publishTime.getTime();
    
    const minutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    
    if (minutes < 1) {
      return '刚刚';
    } else if (minutes < 60) {
      return `${minutes}分钟前`;
    } else if (hours < 24) {
      return `${hours}小时前`;
    } else if (days < 7) {
      return `${days}天前`;
    } else {
      return timeStr.split(' ')[0]; // 返回日期部分
    }
  }
  
  /**
   * 添加评论
   * @param publishId 爆料ID
   * @param content 评论内容
   * @returns 是否添加成功
   */
  static addComment(publishId: string, content: string): boolean {
    const publish = PublishService.getPublishById(publishId);
    if (!publish) {
      return false;
    }
    
    // 初始化评论列表
    if (!publish.comments) {
      publish.comments = [];
    }
    
    // 创建新评论
    const newComment: Comment = {
      id: `comment_${Date.now()}`,
      newsId: publishId,
      author: {
        id: 'user_001',
        name: '测试用户',
        avatar: 'https://picsum.photos/200/200?random=301',
        isVerified: true
      },
      content: content,
      publishTime: PublishService.formatTime(new Date()),
      likeCount: 0,
      replyCount: 0,
      isLiked: false
    };
    
    // 添加评论到列表开头
    publish.comments.unshift(newComment);
    publish.commentCount++;
    
    // 通知状态变化
    PublishService.notifyPublishChanged();
    
    console.log(`PublishService: 添加评论成功，ID: ${newComment.id}`);
    return true;
  }
  
  /**
   * 获取评论列表
   * @param publishId 爆料ID
   * @returns 评论列表
   */
  static getComments(publishId: string): Comment[] {
    const publish = PublishService.getPublishById(publishId);
    if (!publish || !publish.comments) {
      return [];
    }
    return publish.comments;
  }
  
  /**
   * 删除评论
   * @param publishId 爆料ID
   * @param commentId 评论ID
   * @returns 是否删除成功
   */
  static deleteComment(publishId: string, commentId: string): boolean {
    const publish = PublishService.getPublishById(publishId);
    if (!publish || !publish.comments) {
      return false;
    }
    
    const index = publish.comments.findIndex((comment: Comment) => comment.id === commentId);
    if (index !== -1) {
      publish.comments.splice(index, 1);
      publish.commentCount--;
      PublishService.notifyPublishChanged();
      console.log(`PublishService: 删除评论成功，ID: ${commentId}`);
      return true;
    }
    return false;
  }
}
