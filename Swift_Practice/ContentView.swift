/*
修正方針（重要）:
- SwiftUI アプリ（Xcode の App テンプレ）では「トップレベル（ファイル直下）」に
  実行文（関数呼び出しや式）を書けない。
  そのため、次の行はコンパイルエラーになる。

    doubleA.formSquareRoot()   // ❌ Expressions are not allowed at the top level

- トップレベルに置けるのは「宣言（var/let/struct/class/enum/func）」だけ。
- 実行したい処理は、(1) メソッドの中、(2) init / onAppear / ボタン action などの中に移す。

今回の修正:
- トップレベルの `doubleA.formSquareRoot()` を削除（実行文を排除）
- Double の「値コピー + mutating」を確認する処理は、すでに用意している
  `DoubleCopyDemoModel`（+ SwiftUI のボタン）に一本化する
- onAppear でのコンソール確認も、グローバル `doubleA/doubleB` を参照せず
  `doubleModel`（状態）を参照する形にする（設計の一貫性が上がる）

また、既存の「配列 a/b」と「Doubleの a/b」が名前衝突しやすいので、
トップレベルの Double例は「宣言だけ」残し、実行はしない。
（学習としては View 内の doubleModel で十分観測できる）
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
//
// 追加要件: func double(_ x: Int) -> Int { return x * 2 }
func double(_ x: Int) -> Int {
    return x * 2
}

/// トップレベルで「関数呼び出しを実行」したくなるが、SwiftUIアプリでは
/// `let doubledExample = double(2)` のような初期化式（initializer）は書ける。
/// （これは「宣言 + 初期化」であり、単独の実行文ではない）
/// ただし教材としては View 内表示で十分なので、残しても良いし消しても良い。
let doubledExample = double(2) // 4

// MARK: - struct / class / enum（型定義の例）
struct SomeStruct {}
class SomeClass {}
enum SomeEnum {}

/// 型名を文字列化してUI/コンソールに表示するための値（宣言+初期化なのでOK）
let structTypeName = String(describing: SomeStruct.self)
let classTypeName  = String(describing: SomeClass.self)
let enumTypeName   = String(describing: SomeEnum.self)

// MARK: - Doubleの値コピーと formSquareRoot（トップレベルは「宣言のみ」）
//
// ユーザー指定の例（概念）:
//   var a = 4.0
//   var b = a
//   a.formSquareRoot()
//
// これをトップレベルで “実行” するとエラーになるため、ここでは
// - 「宣言（初期化）だけ」置く
// - 実際の平方根適用（mutating実行）は SwiftUI の状態（doubleModel）で行う
//
// ※ `var doubleA = 4.0` / `var doubleB = doubleA` は初期化式なのでOK。
// ※ しかし `doubleA.formSquareRoot()` は単独の実行文なのでNG。
var doubleA = 4.0
var doubleB = doubleA

//
//  ContentView.swift
//  Swift_Practice
//
//  Swiftの学習要素を段階的に追加した統合サンプルである。
//  - var / let（可変・不変）
//  - 静的型付け（Int, String, Double）
//  - 配列（Array）
//  - if 条件分岐
//  - 関数（double）
//  - 型定義（struct / class / enum）
//  - 値型のコピー（Double）と mutating メソッド（formSquareRoot）
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
    
    // struct（値型）のプロパティを書き換えるので mutating が必要
    mutating func assignIntToA() {
        a = 456
    }
}

// MARK: - Doubleコピー + formSquareRoot のデモ用モデル（値型struct）
//
// ここが「ユーザー指定の a/b の例」を SwiftUIで安全に実行する場所。
// - init で rootA/rootB を同じ値から開始（b = a の値コピーに相当）
// - applySquareRootToA() で rootA だけを in-place 更新（a.formSquareRoot() に相当）
struct DoubleCopyDemoModel {
    // aに相当（平方根を適用して変化する側）
    var rootA: Double
    
    // bに相当（aのコピーなので、aの更新の影響を受けない側）
    var rootB: Double
    
    init(initial: Double) {
        // ユーザー指定:
        //   var a = 4.0
        //   var b = a
        // に対応する初期化
        self.rootA = initial
        self.rootB = initial // ここで値コピー
    }
    
    mutating func applySquareRootToA() {
        // ユーザー指定:
        //   a.formSquareRoot()
        // に対応する処理。
        // formSquareRoot は mutating で in-place 更新するため rootA が書き換わる。
        rootA.formSquareRoot()
    }
}

// MARK: - SwiftUI View（Viewはstruct）
struct ContentView: View {
    // 既存: Int/配列デモ
    @State private var model = VarLetArrayDemoModel(
        a: 0,
        b: 100,
        intArray: [1, 2, 3],
        stringArray: ["a", "b", "c"]
    )
    
    // 追加: Doubleコピーのデモ
    @State private var doubleModel = DoubleCopyDemoModel(initial: 4.0)
    
    private var isValueLeq3: Bool {
        value <= 3
    }
    
    private let doubleInput: Int = 2
    private var doubleResult: Int {
        // double は純粋関数なので body 再評価で何度呼ばれても安全
        double(doubleInput)
    }
    
    // Doubleデモの「期待値」を UI に出すための補助
    private var expectedAfterSqrt: Double { 2.0 }
    private var expectedB: Double { 4.0 }
    
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
                
                Text("※ func double(_ x: Int) -> Int の `_` により、呼び出しは double(2) と書ける。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 型定義（struct / class / enum）の表示
            VStack(alignment: .leading, spacing: 10) {
                Text("型定義（struct / class / enum）の例")
                    .font(.headline)
                
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
            
            // Doubleの値コピー + formSquareRoot（追加・修正版）
            VStack(alignment: .leading, spacing: 10) {
                Text("Doubleの値コピー + formSquareRoot の例")
                    .font(.headline)
                
                // 現在値
                Text("rootA（aに相当）= \(doubleModel.rootA)")
                Text("rootB（bに相当）= \(doubleModel.rootB)")
                    .foregroundStyle(.secondary)
                
                // 期待される挙動を明示（教材としての“正解”）
                Text("期待: rootAは平方根後 \(expectedAfterSqrt), rootBは \(expectedB) のまま")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Button("rootA に formSquareRoot() を適用する") {
                    // 実行文（mutating更新）はボタンactionに置く。
                    // ここなら「押したときだけ」実行され、body再評価で暴発しない。
                    doubleModel.applySquareRootToA()
                }
                .buttonStyle(.bordered)
                
                Text("ポイント: Doubleは値型。rootBはrootAの“参照”ではなく“コピー”なので、rootA更新の影響を受けない。")
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
            
            // Double値コピーの確認（コンソール）
            // ここではトップレベル実行を避けているため、初期状態（4.0/4.0）を表示する。
            print("doubleModel.rootA(initial) = \(doubleModel.rootA)")
            print("doubleModel.rootB(initial) = \(doubleModel.rootB)")
        }
    }
}

#Preview {
    ContentView()
}
