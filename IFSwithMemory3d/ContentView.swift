//
//  ContentView.swift
//  IFSwithMemory3d
//
//  Created by 矢野 雅章 on 2023/06/30.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State var enlarge = false
    @State var f:[[[Int]]] = []

    var body: some View {
        TimelineView(.animation) { context in
            VStack {
                RealityView { content in
                    // Add the initial RealityKit content
                    let siz:Float = 0.002

                    // 行列の初期化
                    var m = [[Int]](repeating: [Int](repeating: 0, count: 8), count: 8)

                    // その行列のいち部分を１以上の値に設定しなおす。n個まで
                    let maxCountUp = 36
                    var countUp = 0
                    while countUp < maxCountUp {
                        let xi: Int = Int.random(in: 0..<8)
                        let yi: Int = Int.random(in: 0..<8)
                        if m[yi][xi] == 0 {
                            countUp += 1
                            m[yi][xi] = countUp
                        }
                    }

                    // それでねっ、ありえるすべての変換列をね、設定するのよね
                    var v:[(h:Int, ar:[Int])] = [(1,[1]),(1,[2]),(1,[3]),(1,[4]),(1,[5]),(1,[6]),(1,[7]),(1,[8])]
                    // hは使ってないですね。もはや…
                    let maxDepth = 6
                    for _ in 0 ..< maxDepth {
                        var nv:[(h:Int, ar:[Int])] = []
                        for vi in v {
                            let vli = vi.ar.last!-1
                            //print(vli)
                            for vn in 0 ..< 8 {
                                if m[vli][vn] >= 1 {
                                    var vin:(h:Int, ar:[Int]) = vi
                                    vin.ar.append(vn+1)
                                    if m[vli][vn] > vin.h {
                                        vin.h = m[vli][vn]
                                    }
                                    nv.append(vin)
                                }
                            }
                        }
                        v = nv
                    }
 
                    let modelEntityMesh = MeshResource.generateBox(size: SIMD3<Float>(siz, siz, siz))
                    let meshModels = modelEntityMesh.contents.models

                    // モデルの名前を取得する。後で使う
                    var m1:MeshResource.Model?
                    for mm in meshModels {
                        m1 = mm
                    }

                    var transformedContents:[MeshResource.Contents] = []
                    for _ in 0..<maxDepth+2 {
                        var tc = MeshResource.Contents()
                        tc.instances.removeAll()
                        transformedContents.append(tc)
                    }
                    let step:Float = siz * 32.0
                    var count:Int = 0
                    for vi in v {
                        var fx:Float = 0.0
                        var fy:Float = 0.0
                        var fz:Float = 0.0
                        var cc = 0
                        for vn in vi.ar {
                            fx /= 2.0
                            fy /= 2.0
                            fz /= 2.0
                            fx = [1, 3, 5, 7].contains(vn) ? fx - step : fx + step
                            fy = [1, 2, 5, 6].contains(vn) ? fy - step : fy + step
                            fz = [1, 2, 3, 4].contains(vn) ? fz - step : fz + step
                            if [1, 2, 5, 6].contains(vn) {
                                cc += 1
                            }
                        }
                        let f44 = simd_float4x4(
                            columns: (simd_float4(1.0, 0, 0, 0),
                                      simd_float4(0, 1.0, 0, 0),
                                      simd_float4(0, 0, 1.0, 0),
                                      simd_float4(fx, fy, fz, 1.0)))
                        count += 1
                        let mri = MeshResource.Instance(id: String(count), model: m1!.id, at: f44)
                        precondition(0 <= cc && cc <= maxDepth+1)
                        transformedContents[cc].instances.insert(mri)
                    }

                    var tcc = 0.0
                    count = 0
                    for var tc in transformedContents {
                        tcc = Double(count) / Double(maxDepth)
                        //tcc = tcc * tcc
                        tc.models = meshModels
                        let transformedMesh = try! MeshResource.generate(from: tc)
                        let 黒体輻射 = UIColor(red:1.1-0.9*tcc, green:0.7-1.0*tcc, blue: 0.1, alpha:1.0)
                        let 新緑 = UIColor(red:0.5 - 0.5*tcc, green:1.0-0.7*tcc, blue: 0.1, alpha:1.0)
                        let modelb = ModelEntity(mesh: transformedMesh, materials: [SimpleMaterial(color: 新緑, isMetallic: false)])
                        content.add(modelb)
                        count+=1
                    }
                } update: { content in
                }
                .rotation3DEffect(
                    Rotation3D(
                        angle: Angle2D(degrees: 60*context.date.timeIntervalSinceReferenceDate), axis: .y)
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
