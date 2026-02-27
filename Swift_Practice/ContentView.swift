/*
追加要件:
  let value = 2
  if value <= 3 { print("valueは3以下です") }

を「今までのもの」に統合し、詳細コメント付きで示す。

ポイント:
- if は条件分岐（ブール式が true のときだけ処理を実行する）
- `<=` は「以下（less than or equal）」で、比較の結果は Bool（true/false）になる
- SwiftUIでは `print` はコンソール出力であり、UIには直接見えない
  → 学習としては「コンソールに出る」ことも見せつつ、
     画面にも同じ判定結果を表示すると理解しやすい

また、これまでの統合版では
- グローバルの未初期化 var/let エラー回避のため `globalA/globalB`
- ユーザー指定の配列 `a` / `b`
- SwiftUIの @State model による表示
を含んでいる。そこに `value` と if 判定を追加する。
*/

/// グローバル（ファイル直下）の `var` は初期値が必要なので初期化する。
/// - ただしSwiftUIではグローバルは極力使わず、@State等で管理するのが基本。
var globalA: Int = 0

/// グローバル（ファイル直下）の `let` も初期値が必要なので初期化する。
let globalB: Int = 100

/// ユーザー指定の配列追加（そのまま a/b という名前で定義）
/// - a は [Int]
/// - b は [String]
/// ※ 既存の Int の a/b と同名にすると衝突するため、Int側は globalA/globalB や model.a/model.b として分離している。
let a = [1, 2, 3]          // [Int]
let b = ["a", "b", "c"]    // [String]

/// 追加要件: if 条件分岐の入力値
/// - let なので不変（immutable）
/// - ここでは 2 を固定して、判定結果が true になるケースを示す
let value = 2

//
//  ContentView.swift
//  Swift_Practice
//
//  Swiftの学習要素を段階的に追加した統合サンプルである。
//  - var / let（可変・不変）
//  - 静的型付け（Int, String）
//  - 配列（Array: 同型要素コレクション）
//  - if 条件分岐（Bool式で処理を分岐）
//
//  Created by maton on 2026/02/23.
//

import SwiftUI

// MARK: - 型 + var/let + 配列(Array) のデモ用モデル
//
// SwiftUIでは「画面に出す状態（State）」をモデルとしてまとめると見通しが良い。
// ここでは
// - a（可変 Int）
// - b（不変 Int）
// - intArray（不変 [Int]）
// - stringArray（不変 [String]）
// を保持し、SwiftUIで表示する。
struct VarLetArrayDemoModel {
    var a: Int          // var: 可変（後から再代入できる）
    let b: Int          // let: 不変（初期化後は固定）
    let intArray: [Int] // [Int]: Intの配列
    let stringArray: [String] // [String]: Stringの配列
    
    // struct（値型）の中でプロパティを書き換えるので `mutating` が必要
    mutating func assignIntToA() {
        a = 456
    }
}

// MARK: - SwiftUI View
struct ContentView: View {
    // @State は「この値が変化したらUIを更新する」というSwiftUIの状態管理である。
    // ここで変化するのは model.a のみ（ボタンで更新）。
    @State private var model = VarLetArrayDemoModel(
        a: 0,
        b: 100,
        intArray: [1, 2, 3],
        stringArray: ["a", "b", "c"]
    )
    
    // 追加要件の if 判定結果を SwiftUI上でも見せるため、判定を computed property にする。
    //
    // `value <= 3` は比較演算であり、結果は Bool（true/false）になる。
    // - true なら「条件を満たす」
    // - false なら「条件を満たさない」
    //
    // ここではグローバルの `value` を参照しているが、
    // 学習が進んだら `@State private var value = 2` のように View 内へ移すのがより自然。
    private var isValueLeq3: Bool {
        value <= 3
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
                // varなので再代入できる
                model.assignIntToA()
            }
            .buttonStyle(.borderedProminent)
            
            // 配列の表示
            VStack(alignment: .leading, spacing: 10) {
                Text("配列（Array）の例")
                    .font(.headline)
                
                // Int配列: String化して joined
                Text("intArray（[Int]）= [\(model.intArray.map(String.init).joined(separator: ", "))]")
                
                // String配列: そのまま joined
                Text("stringArray（[String]）= [\(model.stringArray.joined(separator: ", "))]")
                
                Text("intArray.count = \(model.intArray.count), stringArray.count = \(model.stringArray.count)")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // if 条件分岐の表示（追加）
            VStack(alignment: .leading, spacing: 10) {
                Text("if 条件分岐の例")
                    .font(.headline)
                
                // value は let なので固定値として表示される
                Text("value = \(value)")
                
                // 判定式と結果を見せる
                Text("判定: value <= 3 は \(isValueLeq3 ? "true" : "false")")
                    .foregroundStyle(.secondary)
                
                // if は「条件がtrueのときだけ」処理を実行する。
                // SwiftUIでは if を View の中で使うと「表示の分岐」にも使える。
                if isValueLeq3 {
                    // 追加要件の print と同じ意味のメッセージをUIでも表示する。
                    Text("valueは3以下です")
                        .font(.title3)
                    
                    // print はコンソール出力。UIには出ないが、デバッグ・学習には有用。
                    // 注意: SwiftUIでは body が再評価されるたびに実行されうるため、
                    //       ここに print を置くと再描画のたびにログが増える可能性がある。
                    //
                    // そのため、print を「確実に一回だけ」出したいなら
                    // onAppear / ボタン / イベントハンドラ内に置くのが安全。
                } else {
                    Text("valueは3より大きいです")
                        .font(.title3)
                }
                
                // 「追加要件どおりの if + print」を、学習用にそのままの形で載せる（コメントとして保持）。
                // 実際に print を確実に一回だけ動かすなら、下の onAppear の方が挙動が安定する。
                Text("（コンソール出力は下の onAppear で確認）")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        
        // SwiftUIのライフサイクルイベント例:
        // - onAppear は View が表示されたタイミングで呼ばれる。
        // - 追加要件の if + print を「一回だけ実行したい」場合に適している。
        .onAppear {
            // 追加要件そのまま:
            // `value <= 3` が true のときだけ print が走る。
            if value <= 3 {
                print("valueは3以下です")
            }
        }
    }
}

#Preview {
    ContentView()
}
