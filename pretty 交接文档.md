## Pretty 交接文档

> 基于RxSwift开发，业务型界面基本上由Storyboard管理

#### Public

- #### components

  > - PhotoBrowser, 图片浏览组件。使用UICollectionView来管理图片、PhotoAnimator来控制转场动画【并非真正意义上的转场动画】；
  > - FloatingButton 浮窗按钮，目前用于广场界面发布按钮；
  > - AttentionButton 关注按钮；
  > - EmptyView现阶段只有空界面提示；

- Notification

  >目前都是用于广场信息同步，比如点赞、关注、收藏等
  
- Themes

  >本来是用来管理颜色、布局等风格样式，但目前给到的UI图很难展现其App风格；
  
- Configs

  >App配置文件
  
- Networking

  > - Entities 服务器返回的数据实体
  > - Apis 网络请求
  >
  >   > - BaseApi：Api公共处理部分
  >   > - TopicApi：专题模块
  >   > - UserApi： 用户模块
  >   > - SquareApi：广场模块
  >
  > - JSON：用户承载服务器json数据
  > - HttpProvider 网络请求实际发起者
  > - NetworkCachable：网络缓存
  > - Operators：自定义操作符，目前定义了直观化的内存大小显示

- Base

  >- Rx
  >> - ActivityIndicator，加载指示器
  >> - ErrorTracker 错误追踪器
  >
  >- ViewModelType：规范统一ViewModel
  
- Extions

  >- RxSwift：扩展常用组件，用来支持RxSwift
  >- 其他便利扩展

#### Share

> 分享组件，目前只有简单的系统分享

#### Kok

> KOK游戏入口相关的界面

Movie

>电影播放详情页及后续界面
>
>- Models: [ViewModel]
>- Views
>- MovieDetailViewController：专题电影详情页
>- MovieInfoHeaderViewController：专题电影详情页头部信息视图
>- MoviePlayerViewController：播放器控制器，实际播放者SDSPlayerVC
>- MovieRecommendsViewController：专题电影详情页推荐模块
>- CommentReplyViewController：评论详情界面
>- CommentSectionHeaderViewController：评论table view section header
>- CommentDetailHeaderViewController：评论详情界面头部 table view header view
>- InputViewController：发表评论输入框，带有评论、点赞、收藏、分享四个按钮
>- ReplyInputViewController：只有输入框
>- TinyPlayer 自定义播放器，待开发

#### Search

>专题搜索模块
>
>- SearchBarViewController：用来管理自定义SearchBar
>- SearchDefaultViewController：搜索默认界面，主要用户显示历史记录标签
>- RecentSearchCell：历史记录标签cell
>- LeftAlignedCollectionViewFlowLayout：左对齐
>- SearchResultsViewHeader：搜索结果页头部
>- SearchViewController：搜索界面

#### Topic

> 专题模块
>
> - TopicViewController：专题首页
> - MovieListOnTopicViewController：专题下的电影列表界面
> - MovieFavoritesViewController：我的收藏列表界面
> - Views
>   - TopicListCell：专题首页专题cell
>   - TopicMovieListCell：专题下的电影列表cell
>   - MovieFavoritesCell：电影收藏列表cell
>   - MovieListOnTopicHeaderView：专题下的电影列表界面头部 table view header view

#### Circle

> - UserDetail：用户主页及后续界面
>   - UserDetailViewController：用户主页
>   - UserDetailHeaderViewController：用户主页头部
>   - UserPublishListViewController：发布、收藏、足迹
>   - UserReplyListViewController：回复
>   - FansListViewController：关注的列表及粉丝列表
>
> - PostingViewController：发布帖子界面
> - CircleListViewController：全部圈子及我加入的圈子列表界面
> - IssueDetailViewController：帖子详情
> - IssueDetailHeaderViewController：帖子详情头部
> - IssueCommentReplyViewController：帖子评论界面