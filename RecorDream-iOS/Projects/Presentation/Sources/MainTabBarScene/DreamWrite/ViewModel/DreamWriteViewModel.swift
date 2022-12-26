//
//  DreamWriteViewModel.swift
//  RD-Navigator
//
//  Created by Junho Lee on 2022/09/29.
//  Copyright © 2022 RecorDream. All rights reserved.
//

import Foundation

import Domain
import RD_Core

import RxSwift
import RxRelay

public class DreamWriteViewModel: ViewModelType {
    
    // MARK: - Inputs
    
    public struct Input {
        let viewDidLoad: Observable<Void>
        let datePicked: Observable<String>
        let voiceRecorded: Observable<Data?>
        let titleTextChanged: Observable<String>
        let contentTextChanged: Observable<String>
        let emotionChagned: Observable<Int?>
        let genreListChagned: Observable<[Int]?>
        let noteTextChanged: Observable<String>
        let saveButtonTapped: Observable<Void>
    }
    
    // MARK: - Outputs
    
    public struct Output {
        var writeButtonEnabled = PublishRelay<Bool>()
        var showGenreCountCaution = BehaviorRelay<Bool>(value: false)
        var writeRequestSuccess = PublishRelay<Void>()
        var dreamWriteModelFetched = BehaviorRelay<DreamWriteEntity?>(value: nil)
        var loadingStatus = PublishRelay<Bool>()
    }
    
    // MARK: - Properties
    
    private let useCase: DreamWriteUseCase
    private let disposeBag = DisposeBag()
    
    public enum DreamWriteViewModelType {
        case write
        case modify(postId: String)
    }
    
    private var viewModelType = DreamWriteViewModelType.write
    
    let writeRequestEntity = BehaviorRelay<DreamWriteRequest>(value: .init(title: nil, date: "", content: nil, emotion: nil, genre: nil, note: nil, voice: nil))
    var voiceId: String? = nil
    
    var shouldShowWarningForInit: Bool?
    
    // MARK: - Initializer
    
    public init(useCase: DreamWriteUseCase, viewModelType: DreamWriteViewModelType) {
        self.useCase = useCase
        self.viewModelType = viewModelType
    }
}

extension DreamWriteViewModel {
    public func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        Observable.combineLatest(input.datePicked.startWith(.toDateWithYYMMDD("")()),
                                 input.voiceRecorded.startWith(nil),
                                 input.titleTextChanged.startWith(""),
                                 input.contentTextChanged.startWith(""),
                                 input.emotionChagned.startWith(nil),
                                 input.genreListChagned.startWith(nil),
                                 input.noteTextChanged.startWith(""))
        .subscribe(onNext: { (date, urlTime, title, content, emotion, genreList, note) in
            self.writeRequestEntity.accept(DreamWriteRequest.init(title: title,
                                                                  date: date,
                                                                  content: content,
                                                                  emotion: emotion,
                                                                  genre: genreList,
                                                                  note: note,
                                                                  voice: self.voiceId))
        }).disposed(by: disposeBag)
        
        self.bindOutput(output: output, disposeBag: disposeBag)
        
        input.viewDidLoad.subscribe(onNext: { _ in
            if case let .modify(postId) = self.viewModelType {
                self.useCase.fetchDreamRecord(recordId: postId)
                output.loadingStatus.accept(true)
            }
        }).disposed(by: disposeBag)
        
        input.voiceRecorded.subscribe(onNext: { data in
            guard let data else { return }
            self.useCase.uploadVoice(voiceData: data)
        }).disposed(by: disposeBag)
        
        input.titleTextChanged.subscribe(onNext: {
            self.useCase.titleTextValidate(text: $0)
        }).disposed(by: disposeBag)
        
        input.genreListChagned.subscribe(onNext: {
            self.useCase.genreListCautionValidate(genreList: $0)
        }).disposed(by: disposeBag)
        
        input.saveButtonTapped.subscribe(onNext: { _ in
            output.loadingStatus.accept(true)
            self.useCase.writeDreamRecord(request: self.writeRequestEntity.value, voiceId: self.voiceId)
        }).disposed(by: disposeBag)
        
        return output
    }
    
    private func bindOutput(output: Output, disposeBag: DisposeBag) {
        let fetchedModel = useCase.fetchedRecord
        fetchedModel.subscribe(onNext: { entity in
            output.loadingStatus.accept(false)
            guard let entity = entity else {
                return
            }
            self.shouldShowWarningForInit = entity.shouldeShowWarning
            output.dreamWriteModelFetched.accept(entity)
            self.writeRequestEntity.accept(entity.toRequest())
        }).disposed(by: disposeBag)
        
        let writeRelay = useCase.writeSuccess
        writeRelay.subscribe(onNext: { entity in
            output.writeRequestSuccess.accept(())
            output.loadingStatus.accept(false)
        }).disposed(by: disposeBag)
        
        let writeEnabled = useCase.isWriteEnabled
        writeEnabled.subscribe(onNext: { status in
            output.writeButtonEnabled.accept(status)
        }).disposed(by: disposeBag)
        
        let showCaution = useCase.showCaution
        showCaution.subscribe(onNext: { status in
            output.showGenreCountCaution.accept(status)
        }).disposed(by: disposeBag)
        
        let uploadedVoiceId = useCase.uploadedVoice
        uploadedVoiceId.subscribe(onNext: { voiceId in
            self.voiceId = voiceId
        }).disposed(by: disposeBag)
    }
}
