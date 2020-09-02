# Performing Calculations on a GPU
# 在GPU上执行计算

Use Metal to find GPUs and perform calculations on them.

使用Metal找到GPU并对其进行计算。

## Overview

In this sample, you’ll learn essential tasks that are used in all Metal apps.
You'll see how to convert a simple function written in C to Metal Shading Language (MSL) so that it can be run on a GPU.
You'll find a GPU, prepare the MSL function to run on it by creating a pipeline, and create data objects accessible to the GPU.
To execute the pipeline against your data, create a *command buffer*, write commands into it, and commit the buffer to a command queue.
Metal sends the commands to the GPU to be executed.

在这个示例中，您将学习在所有Metal应用程序中使用的基本任务。

您将看到如何将用C编写的简单函数转换为Metal Shading Language（MSL），以便它可以在GPU上运行。

您将找到一个GPU，通过创建一个管道来准备MSL函数在其上运行，并创建GPU可以访问的数据对象。

要对数据执行管道，请创建一个*command buffer*，将命令写入其中，然后将缓冲区提交到命令队列。

Metal将命令发送到GPU以执行。

## Write a GPU Function to Perform Calculations
## 编写一个GPU函数来执行计算

To illustrate GPU programming, this app adds corresponding elements of two arrays together, writing the results to a third array.
Listing 1 shows a function that performs this calculation on the CPU, written in C.
It loops over the index, calculating one value per iteration of the loop.

为了演示GPU编程，这个应用程序将两个数组的相应元素相加，将结果写入第三个数组。

清单1显示了一个在CPU上执行此计算的函数，用C编写。

它循环索引，每次循环计算一个值。

**Listing 1** Array addition, written in C

``` objective-c
void add_arrays(const float* inA,
                const float* inB,
                float* result,
                int length)
{
    for (int index = 0; index < length ; index++)
    {
        result[index] = inA[index] + inB[index];
    }
}
```

Each value is calculated independently, so the values can be safely calculated concurrently.
To perform the calculation on the GPU, you need to rewrite this function in Metal Shading Language (MSL).
MSL is a variant of C++ designed for GPU programming.
In Metal, code that runs on GPUs is called a *shader*, because historically they were first used to calculate colors in 3D graphics.
Listing 2 shows a shader in MSL that performs the same calculation as Listing 1.
The sample project defines this function in the `add.metal` file.
Xcode builds all `.metal` files in the application target and creates a default Metal library, which it embeds in your app.
You’ll see how to load the default library later in this sample.

每个值都是独立计算的，因此可以安全地同时计算这些值。

要在GPU上执行计算，需要用Metal Shading Language（MSL）重写此函数。

MSL是为GPU编程而设计的C++变体。

在Metal中，运行在gpu上的代码被称为*shader*，因为在历史上，它们首先被用来计算3D图形中的颜色。

清单2显示了MSL中的一个着色器，它执行与清单1相同的计算。

示例项目在`add.metal`文件(官方demo文件，自己的demo为Demo3.metal文件)。

Xcode在应用程序目标中构建所有的“.metal”文件，并创建一个默认的metal库，将其嵌入到应用程序中。

在本示例的后面，您将看到如何加载默认库。

**Listing 2** Array addition, written in MSL
``` metal
kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    result[index] = inA[index] + inB[index];
}
```

Listing 1 and Listing 2 are similar, but there are some important differences in the MSL version. Take a closer look at Listing 2. 

清单1和清单2类似，但是MSL版本有一些重要的区别。仔细看一下清单2。

First, the function adds the `kernel` keyword, which declares that the function is:

首先，函数添加“kernel”关键字，该关键字声明函数为：

- A *public GPU function*. Public functions are the only functions that your app can see. Public functions also can't be called by other shader functions.
- 一个*公共GPU函数*。公共函数是只有你的应用程序能看到的功能。公共函数也不能被其他着色器函数调用。
- A *compute function* (also known as a compute kernel), which performs a parallel calculation using a grid of threads.
- 一个*计算函数*（也称为计算内核），它使用线程网格执行并行计算。

See [Using a Render Pipeline to Render Primitives](https://developer.apple.com/documentation/metal/using_a_render_pipeline_to_render_primitives) to learn the other function keywords used to declare public graphics functions.

请参见[使用渲染管道渲染基本体](https://developer.apple.com/documentation/metal/using_a_render_pipeline_to_render_primitives)学习用于声明公共图形函数的其他函数关键字。

The `add_arrays` function declares three of its arguments with the `device` keyword, which says that these pointers are in the `device` address space.
MSL defines several disjoint address spaces for memory.
Whenever you declare a pointer in MSL, you must supply a keyword to declare its address space.
Use the `device` address space to declare persistent memory that the GPU can read from and write to.

“add_arrays”函数用“device”关键字声明它的三个参数，这表示这些指针位于“device”地址空间中。

MSL为内存定义了几个不相交的地址空间。

无论何时在MSL中声明指针，都必须提供关键字来声明其地址空间。

使用“device”地址空间声明GPU可以读写的持久内存。

Listing 2 removes the for-loop from Listing 1, because the function is now going to be called by multiple threads in the compute grid. 
This sample creates a 1D grid of threads that exactly matches the array's dimensions, so that each entry in the array is calculated by a different thread.

清单2从清单1中删除了for循环，因为该函数现在将由计算网格中的多个线程调用。

此示例创建与数组维度完全匹配的线程的一维网格，因此数组中的每个条目都由不同的线程计算。

To replace the index previously provided by the for-loop, the function takes a new `index` argument, with another MSL keyword, `thread_position_in_grid`, specified using C++ attribute syntax.
This keyword declares that Metal should calculate a unique index for each thread and pass that index in this argument.
Because `add_arrays` uses a 1D grid, the index is defined as a scalar integer.
Even though the loop was removed, Listing 1 and Listing 2 use the same line of code to add the two numbers together.
If you want to convert similar code from C or C++ to MSL, replace the loop logic with a grid in the same way.

为了替换先前由for循环提供的索引，该函数采用一个新的“index”参数，用另一个MSL关键字`thread_position_in_grid`，使用C++属性语法指定。

此关键字声明Metal应为每个线程计算一个唯一的索引，并在该参数中传递该索引。

因为“add_arrays”使用1D网格，所以索引被定义为标量整数。

即使删除了循环，清单1和清单2使用相同的代码行将两个数字相加。

如果您想将类似的代码从C或C++转换为MSL，那么用同样的方式用一个网格替换循环逻辑。

## Find a GPU

In your app, a [`MTLDevice`][MTLDevice] object is a thin abstraction for a GPU; you use it to communicate with a GPU.
Metal creates a `MTLDevice` for each GPU.
You get the default device object by calling [`MTLCreateSystemDefaultDevice()`][MTLCreateSystemDefaultDevice].
In macOS, where a Mac can have multiple GPUs, Metal chooses one of the GPUs as the default and returns that GPU's device object.
In macOS, Metal provides other APIs that you can use to retrieve all of the device objects, but this sample just uses the default.

在你的应用程序中，[`MTLDevice`][MTLDevice]对象是GPU的抽象；你可以用它与GPU通信。

Metal为每个GPU创建一个“MTLDevice”。

通过调用[`MTLCreateSystemDefaultDevice（）`][MTLCreateSystemDefaultDevice]获得默认设备对象。

在macOS中，Mac可以有多个GPU，Metal选择其中一个GPU作为默认值并返回该GPU的设备对象。

在macOS中，Metal提供了其他api，可以用来检索所有设备对象，但是这个示例只使用默认值。

``` objective-c
id<MTLDevice> device = MTLCreateSystemDefaultDevice();
```

## Initialize Metal Objects

Metal represents other GPU-related entities, like compiled shaders, memory buffers and textures, as objects.
To create these GPU-specific objects, you call methods on a [`MTLDevice`][MTLDevice] or you call methods on objects created by a [`MTLDevice`][MTLDevice].
All objects created directly or indirectly by a device object are usable only with that device object.
Apps that use multiple GPUs will use multiple device objects and create a similar hierarchy of Metal objects for each.

Metal将其他与GPU相关的实体（如编译的着色器、内存缓冲区和纹理）表示为对象。

要创建这些特定于GPU的对象，可以对[`MTLDevice`][MTLDevice]调用方法，或者对由[`MTLDevice`][MTLDevice]创建的对象调用方法。

由设备对象直接或间接创建的所有对象只能用于该设备对象。

使用多个gpu的应用程序将使用多个设备对象，并为每个对象创建类似的金属对象层次结构。

The sample app uses a custom `MetalAdder` class to manage the objects it needs to communicate with the GPU.
The class's initializer creates these objects and stores them in its properties.
The app creates an instance of this class, passing in the Metal device object to use to create the secondary objects. The `MetalAdder` object keeps strong references to the Metal objects until it finishes executing.

示例应用程序使用一个自定义的`MetalAdder`（自己的为Demo3Adder）类来管理它需要与GPU通信的对象。

类的初始值设定项创建这些对象并将它们存储在其属性中。

应用程序创建此类的一个实例，传入Metal设备对象以用于创建辅助对象。`MetalAdder`对象保持对Metal对象的强引用，直到它完成执行为止。

``` objective-c
MetalAdder* adder = [[MetalAdder alloc] initWithDevice:device];
```

In Metal, expensive initialization tasks can be run once and the results retained and used inexpensively.
You rarely need to run such tasks in performance-sensitive code.

在Metal中，昂贵的初始化任务只需运行一次，结果就可以保留下来并以较低的成本使用。

很少需要在性能敏感的代码中运行此类任务。

## Get a Reference to the Metal Function
## 引用（自定义的）Metal函数

The first thing the initializer does is load the function and prepare it to run on the GPU.
When you build the app, Xcode compiles the `add_arrays` function and adds it to a default Metal library that it embeds in the app.
You use `MTLLibrary` and `MTLFunction` objects to get information about Metal libraries and the functions contained in them. 
To get an object representing the `add_arrays` function, ask the [`MTLDevice`][MTLDevice] to create a [`MTLLibrary`][MTLLibrary] object for the default library, and then ask the library for a [`MTLFunction`][MTLFunction] object that represents the shader function.

初始化器要做的第一件事是加载函数并准备它在GPU上运行。

构建应用程序时，Xcode编译`add_arrays`函数并将其添加到嵌入到应用程序中的默认Metal库中。

您可以使用MTLLibrary和MTLFunction对象来获取有关Metal库及其包含的函数的信息。

要获取表示`add_arrays`函数的对象，请让MTLDevice为默认库创建一个MTLLibrary对象，然后向库请求表示着色器函数的MTLFunction对象。

``` objective-c
- (instancetype) initWithDevice: (id<MTLDevice>) device
{
    self = [super init];
    if (self)
    {
        _mDevice = device;

        NSError* error = nil;

        // Load the shader files with a .metal file extension in the project

        id<MTLLibrary> defaultLibrary = [_mDevice newDefaultLibrary];
        if (defaultLibrary == nil)
        {
            NSLog(@"Failed to find the default library.");
            return nil;
        }

        id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"add_arrays"];
        if (addFunction == nil)
        {
            NSLog(@"Failed to find the adder function.");
            return nil;
        }
```


## Prepare a Metal Pipeline

The function object is a proxy for the MSL function, but it's not executable code.
You convert the function into executable code by creating a *pipeline*.
A pipeline specifies the steps that the GPU performs to complete a specific task.
In Metal, a pipeline is represented by a *pipeline state object*.
Because this sample uses a compute function, the app creates a [`MTLComputePipelineState`][MTLComputePipelineState] object.

这个函数对象是MSL函数的代理，但它不是可执行代码。

通过创建*pipeline*将函数转换为可执行代码。

管道指定GPU为完成特定任务而执行的步骤。

在Metal中，管道由*pipeline state object*表示。

因为此示例使用compute函数，所以应用程序创建了一个[`MTLComputePipelineState`][MTLComputePipelineState]对象。

``` objective-c
_mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction: addFunction error:&error];
```

A compute pipeline runs a single compute function, optionally manipulating the input data before running the function, and the output data afterwards.

When you create a pipeline state object, the device object finishes compiling the function for this specific GPU.
This sample creates the pipeline state object synchronously and returns it directly to the app.
Because compiling does take a while, avoid creating pipeline state objects synchronously in performance-sensitive code.

计算管道运行一个计算函数，在运行函数之前有选择地处理输入数据，之后处理输出数据。

创建管道状态对象时，设备对象将为特定GPU完成编译这个函数的工作。

此示例同步创建管道状态对象并将其直接返回给应用程序。

因为编译需要一段时间，所以避免在性能敏感的代码中同步创建管道状态对象。

- Note: All of the objects returned by Metal in the code you've seen so far are returned as objects that conform to protocols.
Metal defines most GPU-specific objects using protocols to abstract away the underlying implementation classes, which may vary for different GPUs.
Metal defines GPU-independent objects using classes.
The reference documentation for any given Metal protocol make it clear whether you can implement that protocol in your app.

到目前为止，您在代码中看到的由Metal返回的所有对象都作为符合协议的对象返回。

Metal定义了大多数GPU特定的对象，使用协议抽象出底层实现类，这些实现类可能因不同的GPU而有所不同。

Metal使用类定义独立于GPU的对象。任何给定的Metal协议的参考文档都明确说明了您是否可以在应用程序中实现该协议。

## Create a Command Queue

To send work to the GPU, you need a command queue. Metal uses command queues to schedule commands.
Create a command queue by asking the [`MTLDevice`][MTLDevice] for one.

要将工作发送到GPU，您需要一个命令队列。Metal使用命令队列来调度命令。通过请求MTLDevice来创建命令队列。

``` objective-c
_mCommandQueue = [_mDevice newCommandQueue];
```

## Create Data Buffers and Load Data
## 创建数据缓冲区并加载数据

After initializing the basic Metal objects, you load data for the GPU to execute. This task is less performance critical, but still useful to do early in your app's launch.

A GPU can have its own dedicated memory, or it can share memory with the operating system. 
Metal and the operating system kernel need to perform additional work to let you store data in memory and make that data available to the GPU.
Metal abstracts this memory management using *resource* objects. ([`MTLResource`][MTLResource]).
A resource is an allocation of memory that the GPU can access when running commands.
Use a [`MTLDevice`][MTLDevice] to create resources for its GPU.

The sample app creates three buffers and fills the first two with random data.
The third buffer is where `add_arrays` will store its results.

初始化基本Metal对象后，加载要执行的GPU数据。此任务对性能不太重要，但在应用程序启动的早期仍然有用。

GPU可以有自己的专用内存，也可以与操作系统共享内存。

Metal和操作系统内核需要执行额外的工作，以便将数据存储在内存中，并使这些数据可供GPU使用。

Metal使用*resource*对象抽象了这种内存管理。（MTLResource）。

资源是GPU在运行命令时可以访问的内存分配。使用[`MTLDevice`][MTLDevice]为其GPU创建资源。

示例应用程序创建了三个缓冲区，并用随机数据填充前两个缓冲区。第三个缓冲区是`add_arrays`存储结果的地方。

``` objective-c
_mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
_mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
_mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];

[self generateRandomFloatData:_mBufferA];
[self generateRandomFloatData:_mBufferB];
```

The resources in this sample are ([`MTLBuffer`][MTLBuffer]) objects, which are allocations of memory without a predefined format.
Metal manages each buffer as an opaque collection of bytes.
However, you specify the format when you use a buffer in a shader.
This means that your shaders and your app need to agree on the format of any data being passed back and forth. 

此示例中的资源是([`MTLBuffer`][MTLBuffer])对象，它们是没有预定义格式的内存分配。

Metal将每个缓冲区管理为一个不透明的字节集合。

但是，在着色器中使用缓冲区时，可以指定格式。

这意味着着色器和应用程序需要就来回传递的任何数据的格式达成一致。

When you allocate a buffer, you provide a storage mode to determine some of its performance characteristics and whether the CPU or GPU can access it.
The sample app uses shared memory ([`MTLResourceStorageModeShared`][MTLResourceStorageModeShared]), which both the CPU and GPU can access.

当你分配一个缓冲区时，你提供一个存储模式来确定它的一些性能特征，以及CPU或GPU是否可以访问它。示例应用程序使用共享内存([`MTLResourceStorageModeShared`][MTLResourceStorageModeShared])，CPU和GPU都可以访问该内存。

To fill a buffer with random data, the app gets a pointer to the buffer's memory and writes data to it on the CPU. The `add_arrays` function in Listing 2 declared its arguments as arrays of floating-point numbers, so you provide buffers in the same format:

为了用随机数据填充缓冲区，应用程序会获取指向缓冲区内存的指针，并将数据写入CPU。清单2中的`add_arrays`函数将其参数声明为浮点数数组，因此可以使用相同的格式提供缓冲区：

``` objective-c
- (void) generateRandomFloatData: (id<MTLBuffer>) buffer
{
    float* dataPtr = buffer.contents;

    for (unsigned long index = 0; index < arrayLength; index++)
    {
        dataPtr[index] = (float)rand()/(float)(RAND_MAX);
    }
}
```


## Create a Command Buffer
Ask the command queue to create a command buffer.

请求命令队列创建命令缓冲区。

``` objective-c
id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
```

## Create a Command Encoder

To write commands into a command buffer, you use a *command encoder* for the specific kind of commands you want to code.
This sample creates a compute command encoder, which encodes a *compute pass*.
A compute pass holds a list of commands that execute compute pipelines.
Each compute command causes the GPU to create a grid of threads to execute on the GPU.

要将命令写入命令缓冲区，可以使用*command encoder*对要编码的特定类型的命令进行编码。

此示例创建一个计算命令编码器，该编码器对*compute pass*进行编码。

计算过程包含执行计算管道的命令列表。

每个compute命令都会导致GPU创建一个线程网格来在GPU上执行。

``` objective-c
id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
```

To encode a command, you make a series of method calls on the encoder.
Some methods set state information, like the pipeline state object (PSO) or the arguments to be passed to the pipeline.
After you make those state changes, you encode a command to execute the pipeline.
The encoder writes all of the state changes and command parameters into the command buffer.

要对命令进行编码，需要对编码器进行一系列方法调用。

有些方法设置状态信息，如管道状态对象（PSO）或要传递给管道的参数。

在进行这些状态更改后，您将对命令进行编码以执行管道。

编码器将所有状态更改和命令参数写入命令缓冲区。

![Command Encoding](Documentation/command_encoding.png)

## Set Pipeline State and Argument Data
## 设置管道状态和参数数据

Set the pipeline state object of the pipeline you want the command to execute.
Then set data for any arguments that the pipeline needs to send into the `add_arrays` function. 
For this pipeline, that means providing references to three buffers.
Metal automatically assigns indices for the buffer arguments in the order that the arguments appear in the function declaration in Listing 2, starting with `0`.
You provide arguments using the same indices.

设置要执行命令的管道的管道状态对象。

然后为管道需要发送到`add_arrays`函数的任何参数设置数据。

对于这个管道，这意味着提供对三个缓冲区的引用。

Metal自动按照清单2中函数声明中参数出现的顺序为缓冲区参数分配索引，从0开始。

使用相同的索引提供参数。


``` objective-c
[computeEncoder setComputePipelineState:_mAddFunctionPSO];
[computeEncoder setBuffer:_mBufferA offset:0 atIndex:0];
[computeEncoder setBuffer:_mBufferB offset:0 atIndex:1];
[computeEncoder setBuffer:_mBufferResult offset:0 atIndex:2];
```

You also specify an offset for each argument.
An offset of `0` means the command will access the data from the beginning of a buffer.
However, you could use one buffer to store multiple arguments, specifying an offset for each argument.

You don't specify any data for the index argument because the `add_arrays` function defined its values as being provided by the GPU.

还可以为每个参数指定偏移量。

偏移量为0表示命令将从缓冲区开始访问数据。

但是，可以使用一个缓冲区来存储多个参数，为每个参数指定偏移量。

您没有为index参数指定任何数据，因为`add_arrays`函数将其值定义为由GPU提供。

## Specify Thread Count and Organization
## 指定线程数和组织

Next, decide how many threads to create and how to organize those threads.
Metal can create 1D, 2D, or 3D grids.
The `add_arrays` function uses a 1D array, so the sample creates a 1D grid of size (`dataSize` x 1 x 1), from which Metal generates indices between 0 and `dataSize`-1.

接下来，决定要创建多少线程以及如何组织这些线程。

Metal可以创建一维、二维或三维网格。

`add_arrays`函数使用1D数组，因此示例创建一个1D大小的网格（`dataSize` x 1 x 1），Metal从中生成介于0和`dataSize`-1之间的索引。

``` objective-c
MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
```

## Specify Threadgroup Size
## 指定线程组大小

Metal subdivides the grid into smaller grids called *threadgroups*.
Each threadgroup is calculated separately.
Metal can dispatch threadgroups to different processing elements on the GPU to speed up processing.
You also need to decide how large to make the threadgroups for your command.

Metal将网格细分为更小的网格，称为线程组。

每个线程组单独计算。

Metal可以将线程组分配给GPU上的不同处理元素以加快处理速度。

您还需要决定命令的线程组的大小。

``` objective-c
NSUInteger threadGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
if (threadGroupSize > arrayLength)
{
    threadGroupSize = arrayLength;
}
MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
```

The app asks the pipeline state object for the largest possible threadgroup and shrinks it if that size is larger than the size of the data set.
The [`maxTotalThreadsPerThreadgroup`][maxTotalThreadsPerThreadgroup] property gives the maximum number of threads allowed in the threadgroup, which varies depending on the complexity of the function used to create the pipeline state object.

应用程序向管道状态对象请求最大可能的线程组，如果该大小大于数据集的大小，则会收缩该线程组。


[`maxTotalThreadsPerThreadgroup`][maxTotalThreadsPerThreadgroup]属性提供线程组中允许的最大线程数，这取决于用于创建管道状态对象的函数的复杂性。

## Encode the Compute Command to Execute the Threads

Finally, encode the command to dispatch the grid of threads.

最后，对命令进行编码以分派线程网格。

``` objective-c
[computeEncoder dispatchThreads:gridSize
          threadsPerThreadgroup:threadgroupSize];
```

When the GPU executes this command, it uses the state you previously set and the command's parameters to dispatch threads to perform the computation.

当GPU执行此命令时，它使用您先前设置的状态和命令的参数来分派线程来执行计算。

You can follow the same steps using the encoder to encode multiple compute commands into the compute pass without performing any redundant steps.
For example, you might set the pipeline state object once, and then set arguments and encode a command for each collection of buffers to process.

您可以按照相同的步骤使用编码器将多个计算命令编码到计算过程中，而无需执行任何冗余步骤。

例如，可以设置管道状态对象一次，然后为要处理的每个缓冲区集合设置参数并编码一个命令。

## End the Compute Pass
When you have no more commands to add to the compute pass, you end the encoding process to close out the compute pass.

当没有更多的命令添加到计算过程时，结束编码过程以结束计算过程。

``` objective-c
[computeEncoder endEncoding];
```

## Commit the Command Buffer to Execute Its Commands
## 提交命令缓冲区以执行其命令
Run the commands in the command buffer by committing the command buffer to the queue.

通过将命令缓冲区提交到队列来运行命令缓冲区中的命令。

``` objective-c
[commandBuffer commit];
```

The command queue created the command buffer, so committing the buffer always places it on that queue.
After you commit the command buffer, Metal asynchronously prepares the commands for execution and then schedules the command buffer to execute on the GPU.
After the GPU executes all the commands in the command buffer, Metal marks the command buffer as complete.

命令队列创建了命令缓冲区，因此提交缓冲区时总是将其放在该队列上。

提交命令缓冲区后，Metal异步地准备要执行的命令，然后安排命令缓冲区在GPU上执行。

在GPU执行命令缓冲区中的所有命令后，Metal将命令缓冲区标记为完成。

## Wait for the Calculation to Complete
## 等待计算完成

Your app can do other work while the GPU is processing your commands.
This sample doesn't need to do any additional work, so it simply waits until the command buffer is complete.

当GPU处理你的命令时，你的应用可以做其他的工作。

此示例不需要执行任何其他工作，因此它只需等待命令缓冲区完成。

``` objective-c
[commandBuffer waitUntilCompleted];
```

Alternatively, to be notified when Metal has processed all of the commands, add a completion handler to the command buffer ([`addCompletedHandler`][addCompletedHandler]), or check the status of a command buffer by reading its [`status`][status] property.

或者，要在Metal处理完所有命令时得到通知，请将完成处理程序添加到命令缓冲区([`addCompletedHandler`][addCompletedHandler])，或者通过读取命令缓冲区的[`status`][status]属性来检查命令缓冲区的状态。

## Read the Results From the Buffer

After the command buffer completes, the GPU's calculations are stored in the output buffer and Metal performs any necessary steps to make sure the CPU can see them.
In a real app, you would read the results from the buffer and do something with them, such as displaying the results onscreen or writing them to a file.
Because the calculations are only used to illustrate the process of creating a Metal app, the sample reads the values stored in the output buffer and tests to make sure the CPU and the GPU calculated the same results.

命令缓冲区完成后，GPU的计算存储在输出缓冲区中，Metal执行任何必要的步骤，以确保CPU可以看到它们。

在一个真正的应用程序中，你可以从缓冲区中读取结果并对其进行处理，例如在屏幕上显示结果或将结果写入文件。

因为计算只是用来说明创建一个Metal应用程序的过程，所以该示例读取存储在输出缓冲区中的值并进行测试，以确保CPU和GPU计算出的结果相同。

``` objective-c
- (void) verifyResults
{
    float* a = _mBufferA.contents;
    float* b = _mBufferB.contents;
    float* result = _mBufferResult.contents;

    for (unsigned long index = 0; index < arrayLength; index++)
    {
        if (result[index] != (a[index] + b[index]))
        {
            printf("Compute ERROR: index=%lu result=%g vs %g=a+b\n",
                   index, result[index], a[index] + b[index]);
            assert(result[index] == (a[index] + b[index]));
        }
    }
    printf("Compute results as expected\n");
}
```

[MTLDevice]: https://developer.apple.com/documentation/metal/mtldevice
[MTLCreateSystemDefaultDevice]: https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice
[MTLResource]: https://developer.apple.com/documentation/metal/mtlresource
[MTLBuffer]: https://developer.apple.com/documentation/metal/mtlbuffer
[MTLResourceStorageModeShared]: https://developer.apple.com/documentation/metal/mtlresourceoptions/mtlresourcestoragemodeshared
[MTLComputePipelineState]: https://developer.apple.com/documentation/metal/mtlcomputepipelinestate
[maxTotalThreadsPerThreadgroup]: https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/1414927-maxtotalthreadsperthreadgroup
[status]: https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443048-status
[addCompletedHandler]: https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442997-addcompletedhandler
[MTLLibrary]: https://developer.apple.com/documentation/metal/mtllibrary
[MTLFunction]: https://developer.apple.com/documentation/metal/mtlfunction
[HelloTriangle]: https://developer.apple.com/documentation/metal
