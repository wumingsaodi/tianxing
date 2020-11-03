//
//  URLConfig.swift
//  TianXin
//
//  Created by SDS on 2020/9/30.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
let api_checkUp = "/gl/index/checkUpdate"
/**
 首页信息
 */
let api_homeindex = "/gl/index/index"
///
let api_homeVideoSearch = "/gl/user/serchVideo"
/**
 首页刷新
 */
let api_homeRefresh = "/gl/index/refreshVideo"
/**
 其他页面的列表
 */
let  api_HomeOtherVCList = "/gl/index/getTypeVideoUrl"
/**
 获取电影播放地址
 */
let api_homeDetail = "/gl/index/getVideoUrl"
//MARK: - 用户
/***********************用户接口*****************************/
/**
 创建用户
 */
let api_registerUser = "/gl/user/newUser"
/**
 登录
 */
let api_login = "/gl/user/login"
/**
 退出登录
 */
let api_loginout = "/gl/user/loginout"
/**
 获取随机验证码图片
 */
let api_getRandomCode = "/gl/index/generateCheckCodeForRedis"
/**
 验证随机验证码
 */
let api_checkRndomCode = "/gl/user/checkImgCode"

/**
 获取用户信息
 */
let api_getUserInfo = "/gl/user/getUserInfo"
/**
 修改用户信息
 */
let api_updateUserInfo = "/gl/user/updateUserInfo"

/**
 重置密码
 */
let api_resetPassword = "/gl/user/resetPassword"
/**
 
 */
let api_updateUerPhone = "/gl/user/updateUserPhone"
let api_updateUerEmail = "/gl/user/updateUserEmail"
/**
 上传图片或视频
 */
let api_uploadImgUrl = "/gl/user/uploadPicMore"
/**
 发送手机验证码
 */
let api_iphoneSendCode = "/gl/user/sendCode"
/**
 发送邮箱验证
 */
let api_emailSendCode = "/gl/user/sendEmail"
/**
 绑定邮箱
 */
let api_isbindingPhoneOrEmail = "/gl/user/checkPhone"
/**
 获取推广消息
 */
let api_myPromoting = "/gl/user/myPromoting"
/***********************充值接口*****************************/
/**
 获取支付方式
 */
let api_getPayTypes = "/gl/payment/getPaySet"
/**
  支付订单详情
 */
let api_payOrderInfo = "/gl/payment/getOrderInfo"
/**
 支付订单列表
 */
let api_payOrderLists = "/gl/payment/getOrderList"
/**
 余额查询
 */
let api_getBalance = "/gl/payment/getThreeBalance"

/**
 发起支付订单
 */
let  api_payDwonOrder = "/gl/payment/downOrder"

//MARK: - 广场 圈子
/***********************广场圈子*****************************/
let api_topRecommendCellList = "/gl/square/recommendSquare"
/**
 广场首页推荐列表
 */
let api_CircleHomeRecommendList = "/gl/square/squareIssueList"
/**
 广场首页我的关注列表
 */
let api_CircleHomeMyCareList = "/gl/square/checkMyCare"
/**
 广场首页我的收藏
 */
let api_CircleHomeMyCollectList = "/gl/square/checkMyCollect"
/**
 广场首页我的发布
 */
let api_CircleHomeMyIssueList = "/gl/square/checkMyIssue"
/**
 广场首页我的已点赞
 */
let api_CircleHomeMyLikeList = "/gl/square/checkMyLike"
/**
 广场首页我的已评论
 */
let api_CircleHomeMyRemarkList = "/gl/square/checkMyRemark"
/**
广场已评论的删除
 */
let api_CircleHomeMyRemarkDel = "/gl/square/delMyRemark"

/**
 子精华帖子列表
 */
let api_circleEssenceIssueList = "/gl/square/circleIssueEssenceList"
/**
 圈子全部帖子列表
 */
let api_circleAllIssueList = "/gl/square/circleAllIssueList"

/**
 查询发帖用户主页
 */
let api_issueUserInfo = "/gl/square/checkIssueUserInfo"
