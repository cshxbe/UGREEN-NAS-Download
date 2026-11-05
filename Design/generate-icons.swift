import AppKit
import Foundation
let root=URL(fileURLWithPath:CommandLine.arguments[1])
func rounded(_ r:NSRect,_ radius:CGFloat)->NSBezierPath{NSBezierPath(roundedRect:r,xRadius:radius,yRadius:radius)}
func line(_ points:[NSPoint],_ width:CGFloat,_ color:NSColor){let p=NSBezierPath();p.lineWidth=width;p.lineCapStyle = .round;p.lineJoinStyle = .round;p.move(to:points[0]);for pt in points.dropFirst(){p.line(to:pt)};color.setStroke();p.stroke()}
func render(_ size:Int,_ toolbar:Bool,_ destination:URL,dark:Bool=false)throws{
 let rep=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:size,pixelsHigh:size,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
 NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=NSGraphicsContext(bitmapImageRep:rep)
 let t=AffineTransform(scale:CGFloat(size)/128);(t as NSAffineTransform).concat()
 if !toolbar {
  let plate=rounded(NSRect(x:7,y:7,width:114,height:114),25)
  NSGradient(starting:dark ? NSColor(srgbRed:0.045,green:0.065,blue:0.08,alpha:1) : NSColor(srgbRed:0.025,green:0.43,blue:0.42,alpha:1),ending:dark ? NSColor(srgbRed:0.12,green:0.18,blue:0.19,alpha:1) : NSColor(srgbRed:0.25,green:0.79,blue:0.65,alpha:1))!.draw(in:plate,angle:70)
  NSColor.white.withAlphaComponent(dark ? 0.12 : 0.24).setStroke();plate.lineWidth=1;plate.stroke()
  let shadow=NSShadow();shadow.shadowColor=NSColor.black.withAlphaComponent(0.15);shadow.shadowBlurRadius=5;shadow.shadowOffset=NSSize(width:0,height:-3);NSGraphicsContext.saveGraphicsState();shadow.set()
  (dark ? NSColor(srgbRed:0.15,green:0.24,blue:0.23,alpha:1) : NSColor.white.withAlphaComponent(0.97)).setFill();rounded(NSRect(x:32,y:27,width:64,height:65),11).fill();NSGraphicsContext.restoreGraphicsState()
  let green=dark ? NSColor(srgbRed:0.44,green:0.91,blue:0.77,alpha:1) : NSColor(srgbRed:0.02,green:0.47,blue:0.41,alpha:1)
  line([NSPoint(x:48,y:42),NSPoint(x:48,y:57)],3,green.withAlphaComponent(0.45));line([NSPoint(x:61,y:42),NSPoint(x:61,y:57)],3,green.withAlphaComponent(0.45))
  green.setFill();NSBezierPath(ovalIn:NSRect(x:78,y:39,width:5,height:5)).fill()
  line([NSPoint(x:64,y:105),NSPoint(x:64,y:73)],6,green)
  line([NSPoint(x:52,y:84),NSPoint(x:64,y:72),NSPoint(x:76,y:84)],6,green)
 } else {
  let black=NSColor.black
  let p=NSBezierPath();p.lineWidth=7;p.lineCapStyle = .round;p.lineJoinStyle = .round
  p.move(to:NSPoint(x:44,y:87));p.line(to:NSPoint(x:34,y:87));p.line(to:NSPoint(x:34,y:28));p.line(to:NSPoint(x:94,y:28));p.line(to:NSPoint(x:94,y:87));p.line(to:NSPoint(x:84,y:87));black.setStroke();p.stroke()
  line([NSPoint(x:64,y:112),NSPoint(x:64,y:65)],7,black);line([NSPoint(x:49,y:79),NSPoint(x:64,y:64),NSPoint(x:79,y:79)],7,black)
  line([NSPoint(x:48,y:44),NSPoint(x:66,y:44)],6,black);black.setFill();NSBezierPath(ovalIn:NSRect(x:79,y:41,width:6,height:6)).fill()
 }
 NSGraphicsContext.restoreGraphicsState()
 try rep.representation(using:.png,properties:[:])!.write(to:destination)
}
let extensionDir=root.appendingPathComponent("Extension")
for size in [16,32,48,64,96,128,256]{try render(size,false,extensionDir.appendingPathComponent("icon-\(size).png"))}
for size in [16,32,48,64,128]{try render(size,true,extensionDir.appendingPathComponent("toolbar-\(size).png"))}
let appRoot=root.appendingPathComponent("Xcode/UGREEN NAS Download/UGREEN NAS Download")
let icons=root.appendingPathComponent("Design/LegacyAppIcon.appiconset")
try FileManager.default.createDirectory(at:icons,withIntermediateDirectories:true)
var entries:[[String:String]]=[]
for size in [16,32,128,256,512]{for scale in [1,2]{let filename="app-\(size)-\(scale)x.png";try render(size*scale,false,icons.appendingPathComponent(filename));entries.append(["idiom":"mac","size":"\(size)x\(size)","scale":"\(scale)x","filename":filename])}}
let json:[String:Any]=["images":entries,"info":["author":"xcode","version":1]]
try JSONSerialization.data(withJSONObject:json,options:[.prettyPrinted,.sortedKeys]).write(to:icons.appendingPathComponent("Contents.json"))
try render(256,false,appRoot.appendingPathComponent("Resources/Icon.png"))
print("Icônes couleur et barre d’outils générées")

for size in [16,32,48,64,96,128,256]{try render(size,false,extensionDir.appendingPathComponent("icon-dark-\(size).png"),dark:true)}
let large=appRoot.appendingPathComponent("Assets.xcassets/LargeIcon.imageset")
try render(256,false,large.appendingPathComponent("icon-light.png"))
try render(256,false,large.appendingPathComponent("icon-dark.png"),dark:true)
let largeJSON:[String:Any]=["images":[["idiom":"mac","filename":"icon-light.png"],["idiom":"mac","filename":"icon-dark.png","appearances":[["appearance":"luminosity","value":"dark"]]]],"info":["author":"xcode","version":1]]
try JSONSerialization.data(withJSONObject:largeJSON,options:[.prettyPrinted,.sortedKeys]).write(to:large.appendingPathComponent("Contents.json"))
