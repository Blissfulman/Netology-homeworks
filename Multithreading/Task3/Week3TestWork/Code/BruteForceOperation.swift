//
//  BruteForceOperation.swift
//  Week3TestWork
//
//  Created by User on 16.09.2020.
//  Copyright © 2020 E-legion. All rights reserved.
//

import Foundation

/// Операция поиска пароля (если пароль найден, он присваивается переменной foundResult, иначе она остаётся равной nil)
class BruteForceOperation: Operation {
    
    let inputPassword: String
    var foundResult: String?
    let startString: String
    let endString: String
    var startIndexArray = [Int]()
    var endIndexArray = [Int]()
    let characterArray = Consts.characterArray
    let maxIndexArray = Consts.characterArray.count
    
    init(inputPassword: String, startString: String, endString: String) {
        self.inputPassword = inputPassword
        self.startString = startString
        self.endString = endString
        super.init()
    }

    override func main() {
        
        print("Operation started")
        
        // Создает массивы индексов из входных строк
        for char in startString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                startIndexArray.append(index)
            }
        }
        for char in endString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                endIndexArray.append(index)
            }
        }
        
        var currentIndexArray = startIndexArray
        
        // Цикл подбора пароля
        while !isCancelled {
            
            // Формируем строку проверки пароля из элементов массива символов
            let currentPass = self.characterArray[currentIndexArray[0]] + self.characterArray[currentIndexArray[1]] + self.characterArray[currentIndexArray[2]] + self.characterArray[currentIndexArray[3]]

            // Выходим из цикла если пароль найден, или, если дошли до конца массива индексов
            if inputPassword == currentPass {
                print("Password found:", currentPass)
                foundResult = currentPass
                break
            } else {
                if currentIndexArray.elementsEqual(endIndexArray) {
                    break
                }
                
                // Если пароль не найден, то происходит увеличение индекса. Для этого в цикле, начиная с последнего элемента осуществляется проверка текущего значения. Если оно меньше максимального значения (61), то индекс просто увеличивается на 1.
                //Например было [0, 0, 0, 5] а станет [0, 0, 0, 6]. Если же мы уже проверили последний индекс, например [0, 0, 0, 61], то нужно сбросить его в 0, а "старший" индекс увеличить на 1. При этом далее в цикле проверяется переполение "старшего" индекса тем же алгоритмом.
                //Таким образом [0, 0, 0, 61] станет [0, 0, 1, 0]. И поиск продолжится дальше:  [0, 0, 1, 1],  [0, 0, 1, 2],  [0, 0, 1, 3] и т.д.
                for index in (0 ..< currentIndexArray.count).reversed() {
                    guard currentIndexArray[index] < maxIndexArray - 1 else {
                        currentIndexArray[index] = 0
                        continue
                    }
                    currentIndexArray[index] += 1
                    break
                }
            }
        }
    }
}
