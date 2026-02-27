/*
追加要件:
  func double(_ x: Int) -> Int { return x * 2 }
  double(2) // 4

を「今までの統合コード」に追加し、詳細コメント付きで統合する。

今回の学習ポイント（関数）:
- func は「入力（引数）→出力（戻り値）」の変換をまとめたもの
- `(_ x: Int)` の `_` は「呼び出し側の引数ラベルを省略する」指定
  - double(2) と書ける（double(x: 2) ではない）
- `-> Int` は戻り値の型
- `return x * 2` は Int の掛け算で、結果も Int

SwiftUIとの接続:
- 関数結果を Text に表示することで「値→UI」の流れに乗せる
- print でコンソール確認もできるが、body内に副作用を置かないよう onAppear を利用する
*/

/// グローバル（ファイル直下）の `var` は初期値が必要なので初期化する。
/// - SwiftUIで画面に反映したい状態は @State 等で管理するのが基本だが、ここでは言語仕様の説明用に残している。
var globalA: Int = 0

/// グローバル（ファイル直下）の `let` も初期値が必要なので初期化する。
let globalB: Int = 100

/// ユーザー指定の配列追加（そのまま a/b という名前で定義）
/// - a は [Int]
/// - b は [String]
/// ※ model.a/model.b（Int）と同名にならないよう、Int側は model の中に閉じている。
let a = [1, 2, 3]          // [Int]
let b = ["a", "b", "c"]    // [String]

/// 追加要件: if 条件分岐の入力値
/// - let なので固定値
let value = 2

// MARK: - 追加要件: 関数 double
//
// `double` は「Int を受け取り、2倍した Int を返す」純粋関数である。
// ここでの純粋（pure）という意味は、同じ入力に対して常に同じ出力を返し、
// 外部状態を変更しない（副作用がない）という性質を指す。
// 学習の観点では、SwiftUIの body に安全に組み込める処理の典型でもある。
//
// 引数の書き方:
//   func double(_ x: Int) -> Int
//        ^^^^^
//        `_` は「引数ラベル（argument label）を省略する」指定である。
// これにより呼び出し側は
//   double(2)
// のように書ける。
// `_` が無い場合（例: func double(x: Int) -> Int）だと
//   double(x: 2)
// と書く必要がある。
func double(_ x: Int) -> Int {
    // x * 2 は Int 同士の乗算であり、結果も Int。
    // Swiftは静的型付けなので、ここで型が不整合ならコンパイル時に弾かれる。
    return x * 2
}

// `double(2)` の結果は 4。
// ただし、ファイル直下での式の評価や print は学習的にはOKでも、
// 実アプリでは「いつ実行されるか」が曖昧になりやすいので、
// 画面表示や onAppear で確認する方が分かりやすい。
let doubledExample = double(2) // 4

//
//  ContentView.swift
//  Swift_Practice
//
//  Swiftの学習要素を段階的に追加した統合サンプルである。
//  - var / let（可変・不変）
//  - 静的型付け（Int, String）
//  - 配列（Array: 同型要素コレクション）
//  - if 条件分岐（Bool式で処理を分岐）
//  - 関数（入力→出力の変換: double）
//
//  Created by maton on 2026/02/23.
//

import SwiftUI

// MARK: - 型 + var/let + 配列(Array) のデモ用モデル
struct VarLetArrayDemoModel {
    var a: Int
    let b: Int
    let intArray: [Int]
    let stringArray: [String]
    
    mutating func assignIntToA() {
        a = 456
    }
}

// MARK: - SwiftUI View
struct ContentView: View {
    @State private var model = VarLetArrayDemoModel(
        a: 0,
        b: 100,
        intArray: [1, 2, 3],
        stringArray: ["a", "b", "c"]
    )
    
    // `value <= 3` の比較結果（Bool）をまとめておく。
    // body側で同じ式を何度も書かなくて済む上、意味が明確になる。
    private var isValueLeq3: Bool {
        value <= 3
    }
    
    // 関数 double をUI表示で使うために、例の入力を定義しておく。
    // - ここは let なので固定であり、常に同じ結果が表示される。
    // - もし動的に変えたいなら @State にしてStepper等で更新すると良い。
    private let doubleInput: Int = 2
    
    // double の結果（Int）を計算する computed property。
    // double は副作用がない純粋関数なので、body再評価時に何度呼ばれても安全である。
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
                
                // SwiftUIでは if を View の構造分岐として使える。
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
            
            // 追加: 関数 double の表示
            VStack(alignment: .leading, spacing: 10) {
                Text("関数（double）の例")
                    .font(.headline)
                
                // 入力と出力をセットで表示し、「関数=変換」であることを見せる。
                Text("入力: double(\(doubleInput))")
                Text("出力: \(doubleResult)")
                    .font(.title3)
                
                // ユーザー指定の「double(2) // 4」と対応付ける説明
                Text("例: double(2) = 4")
                    .foregroundStyle(.secondary)
                
                // 引数ラベル `_` の意味をUIでも説明しておく
                Text("※ 定義が func double(_ x: Int) -> Int なので、呼び出しは double(2) と書ける（double(x: 2) ではない）。")
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
            // 追加要件（if + print）を「表示タイミングで一回だけ」実行する。
            // SwiftUIでは body が何度も再評価されるので、副作用はここやボタンactionに寄せるのが安全。
            if value <= 3 {
                print("valueは3以下です")
            }
            
            // 追加要件（double）の結果をコンソールでも確認できるようにする。
            // ここでの print は onAppear で一回だけなのでログが増え続けにくい。
            print("double(2) = \(double(2))") // 4
        }
    }
}

#Preview {
    ContentView()
}
