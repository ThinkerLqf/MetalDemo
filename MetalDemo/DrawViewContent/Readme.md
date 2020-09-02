# Using Metal to Draw a View's Contents

使用Metal绘制视图内容

Create a MetalKit view and a render pass to draw the view's contents.

创建MetalKit视图和渲染过程以绘制视图的内容。

## Overview

In this sample, you'll learn the basics of rendering graphics content with Metal. 
You'll use the MetalKit framework to create a view that uses Metal to draw the contents of the view.  Then, you'll encode commands for a render pass that erases the view to a background color.

在本示例中，您将学习使用Metal渲染图形的基础知识。

您将使用MetalKit框架创建一个使用Metal绘制视图内容的视图。

然后，将对一个用于将视图擦除后设置自定义背景色的渲染过程的命令进行编码。

- Note: MetalKit automates windowing system tasks, loads textures, and handles 3D model data. See [MetalKit][MetalKit] for more information.
- Note: MetalKit自动执行窗口系统任务、加载纹理和处理三维模型数据。有关详细信息，请参阅MetalKit。

## Prepare a MetalKit View to Draw
准备要绘制的MetalKit视图

MetalKit provides a class called [`MTKView`][MTKView], which is a subclass of [`NSView`][NSView] (in macOS) or [`UIView`][UIView] (in iOS and tvOS).
`MTKView` handles many of the details related to getting the content you draw with Metal onto the screen. 

MetalKit提供了一个名为MTKView的类，它是NSView（在macOS中）或UIView（在iOS和tvOS中）的子类。MTKView处理许多细节（将用Metal绘制的内容显示在屏幕上有关的）。

An `MTKView` needs a reference to a Metal device object in order to create resources internally, so your first step is to set the view's  [`device`](https://developer.apple.com/documentation/metalkit/mtkview/1536011-device) property to an existing [`MTLDevice`][MTLDevice].

为了在内部创建资源，MTKView需要引用Metal的设备对象，因此第一步是将视图的device属性设置为现有的MTLDevice。

``` objective-c
_view.device = MTLCreateSystemDefaultDevice();
```

Other properties on `MTKView` allow you to control its behavior. To erase the contents of the view to a solid background color, you set its [`clearColor`](https://developer.apple.com/documentation/metalkit/mtkview/1536036-clearcolor) property. You create the color using the [`MTLClearColorMake`](https://developer.apple.com/documentation/metal/1437971-mtlclearcolormake) function, specifying the red, green, blue, and alpha values.

MTKView上的其他属性允许您控制其行为。将视图内容清除为纯色背景时，需要设置其clearColor属性。使用MTLClearColorMake（：：：：）函数创建颜色，指定红色、绿色、蓝色和alpha值。

``` objective-c
_view.clearColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0);
```

Because you won't be drawing animated content in this sample, configure the view so that it only draws when the contents need to be updated, such as when the view changes shape:

由于您不会在本示例中绘制动画内容，所以配置视图使其仅在需要更新内容时才绘制，例如当视图更改形状时：

``` objective-c
_view.enableSetNeedsDisplay = YES;
```


## Delegate Drawing Responsibilities
设置负责绘制的代理

`MTKView` relies on your app to issue commands to Metal to produce visual content.
`MTKView` uses the delegate pattern to inform your app when it should draw.
To receive delegate callbacks, set the view's `delegate` property to an object that conforms to the [`MTKViewDelegate`][MTKViewDelegate] protocol.

MTKView依赖于您的应用程序向Metal发出命令以生成可视内容。

MTKView使用委托模式通知app何时应该绘制。

要接收回调方法，请将视图的delegate属性设置为符合MTKViewDelegate协议的对象。

``` objective-c
_view.delegate = _renderer;
```

The delegate implements two methods:

代理实现两个方法：

- The view calls the [`mtkView:drawableSizeWillChange:`](https://developer.apple.com/documentation/metalkit/mtkviewdelegate/1536015-mtkview) method whenever the size of the contents changes.
This happens when the window containing the view is resized, or when the device orientation changes (on iOS).
This allows your app to adapt the resolution at which it renders to the size of the view.

- 每当内容大小更改时，视图都会调用mtkView（:drawableSizeWillChange:）方法。
当包含视图的窗口被调整大小，或者设备方向改变（在iOS上）时，就会发生这种情况。
这允许应用程序根据视图的大小调整渲染时的分辨率。

- The view calls the [`drawInMTKView:`](https://developer.apple.com/documentation/metalkit/mtkviewdelegate/1535942-drawinmtkview) method whenever it's time to update the view's contents.
In this method, you create a command buffer, encode commands that tell the GPU what to draw and when to display it onscreen, and enqueue that command buffer to be executed by the GPU. This is sometimes referred to as drawing a frame. You can think of a frame as all of the work that goes into producing a single image that gets displayed on the screen. In an interactive app, like a game, you might draw many frames per second.

- 每当更新视图的内容时，视图都会调用draw（in:）方法。
在这种方法中，您创建一个命令缓冲区，对命令进行编码，这些命令告诉GPU要绘制什么以及何时在屏幕上显示它，并将该命令缓冲区排队等待GPU执行。这有时被称为画框。你可以把一个框架看作是产生一个在屏幕上显示的单一图像的所有工作。在一个互动的应用程序中，你可能喜欢每秒钟画很多帧。

In this sample, a class called `AAPLRenderer` implements the delegate methods and takes on the responsibility of drawing.
The view controller creates an instance of this class and sets it as the view's delegate.

在这个示例中，一个名为AAPLRenderer的类实现了委托方法并承担了绘图的责任。

VC创建此类的一个实例，并将其设置为视图的委托。

## Create a Render Pass Descriptor

创建渲染过程描述符

When you draw, the GPU stores the results into *textures*, which are blocks of memory that contain image data and are accessible to the GPU. In this sample, the `MTKView` creates all of the textures you need to draw into the view. It creates multiple textures so that it can display the contents of one texture while you render into another.

绘制时，GPU将结果存储到纹理中，纹理是包含图像数据的内存块，可供GPU访问。在本示例中，MTKView将创建需要绘制到视图中的所有纹理。它创建多个纹理，以便在渲染到另一个纹理时显示一个纹理的内容。

To draw, you create a *render pass*, which is a sequence of rendering commands that draw into a set of textures. When used in a render pass, textures are also called *render targets*. To create a render pass, you need a render pass descriptor, an instance of [`MTLRenderPassDescriptor`][MTLRenderPassDescriptor]. In this sample, rather than configuring your own render pass descriptor, ask the MetalKit view to create one for you.

若要绘制，请创建渲染过程，该过程是绘制到一组纹理中的渲染命令序列。在渲染过程中使用时，纹理也称为渲染目标。若要创建渲染过程，需要一个渲染过程描述符，即MTLRenderPassDescriptor的实例。在本示例中，请使用MetalKit视图为您创建一个，而不是配置自己的渲染过程描述符。

``` objective-c
MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
if (renderPassDescriptor == nil)
{
    return;
}
```

A render pass descriptor describes the set of render targets, and how they should be processed at the start and end of the render pass. Render passes also define some other aspects of rendering that are not part of this sample. The view returns a render pass descriptor with a single color attachment that points to one of the view's textures, and otherwise configures the render pass based on the view's properties. By default, this means that at the start of the render pass, the render target is erased to a solid color that matches the view's `clearColor` property, and at the end of the render pass, all changes are stored back to the texture.

渲染过程描述符描述了一组渲染目标，以及在渲染过程开始和结束时应如何处理这些目标。渲染过程还定义了渲染的某些其他方面，这些方面不是此示例的一部分。该视图返回一个渲染过程描述符，该描述符具有指向该视图的某个纹理的单色附加，否则将基于该视图的属性配置渲染过程。默认情况下，这意味着在渲染过程开始时，渲染目标将被清除为与视图的clearColor属性匹配的纯色，在渲染过程结束时，所有更改都存储回纹理。

Because a view's render pass descriptor might be `nil`, you should test to make sure the render pass descriptor object is non-`nil` before creating the render pass.

由于视图的渲染过程描述符可能为nil，因此在创建渲染过程之前，应测试以确保渲染过程描述符对象为非空。

## Create a Render Pass
创建渲染过程

You create the render pass by encoding it into the command buffer using a  [`MTLRenderCommandEncoder`][MTLRenderCommandEncoder] object. Call the command buffer's [`renderCommandEncoderWithDescriptor:`](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442999-rendercommandencoderwithdescript) method and pass in the render pass descriptor.

通过使用MTLRenderCommandEncoder对象将其编码到命令缓冲区来创建渲染过程。调用命令缓冲区的makeRenderCommandEncoder（descriptor:）方法并传入呈现过程描述符。

``` objective-c
id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
```

In this sample, you don't encode any drawing commands, so the only thing the render pass does is erase the texture. Call the encoder's `endEncoding` method to indicate that the pass is complete.

在本示例中，您不编码任何绘图命令，因此渲染过程只会删除纹理。调用编码器的endEncoding方法以指示该过程已完成。

``` objective-c
[commandEncoder endEncoding];
```

## Present a Drawable to the Screen
在屏幕上呈现一幅图画

Drawing to a texture doesn't automatically display the new contents onscreen. In fact, only some textures can be presented onscreen. In Metal, textures that can be displayed onscreen are managed by *drawable objects*, and to display the content, you present the drawable.

绘制到纹理不会自动在屏幕上显示新内容。实际上，只有一些纹理可以显示在屏幕上。在Metal中，可以在屏幕上显示的纹理是由可绘制对象管理的，要显示内容，需要显示可绘制对象。

`MTKView` automatically creates drawable objects to manage its textures. Read the [`currentDrawable`](https://developer.apple.com/documentation/metalkit/mtkview/1535971-currentdrawable) property to get the drawable that owns the texture that is the render pass's target. The view returns a [`CAMetalDrawable`][CAMetalDrawable] object, an object connected to Core Animation.

MTKView会自动创建可绘制对象来管理其纹理。读取currentDrawable属性以获取拥有作为渲染过程目标的纹理的drawable。视图返回一个CAMetalDrawable对象，一个连接到核心动画的对象。

``` objective-c
id<MTLDrawable> drawable = view.currentDrawable;
```

Call the [`presentDrawable:`](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-presentdrawable) method on the command buffer, passing in the drawable.

对命令缓冲区调用present（:）方法，传递drawable。


``` objective-c
[commandBuffer presentDrawable:drawable];
```

This method tells Metal that when the command buffer is scheduled for execution, Metal should coordinate with Core Animation to display the texture after rendering completes. When Core Animation presents the texture, it becomes the view's new contents. In this sample, this means that the erased texture becomes the new background for the view. The change happens alongside any other visual updates that Core Animation makes for onscreen user interface elements. 

此方法告诉Metal，当计划执行命令缓冲区时，Metal应与核心动画协调以在渲染完成后显示纹理。当核心动画呈现纹理时，它将成为视图的新内容。在本示例中，这意味着删除的纹理将成为视图的新背景。这种变化与核心动画为屏幕用户界面元素所做的任何其他视觉更新一起发生。

## Commit the Command Buffer
提交命令缓冲区

Now that you've issued all the commands for the frame, commit the command buffer.

现在已经发出了帧的所有命令，提交命令缓冲区。

``` objective-c
[commandBuffer commit];
```


[MTLDevice]: https://developer.apple.com/documentation/metal/mtldevice
[MTLRenderPassDescriptor]: https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor
[MTLRenderCommandEncoder]: https://developer.apple.com/documentation/metal/mtlrendercommandencoder
[MetalKit]: https://developer.apple.com/documentation/metalkit
[MTKView]: https://developer.apple.com/documentation/metalkit/mtkview
[MTKViewDelegate]: https://developer.apple.com/documentation/metalkit/mtkviewdelegate
[HelloTriangle]: https://developer.apple.com/documentation/metal
[MetalComputeBasic]: https://developer.apple.com/documentation/metal
[NSView]: https://developer.apple.com/documentation/appkit/nsview
[UIView]: https://developer.apple.com/documentation/uikit/uiview
[CAMetalDrawable]: https://developer.apple.com/documentation/quartzcore/cametaldrawable
