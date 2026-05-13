package com.enterprise.common.exception;

import lombok.Getter;

@Getter
public enum ErrorCode {

    // 通用错误
    SUCCESS(0, "操作成功"),
    SYSTEM_ERROR(10000, "系统内部错误"),
    PARAM_INVALID(10001, "参数校验失败"),
    UNAUTHORIZED(10002, "未授权访问"),
    FORBIDDEN(10003, "无权限访问"),
    NOT_FOUND(10004, "资源不存在"),
    METHOD_NOT_ALLOWED(10005, "请求方法不允许"),
    CONFLICT(10006, "数据冲突"),

    // 用户模块 20000+
    USER_NOT_FOUND(20001, "用户不存在"),
    USERNAME_EXISTS(20002, "用户名已存在"),
    EMAIL_EXISTS(20003, "邮箱已被注册"),
    PASSWORD_INVALID(20004, "密码格式不正确"),
    ACCOUNT_LOCKED(20005, "账户已被锁定"),
    ACCOUNT_DISABLED(20006, "账户已被禁用"),
    LOGIN_FAILED(20007, "用户名或密码错误"),

    // 角色模块 30000+
    ROLE_NOT_FOUND(30001, "角色不存在"),
    ROLE_NAME_EXISTS(30002, "角色名称已存在"),
    ROLE_IN_USE(30003, "角色正在被用户使用，无法删除"),

    // 订单模块 40000+
    ORDER_NOT_FOUND(40001, "订单不存在"),
    ORDER_STATUS_INVALID(40002, "订单状态不允许此操作"),
    ORDER_ITEM_EMPTY(40003, "订单项不能为空"),
    INSUFFICIENT_STOCK(40004, "库存不足");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }
}
