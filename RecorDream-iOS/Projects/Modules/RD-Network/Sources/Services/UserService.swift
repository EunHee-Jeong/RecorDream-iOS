//
//  UserService.swift
//  RD-NetworkTests
//
//  Created by Junho Lee on 2022/10/14.
//  Copyright © 2022 RecorDream. All rights reserved.
//

import Alamofire

import RxSwift

public protocol UserService {
    func withDrawal() -> Observable<Bool>
    func fetchUserInfo() -> Observable<UserInfoResponse?>
    func changeNickname(nickname: String) -> Observable<Bool>
}

public class DefaultUserService: BaseService {
    public static let shared = DefaultUserService()
    
    private override init() {}
}

extension DefaultUserService: UserService {

    public func fetchUserInfo() -> Observable<UserInfoResponse?> {
        requestObjectInRx(UserRouter.fetchUserInfo)
    }
    
    public func withDrawal() -> Observable<Bool> {
        requestObjectInRxWithEmptyResponse(UserRouter.withdrawal)
    }
    
    public func changeNickname(nickname: String) -> RxSwift.Observable<Bool> {
        requestObjectInRxWithEmptyResponse(UserRouter.changeNickname(nickname: nickname))
    }
}
