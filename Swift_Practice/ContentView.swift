/*
追加要件:
  // 構造体
  struct SomeStruct {}
  // クラス
  class SomeClass {}
  // 列挙型
  enum SomeEnum {}

を、これまでの統合コードに追加する。

今回の学習ポイント（型定義の3種）:
- struct（構造体）: 値型（value type）。代入や引数渡しで「値のコピー」が基本（ただしCopy-on-Write最適化も多い）。
- class（クラス） : 参照型（reference type）。代入や引数渡しで「参照（同じ実体）」を共有する。
- enum（列挙）   : 限られたケース（状態）を型として表現する。SwiftではAssociated Valueなどで強力に状態表現できる。

SwiftUIとの関係（重要）:
- SwiftUI の View は基本的に struct で書く（値型 + 差分更新に相性が良い）。
- 状態（State）は値の変化をトリガーにUIが更新されるので、値型中心の設計が自然。
- 一方、共有したい長寿命の状態は class（ObservableObject / @StateObject など）を使うことが多い。
- enum は UI の状態遷移（例: loading / success / error）を表現するのに非常に便利。

ここでは学習用に空の型を定義しつつ、SwiftUI画面で「どの型か」を表示できるようにする。
*/

/// グローバル（ファイル直下）の `var` は初期値が必要なので初期化する。
var globalA: Int = 0

/// グローバル（ファイル直下）の `let` も初期値が必要なので初期化する。
let globalB: Int = 100

/// ユーザー指定の配列追加（そのまま a/b という名前で定義）
/// - a は [Int]
/// - b は [String]
let a = [1, 2, 3]          // [Int]
let b = ["a", "b", "c"]    // [String]

/// if 条件分岐の入力値（固定）
let value = 2

// MARK: - 関数 double（純粋関数の例）
func double(_ x: Int) -> Int {
    return x * 2
}
let doubledExample = double(2) // 4

// MARK: - 追加要件: struct / class / enum（型定義の例）

// 構造体（struct）
// - 値型（value type）である。
// - SwiftUIの View は struct で書くのが基本（ContentView も struct）。
// - 値型なので「状態のスナップショット」を作りやすく、差分更新に相性が良い。
struct SomeStruct {}

// クラス（class）
// - 参照型（reference type）である。
// - 代入すると「同じインスタンス」を参照する（コピーではない）。
// - SwiftUIでは、共有したい状態（ObservableObjectなど）に class を使うことが多い。
class SomeClass {}

// 列挙型（enum）
// - 有限個の「状態」や「ケース」を表現する型である。
// - Swiftは enum が非常に強力で、Associated Value を使うと状態機械を安全に表現できる。
// - UI状態（ロード中/成功/失敗）などを表すのに便利。
enum SomeEnum {}

// 発展例（コメント）:
// enum LoadingState {
//     case idle
//     case loading
//     case success(data: String)
//     case failure(error: Error)
// }

// ここでは「型が存在する」ことをSwiftUIで確認するため、型名（文字列）を用意する。
// - 実際にインスタンス化しなくても、型名は表示できる。
let structTypeName = String(describing: SomeStruct.self)
let classTypeName  = String(describing: SomeClass.self)
let enumTypeName   = String(describing: SomeEnum.self)

//
//  ContentView.swift
//  Swift_Practice
//
//  Swiftの学習要素を段階的に追加した統合サンプルである。
//  - var / let（可変・不変）
//  - 静的型付け（Int, String）
//  - 配列（Array）
//  - if 条件分岐
//  - 関数（double）
//  - 型定義（struct / class / enum）
//
//  Created by maton on 2026/02/23.
//

import SwiftUI

// MARK: - 型 + var/let + 配列(Array) のデモ用モデル（値型struct）
struct VarLetArrayDemoModel {
    var a: Int
    let b: Int
    let intArray: [Int]
    let stringArray: [String]
    
    mutating func assignIntToA() {
        a = 456
    }
}

// MARK: - SwiftUI View（これも struct）
struct ContentView: View {
    @State private var model = VarLetArrayDemoModel(
        a: 0,
        b: 100,
        intArray: [1, 2, 3],
        stringArray: ["a", "b", "c"]
    )
    
    private var isValueLeq3: Bool {
        value <= 3
    }
    
    private let doubleInput: Int = 2
    private var doubleResult: Int {
        double(doubleInput)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            // var / let の表示
            Text("model.a（var, Int）= \(model.a)")
                .font(.title2)
            Text("model.b（let, Int）= \(model.b)")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Button("model.a に 456（Int）を代入する") {
                model.assignIntToA()
            }
            .buttonStyle(.borderedProminent)
            
            // 配列の表示
            VStack(alignment: .leading, spacing: 10) {
                Text("配列（Array）の例")
                    .font(.headline)
                
                Text("intArray（[Int]）= [\(model.intArray.map(String.init).joined(separator: ", "))]")
                Text("stringArray（[String]）= [\(model.stringArray.joined(separator: ", "))]")
                Text("intArray.count = \(model.intArray.count), stringArray.count = \(model.stringArray.count)")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // if 条件分岐の表示
            VStack(alignment: .leading, spacing: 10) {
                Text("if 条件分岐の例")
                    .font(.headline)
                
                Text("value = \(value)")
                Text("判定: value <= 3 は \(isValueLeq3 ? "true" : "false")")
                    .foregroundStyle(.secondary)
                
                if isValueLeq3 {
                    Text("valueは3以下です")
                        .font(.title3)
                } else {
                    Text("valueは3より大きいです")
                        .font(.title3)
                }
                
                Text("（コンソール出力は onAppear で確認）")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 関数 double の表示
            VStack(alignment: .leading, spacing: 10) {
                Text("関数（double）の例")
                    .font(.headline)
                
                Text("入力: double(\(doubleInput))")
                Text("出力: \(doubleResult)")
                    .font(.title3)
                
                Text("例: double(2) = 4")
                    .foregroundStyle(.secondary)
                
                Text("※ func double(_ x: Int) -> Int の `_` により、呼び出しは double(2) と書ける。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 追加: struct / class / enum の表示
            VStack(alignment: .leading, spacing: 10) {
                Text("型定義（struct / class / enum）の例")
                    .font(.headline)
                
                // `String(describing: Type.self)` は型名を文字列化する簡易手段
                Text("struct: \(structTypeName)（値型）")
                Text("class : \(classTypeName)（参照型）")
                Text("enum  : \(enumTypeName)（状態の型）")
                
                Text("※ SwiftUIのViewはstructが基本。共有状態はclass（ObservableObject）を使うことが多い。UI状態はenumが便利。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .onAppear {
            // if + print（表示時に一回だけ）
            if value <= 3 {
                print("valueは3以下です")
            }
            
            // double の確認
            print("double(2) = \(double(2))") // 4
            
            // 型名の確認（コンソール）
            print("struct type = \(structTypeName)")
            print("class  type = \(classTypeName)")
            print("enum   type = \(enumTypeName)")
        }
    }
}

#Preview {
    ContentView()
}
