//
//  CarbonEmissionCalculateUtil.swift
//  Bingha
//
//  Created by Terry Koo on 2022/07/18.
//

import Foundation

internal class ReducedCarbonCalculator {
    public static let shared: ReducedCarbonCalculator = ReducedCarbonCalculator()

    private init(){}
    
    // 내가 걸은 거리만큼 계산했을 때 탄소 배출이 얼마나 감소했을까
    func reducedCarbon(km distance: Double) -> String {
        // 자가용으로 1km 이동 시 약 134g의 탄소 배출이 발생함
        return (distance * 134).formatterWithSeparator + "g"
    }
    
    // 내가 걸은 거리만큼 계산했을 때 빙하가 얼마나 지켜졌을까
    func protectedGlacier(km distance: Double) -> String {
        // 자가용으로 1km 이동 시 약 2kg의 빙하가 소멸 -> 1km를 걸어갔을 경우 2kg의 빙하를 지킴
        return (distance * 2).formatterWithSeparator + "kg"
    }
    
    func reducedCarbonDouble(km distance: Double) -> Double {
        return (distance * 134)
    }
}

