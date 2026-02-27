/*
追加要件:
  func printIfEqual<T: Equatable>(_ arg1: T, _ arg2: T) {
      if arg1 == arg2 {
          print("Both are \(arg1)")
      }
  }
  printIfEqual(123, 123)
  printIfEqual("str", "str")

を「今までの統合コード」に追加し、詳細コメント付きで統合する。

今回の学習ポイント（ジェネリクス + 制約 + Equatable + if + print）:
- `printIfEqual<T: Equatable>` はジェネリック関数である。
  - T は「型パラメータ」で、呼び出し時に Int や String など具体的な型に置き換わる。
- `T: Equatable` は「型制約（constraint）」である。
  - T は Equatable に準拠している必要がある。
  - つまり `==` で比較できる型だけ受け付ける。
- 引数ラベル `_` により、呼び出しは `printIfEqual(123, 123)` のように書ける。
- 本体では `if arg1 == arg2` で等価性を判定し、true の場合だけ print する。
- SwiftUIとの接続では、printはコンソール出力でありUIには出ない。
  - そのため「UIにも結果を出す」には、printの代わりに文字列を返す関数にする、
    あるいは SwiftUI の状態（@State）を更新して Text に表示するのが基本。
  - ただし「今回の追加要件は print する関数」なので、実行場所は onAppear などに寄せて、
    body再評価でログが増殖しないようにする。
*/

// ------------------------------
// 既存: トップレベル（宣言のみ）
// ------------------------------

var globalA: Int = 0
let globalB: Int = 100

let a = [1, 2, 3]          // [Int]
let b = ["a", "b", "c"]    // [String]

let value = 2

// MARK: - 関数 double（純粋関数）
func double(_ x: Int) -> Int {
    return x * 2
}
let doubledExample = double(2) // 4（宣言+初期化なのでOK）

// MARK: - struct / class / enum
struct SomeStruct {}
class SomeClass {}
enum SomeEnum {}

let structTypeName = String(describing: SomeStruct.self)
let classTypeName  = String(describing: SomeClass.self)
let enumTypeName   = String(describing: SomeEnum.self)

// MARK: - Double（宣言のみ。トップレベルでの実行文は置かない）
var doubleA = 4.0
var doubleB = doubleA

// ------------------------------------------
// 追加要件: ジェネリック関数 printIfEqual
// ------------------------------------------

/*
ジェネリック関数の定義:
- <T: Equatable> は「型パラメータT」に制約を付けている。
- Equatable に準拠している型は `==` が使えるので、ifで比較できる。
- `_` により引数ラベルを省略できるため、呼び出しは printIfEqual(123, 123) の形になる。

この関数の動作:
- arg1 と arg2 が等しいときだけ print を行う（等しくない場合は何もしない）
*/
func printIfEqual<T: Equatable>(_ arg1: T, _ arg2: T) {
    // Equatable 制約があるので `==` が使える
    if arg1 == arg2 {
        // 文字列補間（String Interpolation）で arg1 の値を埋め込む
        // ここで \(arg1) は、arg1 を String 化して文字列に挿入する構文である。
        print("Both are \(arg1)")
    }
}

/*
注意（SwiftUIアプリのトップレベル実行禁止）:
- printIfEqual(123, 123) のような「実行文」をファイル直下に置くと、
  SwiftUIアプリではコンパイルエラーになりうる（トップレベル実行不可）。
- したがって、呼び出しは onAppear やボタンaction の中で行う。
*/

// 例の「呼び出し結果」を UI にも見せたい場合は、print ではなく String を返す関数にするのが自然。
// ただし追加要件が print なので、ここでは補助関数として別に用意しておく（教材用）。
//
// - printIfEqual: コンソール向け（副作用）
// - messageIfEqual: UI向け（純粋関数）
func messageIfEqual<T: Equatable>(_ arg1: T, _ arg2: T) -> String? {
    if arg1 == arg2 {
        return "Both are \(arg1)"
    }
    return nil
}

//
//  ContentView.swift
//  Swift_Practice
//
//  ここまでの学習要素:
//  - var / let
//  - 型（Int, String, Double）
//  - 配列（Array）
//  - if 条件分岐
//  - 関数（double）
//  - 型定義（struct / class / enum）
//  - Double 値コピー + mutating（formSquareRoot）
//  - ジェネリクス + 制約（printIfEqual<T: Equatable>）
//

import SwiftUI

struct VarLetArrayDemoModel {
    var a: Int
    let b: Int
    let intArray: [Int]
    let stringArray: [String]
    
    mutating func assignIntToA() {
        a = 456
    }
}

struct DoubleCopyDemoModel {
    var rootA: Double
    var rootB: Double
    
    init(initial: Double) {
        self.rootA = initial
        self.rootB = initial
    }
    
    mutating func applySquareRootToA() {
        rootA.formSquareRoot()
    }
}

struct ContentView: View {
    @State private var model = VarLetArrayDemoModel(
        a: 0,
        b: 100,
        intArray: [1, 2, 3],
        stringArray: ["a", "b", "c"]
    )
    
    @State private var doubleModel = DoubleCopyDemoModel(initial: 4.0)
    
    // 追加: ジェネリック関数の結果をUIに表示するための状態
    // - printIfEqual はコンソール出力なのでUIには出ない
    // - messageIfEqual を使って「表示用文字列」を作り、ここに入れる
    @State private var equalMessages: [String] = []
    
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
            
            Text("model.a（var, Int）= \(model.a)")
                .font(.title2)
            Text("model.b（let, Int）= \(model.b)")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Button("model.a に 456（Int）を代入する") {
                model.assignIntToA()
            }
            .buttonStyle(.borderedProminent)
            
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 10) {
                Text("関数（double）の例")
                    .font(.headline)
                
                Text("入力: double(\(doubleInput))")
                Text("出力: \(doubleResult)")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 10) {
                Text("型定義（struct / class / enum）の例")
                    .font(.headline)
                
                Text("struct: \(structTypeName)（値型）")
                Text("class : \(classTypeName)（参照型）")
                Text("enum  : \(enumTypeName)（状態の型）")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Doubleの値コピー + formSquareRoot の例")
                    .font(.headline)
                
                Text("rootA（aに相当）= \(doubleModel.rootA)")
                Text("rootB（bに相当）= \(doubleModel.rootB)")
                    .foregroundStyle(.secondary)
                
                Button("rootA に formSquareRoot() を適用する") {
                    doubleModel.applySquareRootToA()
                }
                .buttonStyle(.bordered)
                
                Text("ポイント: Doubleは値型。rootBはrootAの変更の影響を受けない。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 追加: ジェネリクス（Equatable）デモ
            VStack(alignment: .leading, spacing: 10) {
                Text("ジェネリクス（T: Equatable）の例")
                    .font(.headline)
                
                Text("printIfEqual はコンソール出力、messageIfEqual はUI表示用。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // equalMessages は onAppear で作っておき、ここで一覧表示する。
                if equalMessages.isEmpty {
                    Text("（まだ結果がありません）")
                        .foregroundStyle(.secondary)
                } else {
                    // SwiftUIで配列を表示する定番: ForEach
                    // id: \.self は、StringがHashableなので自己同一性で識別できるという指定。
                    ForEach(equalMessages, id: \.self) { msg in
                        Text(msg)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .onAppear {
            // 追加要件の呼び出し（コンソール出力）
            // ここなら「表示時に一回だけ」実行しやすく、body再評価で増殖しにくい。
            printIfEqual(123, 123)
            printIfEqual("str", "str")
            
            // UI表示用に、同じ判定を messageIfEqual で作って配列へ入れる。
            // （print結果をそのまま取り込むより、UI向けは純粋関数で作る方が設計が安全）
            equalMessages = [
                messageIfEqual(123, 123),
                messageIfEqual("str", "str")
            ].compactMap { $0 } // nil を除外して [String] にする
            
            // 既存のコンソール確認（学習用）
            if value <= 3 {
                print("valueは3以下です")
            }
            print("double(2) = \(double(2))")
            print("struct type = \(structTypeName)")
            print("class  type = \(classTypeName)")
            print("enum   type = \(enumTypeName)")
        }
    }
}

#Preview {
    ContentView()
}
