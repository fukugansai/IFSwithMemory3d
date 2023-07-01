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
                    let s = 32
                    let siz:Float = 0.002
                    
                    var m:[[Int]] = []
                    for y in 0 ..< 8 {
                        m.append([])
                        for _ in 0 ..< 8 {
                            let rr = Float.random(in: 0 ..< Float(1))
                            if rr > 0.4 {
                                m[y].append(0)
                            }
                            else {
                                m[y].append(1)
                            }
                        }
                    }
                    var v:[[Int]] = [[1],[2],[3],[4],[5],[6],[7],[8]]
                    for _ in 0 ..< 6 {
                        var nv:[[Int]] = []
                        for vi in v {
                            let vli = vi.last!-1
                            //print(vli)
                            for vn in 0 ..< 8 {
                                if m[vli][vn] == 1 {
                                    var vin:[Int] = vi
                                    vin.append(vn+1)
                                    nv.append(vin)
                                }
                            }
                        }
                        v = nv
                    }
                    print(m)
                    
                    let modelEntityMesh = MeshResource.generateBox(size: SIMD3<Float>(siz, siz, siz))
                    let meshModels = modelEntityMesh.contents.models

                    // モデルの名前を取得する。
                    var m1:MeshResource.Model?
                    for mm in meshModels {
                        m1 = mm
                    }

                    var transformedContents = MeshResource.Contents()
                    transformedContents.instances.removeAll()
                    let step:Float = siz * 32.0
                    var count:Int = 0
                    for vi in v {
                        var fx:Float = 0.0
                        var fy:Float = 0.0
                        var fz:Float = 0.0
                        for vn in vi {
                            fx /= 2.0
                            fy /= 2.0
                            fz /= 2.0
                            switch vn {
                            case 1:
                                fx -= step
                                fy -= step
                                fz -= step
                            case 2:
                                fx += step
                                fy -= step
                                fz -= step
                            case 3:
                                fx -= step
                                fy += step
                                fz -= step
                            case 4:
                                fx += step
                                fy += step
                                fz -= step
                            case 5:
                                fx -= step
                                fy -= step
                                fz += step
                            case 6:
                                fx += step
                                fy -= step
                                fz += step
                            case 7:
                                fx -= step
                                fy += step
                                fz += step
                            case 8:
                                fx += step
                                fy += step
                                fz += step
                            default:
                                fx -= step
                                fy -= step
                                fz -= step
                            }
                        }
                        let f44 = simd_float4x4(
                            columns: (simd_float4(1.0, 0, 0, 0),
                                      simd_float4(0, 1.0, 0, 0),
                                      simd_float4(0, 0, 1.0, 0),
                                      simd_float4(fx, fy, fz, 1.0)))
                        count += 1
                        let mri = MeshResource.Instance(id: String(count), model: m1!.id, at: f44)
                        transformedContents.instances.insert(mri)
                    }

                    transformedContents.models = meshModels
                    let transformedMesh = try! MeshResource.generate(from: transformedContents)
                    let modelb = ModelEntity(mesh: transformedMesh, materials: [SimpleMaterial(color: UIColor(red:0.5, green:0.5, blue: 1, alpha:1), isMetallic: true)])
                    
                    content.add(modelb)
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
