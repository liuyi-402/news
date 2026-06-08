import { Comment, AuthorInfo, CommentClass } from '../models/NewsModel';
import { MockDataService, CommentSortType } from '../services/MockDataService';
import { CommonConstants } from '../common/CommonConstants';

/**
 * 评论区组件
 * 参考学习强国的评论区设计
 */
@Component
export struct CommentSection {
  @Prop newsId: string = '';
  @Link commentList: Comment[];
  @Link totalCommentCount: number;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State hasMore: boolean = true;
  @State isLoading: boolean = false;
  @State isNightMode: boolean = false;
  @State replyToCommentId: string = ''; // 回复的评论ID
  @State commentText: string = '';
  @State refreshTrigger: number = 0; // 刷新触发器
  
  // 评论数量变化的回调
  onCommentCountChange?: (count: number) => void;

  aboutToAppear() {
    // 只在评论列表为空时才加载评论
    if (this.commentList.length === 0) {
      this.loadComments();
    }
  }

  build() {
    Column({ space: 0 }) {
      // 评论标题和排序
      this.CommentHeader()
      
      // 评论列表
      if (this.commentList.length > 0) {
        this.CommentList()
      } else {
        this.EmptyComment()
      }
      
      // 加载更多按钮
      if (this.hasMore && this.commentList.length > 0) {
        this.LoadMoreButton()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 评论头部
   */
  @Builder
  CommentHeader() {
    Row({ space: 8 }) {
      Text('评论')
        .fontSize(18)
        .fontColor(this.isNightMode ? CommonConstants.COLORS.WHITE : CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)

      Text(`${this.totalCommentCount}`)
        .fontSize(16)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
    }
    .width('100%')
    .padding({ bottom: 12 })
  }

  /**
   * 评论列表
   */
  @Builder
  CommentList() {
    Column() {
      ForEach(this.commentList, (comment: Comment, index: number) => {
        Column() {
          this.CommentItem(comment)
          
          // 分隔线（除了最后一个）
          if (index < this.commentList.length - 1) {
            Divider()
              .color(this.isNightMode ? '#FF3A3A3A' : '#FFF0F0F0')
              .margin({ left: 48 }) // 头像宽度 + 间距
          }
        }
      }, (comment: Comment) => comment.id + '_' + this.refreshTrigger)
    }
    .width('100%')
  }

  /**
   * 空评论状态
   */
  @Builder
  EmptyComment() {
    Column({ space: 16 }) {
      Image($r('app.media.ic_empty_comment'))
        .width(100)
        .height(100)
        .opacity(0.4)

      Column({ space: 4 }) {
        Text('暂无评论')
          .fontSize(16)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          .fontWeight(FontWeight.Medium)

        Text('快来抢沙发吧~')
          .fontSize(14)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
      }
    }
    .width('100%')
    .padding(40)
  }

  /**
   * 加载更多按钮
   */
  @Builder
  LoadMoreButton() {
    Row() {
      if (this.isLoading) {
        LoadingProgress()
          .width(20)
          .height(20)
          .color(CommonConstants.COLORS.PRIMARY)
        
        Text('加载中...')
          .fontSize(14)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          .margin({ left: 8 })
      } else {
        Text('点击加载更多评论')
          .fontSize(14)
          .fontColor(CommonConstants.COLORS.PRIMARY)
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (!this.isLoading) {
        this.loadMoreComments();
      }
    })
  }

  /**
   * 评论项
   */
  @Builder
  CommentItem(comment: Comment) {
    Row() {
      // 头像 - 固定位置
      Image(comment.author.avatar)
        .width(36)
        .height(36)
        .borderRadius(18)
        .objectFit(ImageFit.Cover)
        .flexShrink(0) // 固定宽度，不压缩

      // 评论内容
      Column({ space: 6 }) {
        // 评论者昵称
        Row({ space: 6 }) {
          if (comment.author.isVerified) {
            Image($r('app.media.ic_verified'))
              .width(14)
              .height(14)
          }

          Text(comment.author.name)
            .fontSize(14)
            .fontColor(this.isNightMode ? CommonConstants.COLORS.WHITE : CommonConstants.COLORS.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')

        // 评论内容
        Text(comment.content)
          .fontSize(15)
          .fontColor(this.isNightMode ? '#FFE0E0E0' : CommonConstants.COLORS.TEXT_PRIMARY)
          .lineHeight(22)
          .width('100%')

        // 底部：时间和互动按钮
        Row({ space: 16 }) {
          Text(comment.publishTime)
            .fontSize(12)
            .fontColor(CommonConstants.COLORS.TEXT_HINT)

          Blank()
            .layoutWeight(1)

          // 点赞按钮
          Row({ space: 4 }) {
            Image(comment.isLiked ? $r('app.media.ic_like_active') : $r('app.media.ic_like'))
              .width(16)
              .height(16)

            Text(this.formatCount(comment.likeCount))
              .fontSize(12)
              .fontColor(comment.isLiked ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_SECONDARY)
          }
          .onClick(() => {
            this.toggleCommentLike(comment);
          })

          // 回复按钮
          Row({ space: 4 }) {
            Image($r('app.media.ic_comment'))
              .width(16)
              .height(16)

            Text(this.formatCount(comment.replyCount))
              .fontSize(12)
              .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          }
          .onClick(() => {
            this.replyToCommentId = comment.id;
          })
        }
        .width('100%')
        .margin({ top: 8 })

        // 回复列表
        if (comment.replies && comment.replies.length > 0) {
          this.ReplyList(comment)
        }
        
        // 回复输入框
        if (this.replyToCommentId === comment.id) {
          this.ReplyInput(comment)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 }) // 头像和内容的间距
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .alignItems(VerticalAlign.Top) // 头像顶部对齐
  }

  /**
   * 回复列表
   */
  @Builder
  ReplyList(comment: Comment) {
    Column({ space: 8 }) {
      ForEach(comment.replies, (reply: Comment) => {
        Row({ space: 8 }) {
          Text(reply.author.name)
            .fontSize(13)
            .fontColor(CommonConstants.COLORS.PRIMARY)
            .fontWeight(FontWeight.Medium)

          Text(reply.content)
            .fontSize(13)
            .fontColor(this.isNightMode ? '#FFE0E0E0' : CommonConstants.COLORS.TEXT_SECONDARY)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .backgroundColor(this.isNightMode ? '#FF2A2A2A' : '#FFF8F8F8')
        .borderRadius(6)
      }, (reply: Comment) => reply.id)
      
      // 查看更多回复
      if (comment.replyCount > (comment.replies?.length || 0)) {
        Text(`查看全部 ${comment.replyCount} 条回复 >`)
          .fontSize(12)
          .fontColor(CommonConstants.COLORS.PRIMARY)
          .width('100%')
          .padding({ top: 4 })
      }
    }
    .width('100%')
    .margin({ top: 8 })
  }

  /**
   * 回复输入框
   */
  @Builder
  ReplyInput(comment: Comment) {
    Row({ space: 8 }) {
      TextInput({ placeholder: `回复 ${comment.author.name}...`, text: this.commentText })
        .layoutWeight(1)
        .height(36)
        .backgroundColor(this.isNightMode ? '#FF3A3A3A' : '#FFF5F5F5')
        .borderRadius(18)
        .fontSize(14)
        .fontColor(this.isNightMode ? CommonConstants.COLORS.WHITE : CommonConstants.COLORS.TEXT_PRIMARY)
        .placeholderColor(CommonConstants.COLORS.TEXT_HINT)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.commentText = value;
        })
      
      Button('发送')
        .fontSize(14)
        .fontColor(CommonConstants.COLORS.WHITE)
        .height(36)
        .borderRadius(18)
        .backgroundColor(this.commentText.trim().length > 0 ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_HINT)
        .enabled(this.commentText.trim().length > 0)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.sendReply(comment);
        })
    }
    .width('100%')
    .margin({ top: 8 })
  }

  // ==================== 数据加载 ====================

  /**
   * 加载评论
   */
  private loadComments() {
    this.isLoading = true;
    
    // 模拟异步加载
    setTimeout(() => {
      const result = MockDataService.getCommentsPaginated(
        this.newsId,
        this.currentPage,
        this.pageSize
      );
      
      // 使用splice清空并添加新元素，触发响应式更新
      this.commentList.splice(0, this.commentList.length);
      for (let i = 0; i < result.comments.length; i++) {
        this.commentList.push(result.comments[i]);
      }
      
      this.totalCommentCount = result.total;
      this.hasMore = result.hasMore;
      this.isLoading = false;
      this.refreshTrigger++;
      
      console.log(`评论加载完成: ${this.commentList.length}条`);
    }, 300);
  }

  /**
   * 加载更多评论
   */
  private loadMoreComments() {
    this.isLoading = true;
    this.currentPage++;
    
    setTimeout(() => {
      const result = MockDataService.getCommentsPaginated(
        this.newsId,
        this.currentPage,
        this.pageSize
      );
      
      // 使用push添加新元素，触发响应式更新
      for (let i = 0; i < result.comments.length; i++) {
        this.commentList.push(result.comments[i]);
      }
      
      this.hasMore = result.hasMore;
      this.isLoading = false;
      this.refreshTrigger++;
      
      console.log(`加载更多评论完成: 总共${this.commentList.length}条`);
    }, 300);
  }

  /**
   * 切换评论点赞状态
   */
  private toggleCommentLike(comment: Comment) {
    console.log(`点赞评论: ${comment.id}`);
    
    // 调用服务层更新点赞状态
    const result = MockDataService.toggleCommentLike(comment.id, comment.likeCount);
    
    // 找到评论索引
    const index = this.commentList.findIndex(c => c.id === comment.id);
    if (index !== -1) {
      const oldComment = this.commentList[index];
      
      // 创建新的评论对象
      const updatedComment: Comment = {
        id: oldComment.id,
        newsId: oldComment.newsId,
        author: oldComment.author,
        content: oldComment.content,
        publishTime: oldComment.publishTime,
        likeCount: result.likeCount,
        replyCount: oldComment.replyCount,
        isLiked: result.isLiked,
        replies: oldComment.replies
      };
      
      // 使用splice替换元素，触发响应式更新
      this.commentList.splice(index, 1, updatedComment);
      this.refreshTrigger++;
      
      console.log(`点赞成功: ${result.isLiked ? '已点赞' : '取消点赞'}, 点赞数: ${result.likeCount}`);
    }
  }

  /**
   * 发送回复
   */
  private sendReply(comment: Comment) {
    if (this.commentText.trim().length === 0) {
      console.log('回复内容为空');
      return;
    }
    
    console.log(`发送回复: 评论ID=${comment.id}, 内容=${this.commentText}`);
    
    // 添加回复到数据服务
    const reply = MockDataService.addReply(this.newsId, comment.id, this.commentText.trim());
    
    // 找到评论索引
    const index = this.commentList.findIndex(c => c.id === comment.id);
    if (index !== -1) {
      const oldComment = this.commentList[index];
      
      // 创建新的回复数组
      const replies: Comment[] = [];
      if (oldComment.replies) {
        for (let i = 0; i < oldComment.replies.length; i++) {
          replies.push(oldComment.replies[i]);
        }
      }
      replies.push(reply);
      
      // 创建新的评论对象
      const updatedComment: Comment = {
        id: oldComment.id,
        newsId: oldComment.newsId,
        author: oldComment.author,
        content: oldComment.content,
        publishTime: oldComment.publishTime,
        likeCount: oldComment.likeCount,
        replyCount: oldComment.replyCount + 1,
        isLiked: oldComment.isLiked,
        replies: replies
      };
      
      // 使用splice替换元素，触发响应式更新
      this.commentList.splice(index, 1, updatedComment);
      this.refreshTrigger++;
      
      console.log(`回复成功: 回复数=${updatedComment.replyCount}`);
    }
    
    // 清空输入框
    this.commentText = '';
    this.replyToCommentId = '';
  }

  /**
   * 格式化数量显示
   */
  private formatCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    }
    return count.toString();
  }

  /**
   * 添加新评论（供外部调用）
   */
  public addComment(content: string) {
    const newComment = MockDataService.addComment(this.newsId, content);
    
    // 使用unshift添加到开头，触发响应式更新
    this.commentList.unshift(newComment);
    this.totalCommentCount++;
    this.refreshTrigger++;
    
    console.log(`添加新评论: 总数=${this.totalCommentCount}`);
  }
}
