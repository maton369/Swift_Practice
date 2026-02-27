/*
このファイルで発生していたエラー:
  global 'var' declaration requires an initializer expression or an explicitly stated getter

原因:
  ファイル直下（グローバル領域）で

    var a: Int
    let b: Int

  のように「型だけ書いて初期化していない」宣言があるため。
  Swiftはグローバルの var/let をアプリ起動時に確実に初期化できないといけないので、
  初期値（initializer）か、computed property の getter が必須になる。

対処:
  1) グローバルに置くなら初期値を入れる
  2) そもそも SwiftUI の状態として ContentView 内へ移す
  3) 学習用のモデル（VarLetArrayDemoModel）に寄せる

今回は「今までのものに追加」しつつ、エラーを確実に潰すために
グローバルの a/b は「初期値つき」に直して残す。
  - a は var なので後から再代入できる
  - b は let なので初期化後に固定される

また、配列の追加（ユーザー指定）:
  let a = [1, 2, 3]
  let b = ["a", "b", "c"]

は、既存コードでは a/b を Int として使っているので名前衝突する。
Swiftは同一スコープで同名の変数を2回宣言できないため、
配列側は `intArray` / `stringArray` のように名前を分けるのが安全である。
（もしどうしても a/b という名前で配列を持ちたいなら、Intのa/bと別スコープに置く必要がある。）

以下が「エラー解消 + 配列追加 + 詳細コメント」を反映した統合版である。
*/

/// グローバル（ファイル直下）の `var` は初期値が必要なので、0で初期化する。
/// - var なので、必要なら後から `globalA = 123` のように再代入できる。
/// - ただし SwiftUI の学習では、UIに反映させたい値は `@State` 等で管理するのが基本であり、
///   グローバル変数は原則おすすめしない（依存関係が追いづらくなるため）。
var globalA: Int = 0

/// グローバル（ファイル直下）の `let` も初期値が必要なので、100で初期化する。
/// - let なので、この値は固定であり再代入できない。
let globalB: Int = 100

/// ユーザー指定の「配列の追加」
/// `let a = [1, 2, 3]` と `let b = ["a", "b", "c"]` をそのまま書くと、
/// すでに `globalA/globalB` や、モデル内の `a/b` と名前が衝突して混乱しやすい。
/// そのため、意味が分かる名前で定義する。
///
/// - `[1, 2, 3]` は要素がすべて Int なので、型推論で `[Int]` になる。
/// - `["a", "b", "c"]` は要素がすべて String なので、型推論で `[String]` になる。
let a = [1, 2, 3]          // ユーザー指定: Int配列（[Int]）
let b = ["a", "b", "c"]    // ユーザー指定: String配列（[String]）

// 上の a/b を「学習用により分かりやすくしたい」なら、以下のような別名もアリ。
// （ただし今回はユーザー指定に合わせて a/b を残している）
// let intArray = [1, 2, 3]
// let stringArray = ["a", "b", "c"]

//
//  ContentView.swift
//  Swift_Practice
//
//  Swiftの「var / let（変数と定数）」「型（Int, String）」「配列（Array）」を、SwiftUIの画面で確認するサンプルである。
//  - var は「再代入できる（mutable）」
//  - let は「再代入できない（immutable）」
//  - Array は「同じ型の要素」を複数保持するコレクション
//  - [1, 2, 3] は [Int]、["a","b","c"] は [String] と推論される（型推論）
//
//  ここでは、
//  - a（var）はボタンで値を変更できる
//  - b（let）は初期化後に変更できない
//  - 配列（Int配列 / String配列）は「型が揃った配列」であることを表示できる
// という構成で、SwiftUIとセットで理解できるようにしている。
//
//  Created by maton on 2026/02/23.
//

import SwiftUI

// MARK: - 型 + var/let + 配列(Array) のデモ用モデル
//
// SwiftUIでは「画面に出す状態（State）」をモデルとしてまとめると見通しが良い。
// ここでは a（可変）と b（不変）に加えて、配列の例（Int配列とString配列）もまとめる。
struct VarLetArrayDemoModel {
    // var: 値を変更できるプロパティ（可変）
    // Int型なので、代入できるのは Int のみである。
    var a: Int
    
    // let: 値を変更できないプロパティ（不変）
    // 初期化時に一度だけ値が決まり、その後は再代入できない。
    let b: Int
    
    // 配列は「同じ型の要素」を並べて持つ。
    // ここでは [Int] と [String] を持たせる。
    //
    // 注意:
    // - Swiftの配列は値型（struct）で、コピーオンライト（Copy-on-Write）最適化がある。
    // - 見た目は参照っぽく扱えるが、内部的には必要な時だけコピーが発生する。
    let intArray: [Int]
    let stringArray: [String]
    
    // a は var なので、後から代入して更新できる。
    // `mutating` が付いているのは、struct（値型）の中でプロパティを書き換えるため。
    // struct は基本的に「自分自身を書き換える」操作は mutating が必要である。
    mutating func assignIntToA() {
        a = 456
    }
    
    // b は let なので、以下のようなコードはコンパイルエラーになるため書けない。
    //
    // mutating func assignIntToB() {
    //     b = 999 // ❌ let のプロパティは変更不可
    // }
    
    // 型の違いによる代入不可も同様にコンパイルエラーになる。
    //
    // mutating func assignStringToA() {
    //     a = "abc" // ❌ Int に String は代入できない
    // }
    
    // 配列も同様に、要素の型が揃っていないといけない。
    // 例えば次はコンパイルエラー（または意図しない推論）になりやすいので避ける:
    //
    // let mixed = [1, "a"] // ❌ 要素型が揃わない（Anyに落ちる等の問題が起きる）
}

// MARK: - SwiftUI View
struct ContentView: View {
    // @State は「この値が変化したらUIを更新する」というSwiftUIの状態管理である。
    //
    // 仕組み（重要）:
    // - SwiftUI は `body` を状態から計算して Viewツリーを作る（宣言的UI）
    // - @State の値が変わると、SwiftUI が `body` を再評価して差分描画する
    //
    // ここでのポイント:
    // - model.a は var なので、ボタンで変更できる（状態遷移を起こせる）
    // - model.b / model.intArray / model.stringArray は let なので固定（状態遷移しない）
    @State private var model = VarLetArrayDemoModel(
        a: 0,
        b: 100,
        // ここでは「ユーザー指定の配列 a/b（グローバル）」を再利用しても良いが、
        // グローバル依存が増えると理解が難しくなるので、学習用にはローカルで明示している。
        intArray: [1, 2, 3],
        stringArray: ["a", "b", "c"]
    )
    
    var body: some View {
        VStack(spacing: 16) {
            // SF Symbols のアイコン表示例
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            // a（var）: ボタンで変更できる値
            // 文字列補間 \(...) を使うことで、Int を Text に表示できる
            Text("a（var, Int）= \(model.a)")
                .font(.title2)
            
            // b（let）: 初期化後に変更できない値
            Text("b（let, Int）= \(model.b)")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            // a を更新する操作
            Button("a に 456（Int）を代入する") {
                // `assignIntToA()` は model.a を書き換える。
                // @State の内容が更新されるので、SwiftUIが `body` を再評価し表示が更新される。
                model.assignIntToA()
            }
            .buttonStyle(.borderedProminent)
            
            // 配列の表示（SwiftUI側）
            //
            // 配列はそのまま表示しづらいことがあるので、説明用に「見やすい文字列」に整形している。
            // - Int配列: 各要素を String に変換（map）してから joined する
            // - String配列: すでに String なので joined だけでOK
            VStack(alignment: .leading, spacing: 10) {
                Text("配列（Array）の例")
                    .font(.headline)
                
                // [Int] の表示
                Text("intArray（[Int]）= [\(model.intArray.map(String.init).joined(separator: ", "))]")
                
                // [String] の表示
                Text("stringArray（[String]）= [\(model.stringArray.joined(separator: ", "))]")
                
                // count は「配列の要素数」を返す
                Text("intArray.count = \(model.intArray.count), stringArray.count = \(model.stringArray.count)")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 説明カード（var/let/型）
            VStack(alignment: .leading, spacing: 10) {
                Text("ポイント")
                    .font(.headline)
                
                Text("・var は再代入できる（mutable）。a はボタンで値が変わる。")
                Text("・let は再代入できない（immutable）。b は初期値のまま固定される。")
                Text("・配列は同じ型の要素を並べる。[1,2,3] は [Int]、[\"a\",\"b\",\"c\"] は [String]。")
                Text("・Int 型には Int しか代入できない。a = \"abc\" のような代入はコンパイルエラー。")
                
                Text("例（コンパイルエラーになるもの）:")
                    .font(.subheadline)
                    .padding(.top, 4)
                
                // ここは「ビルドを壊さずに」学習できるよう、文字列として例を提示している。
                Text("a = \"abc\"  // ❌ Int に String は代入できない")
                    .font(.caption)
                    .textSelection(.enabled)
                
                Text("b = 999     // ❌ let は再代入できない")
                    .font(.caption)
                    .textSelection(.enabled)
                
                Text("let mixed = [1, \"a\"] // ❌ 配列要素の型が揃わない（意図せずAnyになる等）")
                    .font(.caption)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
