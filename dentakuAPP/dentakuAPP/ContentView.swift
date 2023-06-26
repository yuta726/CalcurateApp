//
//  ContentView.swift
//  dentakuAPP
//
//  Created by 中村優太 on 2023/06/19.
//

import SwiftUI

enum CaluculateState {
    case initial, addition, substraction, division, multiplication, sum
}

struct ContentView: View {
    
    @State var selectedItem: String = "0"
    @State var caluculatedNumber: Double = 0
    @State var caluculateState: CaluculateState = .initial
    
    private let caluculateItems: [[String]] = [
        ["AC", "+/-", "%", "÷"],
        ["7", "8", "9", "x"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="],
    ]
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            VStack {
            
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text(selectedItem == "0" ? checkDecimal(number: caluculatedNumber) : selectedItem)
                        .font(.system(size: 100, weight: .light))
                        .foregroundColor(Color.white)
                        .padding()
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                }
                
                VStack {
                    ForEach(caluculateItems, id: \.self) { items in
                        NumberView(selectedItem: $selectedItem,
                                   caluculatedNumber: $caluculatedNumber,
                                   caluculateState: $caluculateState,
                                   items: items)
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // 小数点以下に数値が含まれるか確認する
    private func checkDecimal(number: Double) -> String {
        if number.truncatingRemainder(dividingBy: 1).isLess(than: .ulpOfOne) {
            return String(Int(number))
        } else {
            return String(number)
        }
    }
    
}

struct NumberView: View {
    
    @Binding var selectedItem: String
    @Binding var caluculatedNumber: Double
    @Binding var caluculateState: CaluculateState

    var items: [String]
    
    private let buttonWidth: CGFloat = (UIScreen.main.bounds.width - 50) / 4
    private let numbers: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."]
    private let symbols: [String] = ["÷", "x", "-", "+", "="]
        
    
    var body: some View {
        
        HStack {
            
            ForEach(items, id: \.self) { item in
                
                Button {
                    handleButtonInfo(item: item)
                } label: {
                    Text(item)
                        .font(.system(size: 30, weight: .regular))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                }
                .foregroundColor(numbers.contains(item) || symbols.contains(item) ? .white : .black)
                .background(handleButtonColor(item: item))
                .frame(width: item == "0" ? buttonWidth * 2 + 10 : buttonWidth)
                .cornerRadius(buttonWidth)

            }
            .frame(height: buttonWidth)
        }
    }
    
    // ボタンの色を設定
    private func handleButtonColor(item: String) -> Color {
        if numbers.contains(item) {
            return Color(white: 0.2, opacity: 1)
        } else if symbols.contains(item) {
            return Color.orange
        } else {
            return Color(white: 0.8, opacity: 1)
        }
    }
    
    // ボタンタップ時の処理を作成
    private func handleButtonInfo(item: String) {
        
        // 数字が入力された時
        if numbers.contains(item) {
            // "."入力されて、且つ入力済みの値に"."が含まれるもしくは"0"の場合は、追加しない
            if item == "." && selectedItem.contains(".") {
                return
            }
            
            // 入力可能文字数を10桁に
            if selectedItem.count >= 10 {
                return
            }
            
            // 数値がゼロの時は書き換える
            if selectedItem == "0" && item != "." {
                selectedItem = item
                return
            }
            
            selectedItem += item
            
        //特殊記号が入力された時
        } else if item == "AC" {
            selectedItem = "0"
            caluculatedNumber = 0
            caluculateState = .initial
        } else if item == "+/-" {
            if selectedItem == "0"{
                var str = String(caluculatedNumber)
                if let range = str.range(of: "-"){
                    str.removeSubrange(range)
                }else{
                    str = "-" + str
                }
                if let calculatedValue = Double(str) {
                        caluculatedNumber = calculatedValue
                    }
            }else{
                if let range = selectedItem.range(of: "-") {
                    selectedItem.removeSubrange(range)
                }else{
                    selectedItem = "-" + selectedItem
                }
            }
        } else if item == "%" {
            if selectedItem == "0" && caluculatedNumber == 0 {
                    return
            }else if selectedItem == "0"{
                caluculatedNumber = caluculatedNumber / 100
            } else if caluculatedNumber == 0 {
                if let selectedValue = Double(selectedItem) {
                    selectedItem = String(selectedValue / 100)
                }
            }
        }
        
        guard let selectedNumber = Double(selectedItem) else { return }
        // 計算記号が入力された時
        if item == "÷" {
            setCaluculate(state: .division, selectedNumber: selectedNumber)
        } else if item == "x" {
            setCaluculate(state: .multiplication, selectedNumber: selectedNumber)
        } else if item == "-" {
            setCaluculate(state: .substraction, selectedNumber: selectedNumber)
        } else if item == "+" {
            setCaluculate(state: .addition, selectedNumber: selectedNumber)
        } else if item == "=" {
            selectedItem = "0"
            caluculate(selectedNumber: selectedNumber)
            caluculateState = .sum
        }
    }
    
    // どの計算をするかハンドル
    private func setCaluculate(state: CaluculateState, selectedNumber: Double) {
        if selectedItem == "0" {
            caluculateState = state
            return
        }
        
        selectedItem = "0"
        caluculateState = state
        caluculate(selectedNumber: selectedNumber)
    }
    
    // 計算する
    private func caluculate(selectedNumber: Double) {
        
        if caluculatedNumber == 0 {
            caluculatedNumber = selectedNumber
            return
        }
        
        switch caluculateState {
        case .addition:
            caluculatedNumber = caluculatedNumber + selectedNumber
        case .substraction:
            caluculatedNumber = caluculatedNumber - selectedNumber
        case .division:
            caluculatedNumber = caluculatedNumber / selectedNumber
        case .multiplication:
            caluculatedNumber = caluculatedNumber * selectedNumber
        default:
            break
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
