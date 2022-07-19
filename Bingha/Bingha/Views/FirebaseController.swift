//
//  FirebaseController.swift
//  Bingha
//
//  Created by ryu hyunsun on 2022/07/17.
//

import Foundation
import FirebaseFirestore
import UIKit

class FirebaseController {
    let database = Firestore.firestore()
    var carbonModel: CarbonModel
    
    init(){
        self.carbonModel = CarbonModel(todayTotalDecreaseCarbon: 0.0, totalDistance: 0.0, totalDecreaseCarbon: 0.0)
        print(self.carbonModel.todayTotalDecreaseCarbon)
        self.loadTodayCarbonData()
        self.loadIcebergData()
    }
    
    // 탄소 저감량 저장 (종료 버튼 눌렀을때)
    func saveDecreaseCarbonData(startTime: Date, endTime: Date, distance: Double, decreaseCarbon: Double) {
        // 버튼 누른 시간 기점으로 들어감.
        let dayToString = endTime.changeDayToString()
        let timeToString = endTime.changeTimeToString()
        // firestore db 컬렉션 및 다큐멘트 경로.
        let path = database.document("\( UIDevice.current.identifierForVendor!.uuidString + "-carbon")/\(dayToString)")
        // 경로가 존재한다면? 필드만 추가해줌.
        path.getDocument { (document, error) in
            if let document = document, document.exists {
                path.updateData(["\(timeToString)": [
                    "startTime": startTime,
                    "endTime": endTime,
                    "distance": distance,
                    "decreaseCarbon": decreaseCarbon
                ]])
                // 근데 경로가 없다면? 생성해준다!
            } else {
                // 시작시간, 끝 시간, 거리, 탄소 저감량 저장.
                path.setData([ "\(timeToString)": [
                    "startTime": startTime,
                    "endTime": endTime,
                    "distance": distance,
                    "decreaseCarbon": decreaseCarbon
                ]])
            }
        }
    }
    
    // 오늘 총 이동 거리, 탄소 저감량 로드 (최초 앱 들어올때!, 측정 완료시 확인용?)
    func loadTodayCarbonData() {
        let todayToString = Date().changeDayToString()
        // 파이어 스토어 데이터 경로
        let path = database.document("\( UIDevice.current.identifierForVendor!.uuidString+"-carbon")/\(todayToString)")
        
        // 데이터 불러오기
        path.getDocument {
            (document, error) in
            // 데이터가 있다면.
            if let document = document, document.exists {
                // document에서 data 뽑아오기.
                if let datas = document.data() {
                    // 날짜 바뀌는 것을 대비한 초기화. 우리는 오늘 데이터만 필요하니까.
                    self.carbonModel.todayTotalDecreaseCarbon = 0.0
                    // 우리는 value값만 필요하니까.
                    let values = datas.values
                    var todayTotalDecreaseCarbon = 0.0
                    for value in values {
                        // 다 옵셔널 타입으로 들어가 있어서 옵셔널 바인딩 해주기.
                        guard let parsedDictionary = value as? [String: Any],
//                              let distance = parsedDictionary["distance"] as? Double,
                              //                                  let startTime = parsedDictionary["startTime"] as? Date,
                              //                                  let endTime = parsedDictionary["endTime"] as? Date,
                                let decreaseCarbon = parsedDictionary["decreaseCarbon"] as? Double
                        else { return }
                        // 오늘 총 탄소 배출 저감량에 더해주기.
                        todayTotalDecreaseCarbon += decreaseCarbon
                    }
                    self.carbonModel.todayTotalDecreaseCarbon = todayTotalDecreaseCarbon
                    print("오늘 총 저감한 탄소량 : \(self.carbonModel.todayTotalDecreaseCarbon)")
//                    print("오늘 총 걸은 거리 : \(self.todayTotalDistance)")
//                    print("오늘 총 저감한 탄소량 : \(self.todayTotalDecreaseCarbon)")
                }
            } else {
                print("데이터 없음")
            }
        }
    }
    
    // 총 이동거리, 총 탄소 저감량 저장
    func saveIcebergData(totalDistance: Double, totalDecreaseCarbon: Double) {
        let path = database.document("\( UIDevice.current.identifierForVendor!.uuidString + "-iceberg")/icebergInfo")
        // 레벨 데이터 저장.
        path.setData([
            "totalDistance": totalDistance,
            "totalDecreaseCarbon": totalDecreaseCarbon
        ])
        print("이동거리, 탄소 저감량 저장")
    }
    
    // 총 이동거리, 총 탄소 저감량 저장
    func loadIcebergData() {
        let path = database.document("\( UIDevice.current.identifierForVendor!.uuidString + "-iceberg")/icebergInfo")
        path.getDocument {
            (document, error) in
            if let document = document, document.exists {
                if let datas = document.data() {
                    print(datas)
                    guard let levelValue = datas["totalDistance"] as? Double,
                          let expValue = datas["totalDecreaseCarbon"] as? Double
                    else { return }
                    print(levelValue)
                    print(expValue)
                    }
            }
            
        }
    }
}


extension Date {
    func changeDayToString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dayToString = formatter.string(from: self)
        return dayToString
    }
    func changeTimeToString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeToString = formatter.string(from: self)
        return timeToString
    }
    
}
